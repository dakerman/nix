# Installing NixOS beside Windows on the desktop

What you end up with: Windows untouched on its own partitions and its own EFI
partition, NixOS on new partitions with a second EFI partition, systemd-boot as
the boot menu (NixOS by default, Windows one entry down), and the machine
reachable from the laptop as `ssh desktop` over Tailscale. The config is
`hosts/desktop/` in this repo.

Steps 1–3 happen on the desktop in Windows and its firmware, 4–6 on the desktop
in NixOS, 7–8 from the laptop.

## 1. In Windows, before touching anything

1. Back up what you cannot lose. Shrinking a partition is routine but not
   risk-free.
2. **BitLocker / Device encryption.** Settings → Privacy & security → Device
   encryption (Home) or Control Panel → BitLocker (Pro). If it is on, save the
   recovery key somewhere you can read from your phone (Microsoft account →
   Devices → "View BitLocker keys", or in an admin PowerShell
   `manage-bde -protectors -get C:`). Turning Secure Boot off in step 2 makes
   Windows ask for it once.
3. **Fast Startup off.** Control Panel → Power Options → "Choose what the power
   buttons do" → "Change settings that are currently unavailable" → untick
   "Turn on fast startup". Or in an admin PowerShell: `powercfg /h off`.
   With it on, Windows leaves its filesystem half-hibernated, which breaks
   mounting it from Linux and can confuse the clock.
4. **Check the firmware mode.** Run `msinfo32`: "BIOS Mode" must say UEFI.
   (If it says Legacy, stop here and tell me; that needs a different plan.)
   Note "Secure Boot State" too.
5. **Make room.** `diskmgmt.msc` → right-click `C:` → Shrink Volume. Free at
   least 150 GB (200 GB is comfortable: the training venv is ~10 GB and the Nix
   store grows). Leave it *unallocated*. If you have a spare SSD, use that
   instead and skip the shrink. Note which disk and how big the free space is;
   you will recognise it in the installer by that.
6. **Anti-cheat check.** If you play something that requires Secure Boot in
   Windows (Valorant/Vanguard, Battlefield 6, recent Call of Duty, ...), know
   that step 2 turns Secure Boot off. Windows itself does not care. Step 9 puts
   it back on later with signed NixOS boot files.
7. **USB stick.** Download the NixOS 26.05 *graphical* ISO (Plasma) from
   nixos.org/download and write it to a stick: Rufus (choose "DD image mode"
   when asked) or Ventoy on Windows; from the laptop
   `sudo dd if=nixos-*.iso of=/dev/sdX bs=4M status=progress oflag=sync` after
   checking the device name with `lsblk`.

## 2. Firmware settings (Del/F2 at power-on)

- Secure Boot → **Disabled**. NixOS's boot loader is unsigned until step 9.
- Leave the SATA/NVMe mode alone. (If it is "Intel VMD" / "RST" and the
  installer cannot see the disk later, do not switch it: that breaks Windows.
  Tell me; the hardware scan usually handles it.)
- Find the one-time boot menu key (F8/F11/F12 depending on the board); you
  will use it for the USB stick now and to reach Windows directly if ever
  needed.

## 3. Install from the USB stick

1. Boot the stick (UEFI entry). Plug in Ethernet, or join Wi-Fi from the tray.
2. Start the installer on the desktop. Language English, region
   Europe/Stockholm, keyboard Swedish.
3. Desktop: Plasma. User: name Daniel, login `daniel`, a password, host name
   `desktop`. The flake replaces all of this on first boot; only the user and
   password survive.
4. Partitions → **Manual partitioning**. Pick the disk with the free space. You
   will see Windows' partitions: EFI (~100 MB, FAT32), Microsoft reserved
   (16 MB), `C:` (NTFS), recovery (NTFS). **Do not touch them.** Select the free
   space and Create, twice:
   - 1024 MiB, FAT32, mount point `/boot`, flag **boot** (esp), label `NIXBOOT`
   - the rest, ext4, mount point `/`, label `NIXOS`

   No swap partition (the config uses zram). Before clicking Install, the
   summary must list only two *create* operations on free space: nothing
   formatted or deleted on the NTFS or existing EFI partitions.
5. Install, reboot, remove the stick. systemd-boot shows NixOS. (Windows is not
   in that menu yet; the firmware boot menu still boots it.)

## 4. First boot: switch to this flake

In Konsole on the desktop:

```sh
nix-shell -p git
git clone https://github.com/dakerman/nix.git ~/workspace/nix
cp /etc/nixos/hardware-configuration.nix ~/workspace/nix/hosts/desktop/hardware-configuration.nix
cd ~/workspace/nix && git diff hosts/desktop/hardware-configuration.nix
```

The diff should show `/` as ext4 and `/boot` as vfat by UUID, a
`hardware.cpu.<vendor>.updateMicrocode` line, and no LUKS. Then:

```sh
sudo env NIX_CONFIG='experimental-features = nix-command flakes' nixos-rebuild switch --flake .#desktop
```

(The `env` part is needed only this once: the freshly installed system has flakes
off; the flake turns them on.)
This downloads the NVIDIA driver and Plasma. **Reboot** afterwards: the new
kernel and the nvidia module only load on a fresh boot. Then check:

```sh
nvidia-smi          # both 3060 Ti listed
```

Commit the hardware file from the laptop later (`git add hosts/desktop`), or
push from the desktop once step 7 forwards your keys there.

## 5. Clock and the Windows side

Boot Windows once through the firmware boot menu. If BitLocker asks for the
recovery key, enter it; it will not ask again. Check the time is right in both
systems (`time.hardwareClockInLocalTime` in the config handles this).

## 6. Windows in the boot menu

1. Reboot, choose **EDK2 UEFI Shell** in the systemd-boot menu.
2. `map -c` lists disks and partitions as `HD0b`, `HD1a`, ... For each
   `HDxy`, run `ls HDxy:\EFI`; the one that lists a `Microsoft` directory is
   Windows' EFI partition.
3. Test it: `HDxy:\EFI\Microsoft\Boot\Bootmgfw.efi` must boot Windows.
4. Put the handle in `hosts/desktop/configuration.nix` by uncommenting
   `boot.loader.systemd-boot.windows."11".efiDeviceHandle = "HDxy";` and run
   `sudo nixos-rebuild switch --flake .#desktop`. The menu now has
   "Windows 11". Keep `edk2-uefi-shell.enable`; the Windows entry uses the shell.

NixOS stays the default entry after the 5-second timeout, so a remote reboot
always lands in NixOS; Windows is a menu choice.

## 7. Reach it from the laptop

On the desktop: `sudo tailscale up`, open the printed URL, log in (Google or
GitHub; this creates your tailnet). On the laptop, after
`sudo nixos-rebuild switch --flake .#bits` with this change:
`sudo tailscale up --hostname bits` (same account; the laptop's hostname is
`nixos`, this names it sensibly in the tailnet). Then from the laptop:

```sh
ssh desktop          # type yes once for the host key
```

Pin the host key so no other machine can impersonate it: on the desktop
`cat /etc/ssh/ssh_host_ed25519_key.pub`, then in `modules/common/default.nix`:

```nix
programs.ssh.knownHosts.desktop = {
  extraHostNames = [ "desktop" ];
  publicKey = "ssh-ed25519 AAAA...";
};
```

sshd is reachable only over Tailscale (port 22 is closed on the LAN), and only
with the laptop's key.

## 8. Training on the desktop's GPUs

The training code must run where the GPUs are, so `microduck_rl` gets a
checkout on the desktop. `quack-your-customer` stays on the laptop. Over
`ssh desktop` (the laptop's ssh-agent is forwarded, so GitHub works with your
laptop keys; run `ssh-add ~/.ssh/id_ed25519_bits` on the laptop first if the
clone is refused):

```sh
mkdir -p ~/workspace && cd ~/workspace
git clone ssh://git@github.com/Bits-Technology/microduck_rl.git
cd microduck_rl && git checkout <your branch>
uv sync                 # first time: ~3 GB (uv's own Python 3.12, CUDA wheels)
uv run python -c 'import torch; print(torch.cuda.device_count(), torch.cuda.get_device_name(0))'
uv run wandb login      # runs log to wandb; play/export fetch checkpoints from there
uv run train Mjlab-Velocity-Flat-MicroDuck --env.scene.num-envs 64 --agent.max_iterations 5   # smoke test
```

Real runs live in tmux so they survive the SSH session:

```sh
tmux new -s train
uv run train Mjlab-Velocity-Flat-MicroDuck --env.scene.num-envs 4096
# Ctrl-b d detaches; `tmux attach -t train` later. Second card, second window:
CUDA_VISIBLE_DEVICES=1 uv run train <another task> --env.scene.num-envs 4096
nvtop                   # what each GPU is doing
```

Editing: in VS Code on the laptop, "Remote-SSH: Connect to Host..." →
`desktop`, open `~/workspace/microduck_rl`. Exported ONNX files come back with
`scp desktop:~/workspace/microduck_rl/output.onnx .`.

If the smoke test says it cannot find `libcuda.so.1`, run it once as
`LD_LIBRARY_PATH=/run/opengl-driver/lib uv run train ...` and tell me; the
config's nix-ld library list is meant to make that unnecessary.

## 9. Later, if a game needs Secure Boot

Lanzaboote signs NixOS's boot files with your own keys and enrolls them
alongside Microsoft's, so Secure Boot can be on for both systems. It is a
separate change (new flake input, `sbctl create-keys`, `sbctl enroll-keys -m`,
Secure Boot back on); ask when you want it. Until then Secure Boot stays off.

## When something goes wrong

- **Windows boots straight away, no menu.** A Windows update reset the boot
  order. Firmware boot menu → "Linux Boot Manager", then in NixOS
  `sudo bootctl install` puts it back first.
- **BitLocker recovery prompt every boot.** Windows measures the boot path;
  after it settles once it should stop. If not, suspend and resume BitLocker in
  Windows (`manage-bde -protectors -disable C:` then `-enable`).
- **The installer does not see the NVMe disk.** Usually Intel VMD; see step 2.
- **Windows partition mounts read-only in NixOS.** Fast Startup is still on
  (step 1.3), or Windows was hibernated rather than shut down.
