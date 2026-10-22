# Home gaming PC, dual-booting Windows. NixOS has its own partitions and its own
# EFI partition; Windows' are never touched. Mostly used headless, over
# Tailscale from the laptop, as the GPU box for training the duck (microduck_rl:
# MuJoCo Warp + PyTorch on CUDA). INSTALL.md next to this file is the runbook.

{ config, pkgs, ... }:

{
  networking.hostName = "desktop";

  # --- Dual boot ---------------------------------------------------------------

  # Windows' boot loader sits on its own EFI partition, which systemd-boot cannot
  # list by itself. The EDK2 UEFI shell can chainload it; `efiDeviceHandle` names
  # Windows' EFI partition as that shell sees it (`map -c`). INSTALL.md step 6
  # finds the handle. Until then the shell is a menu entry of its own, and the
  # firmware's boot menu (F8/F11/F12) still boots Windows directly.
  boot.loader.systemd-boot.edk2-uefi-shell.enable = true;
  # boot.loader.systemd-boot.windows."11".efiDeviceHandle = "HD0b"; # fill in (INSTALL.md step 6)

  # Windows keeps the hardware clock in local time; do the same, or every switch
  # between the two systems shifts the clock by the UTC offset.
  time.hardwareClockInLocalTime = true;

  # Read the Windows partitions (ntfs-3g). Turn off Fast Startup in Windows
  # first, or its filesystem is left "hibernated" and only mounts read-only.
  boot.supportedFilesystems = [ "ntfs" ];

  # --- Hardware ----------------------------------------------------------------

  # Two GeForce RTX 3060 Ti (modules/system/graphics: NVIDIA driver, CUDA via
  # the driver's libcuda for the training wheels below).
  graphics = {
    enable = true;
    nvidia = true;
  };
  # NVIDIA's recommended kernel module for Turing and newer (RTX); the graphics
  # module defaults to the closed one for older GPUs.
  hardware.nvidia.open = true;

  # Compressed swap in RAM instead of a swap partition.
  zramSwap.enable = true;

  bluetooth.enable = true; # DualSense and the like

  # Steam + GameMode + Gamescope + MangoHud (modules/system/gaming)
  gaming.enable = true;

  # --- Remote access: Tailscale (modules/common) + sshd on the tailnet only ----

  services.openssh = {
    enable = true;
    # Port 22 stays closed on the LAN and the internet; only the tailnet
    # interface, trusted below, reaches sshd.
    openFirewall = false;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  # The laptop's key (~/.ssh/id_ed25519.pub on bits). GitHub access from here
  # comes through the laptop's forwarded ssh-agent, so no keys live on this host.
  users.users.daniel.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKqBYuX8byANEKAXiVPWcc9E+eHSAEOIRY2sN33DZ7Ia daniel@nixos"
  ];

  # --- Training box ------------------------------------------------------------
  # `uv sync` and `uv run train` in a microduck_rl checkout work as on any other
  # Linux; no flake or direnv is needed on this host.

  # nix-ld provides the /lib64 loader that NixOS lacks, so prebuilt binaries
  # run: uv's own Python 3.12, the uv_build backend wheel, and the VS Code server
  # that Remote-SSH from the laptop installs. Programs under it see the libraries
  # listed here; the NVIDIA driver is in the list so the torch and warp wheels
  # (they bundle the CUDA toolkit itself) find the driver's libcuda.so.1.
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = [
    config.hardware.nvidia.package
    pkgs.libglvnd # EGL/OpenGL for MuJoCo's offscreen rendering (MUJOCO_GL=egl)
  ];

  environment.systemPackages = with pkgs; [
    uv # runs microduck_rl: `uv sync`, `uv run train ...`
    tmux # keeps a training run alive after the SSH session ends
    nvtopPackages.nvidia # per-process GPU usage; nvidia-smi comes with the driver
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. Leave it at the release this host was installed with.
  system.stateVersion = "26.05";
}
