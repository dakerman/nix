# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Apply configuration (makes it permanent); .#bits on the laptop, .#desktop on the desktop
sudo nixos-rebuild switch --flake .#bits

# Test configuration without making it permanent
sudo nixos-rebuild test --flake .#bits

# Build without activating (smoke test)
sudo nixos-rebuild build --flake .#bits

# Check flake validity (syntax/type errors), evaluates every host
nix flake check

# Update all flake inputs
nix flake update

# Update a single input (e.g. nixpkgs)
nix flake update nixpkgs

# Format all .nix files
nix fmt
```

## Architecture

This is a NixOS flake configuration for two x86_64-linux hosts, with one user (`daniel`) on each.

**Inputs:** `nixpkgs` (26.05 stable), `nixpkgs-unstable`, `home-manager` (release-26.05), and `plasma-manager`.

**Entry point:** `flake.nix` lists the host names; `lib/mk-host.nix` builds each one from `hosts/<name>/`, wiring in the shared base, the feature modules, `pkgs-unstable` as a module argument (`specialArgs`) and Home Manager.

**Layout:**
- `hosts/<name>/configuration.nix` — what is specific to that host (NixOS)
- `hosts/<name>/user-daniel.nix` — what is specific to that host (Home Manager for `daniel`)
- `hosts/<name>/hardware-configuration.nix` — hardware scan output
- `modules/common/default.nix` — the always-on base every host gets (boot loader, networking, Tailscale, locale, Plasma, audio, the `daniel` account, packages wanted everywhere)
- `modules/common/home.nix` — Home Manager config for `daniel` that is the same on every host (VS Code, git, shell, Plasma/Krohnkite settings, ...)
- `modules/system/` — opt-in feature modules auto-imported by `modules/system/default.nix`, each adding a `<name>.enable` option (`bluetooth`, `docker`, `fingerprint`, `gaming`, `graphics`, `power-management`, `speaker-eq`, `touchpad`)

**Hosts:**
- `bits` — work laptop (Intel Core Ultra 7 258V / Arc 140V, LUKS). Hostname is still `nixos`.
- `desktop` — home gaming PC dual-booting Windows (NixOS on its own partitions and EFI partition), Ryzen 7 7700 + one RTX 3060 (12 GB), used mostly headless over Tailscale (`ssh desktop`) as the GPU box for training the duck (`~/workspace/microduck_rl` there). `hosts/desktop/INSTALL.md` is the install and setup runbook (installed 2026-10-22).

**Why the shared files are listed in `lib/mk-host.nix` rather than imported by the host files:** the module system orders list options (`environment.systemPackages`, `home.packages`) by where a module sits in the import tree. Listing them beside the host files keeps the `bits` closure identical to before the split. When refactoring, prove nothing changed with `nix eval --raw .#nixosConfigurations.bits.config.system.build.toplevel.drvPath` before and after (`nix run nixpkgs#nix-diff -- <old> <new>` explains a difference).

**Home Manager** is wired in as a NixOS module in `lib/mk-host.nix` (`useGlobalPkgs = true`, `useUserPackages = true`). User-level config (apps, dotfiles, settings, input devices via plasma-manager) goes in `modules/common/home.nix` when it applies everywhere, otherwise in `hosts/<name>/user-daniel.nix`. System-level config follows the same split between `modules/common/default.nix` and `hosts/<name>/configuration.nix`.

**Adding a host:** create `hosts/<name>/` with the three files and add the name to the list in `flake.nix`.

**Adding new system-wide modules:** create a subdirectory under `modules/system/` with a `default.nix` and add it to the imports list in `modules/system/default.nix`.

**Plasma input settings** (`programs.plasma.input.touchpads`, etc.) require logging out and back in to take effect after `nixos-rebuild switch`.

**Using unstable packages:** access via the `pkgs-unstable` argument (already available in any module due to `specialArgs`). Example in use: `pkgs-unstable.claude-code`.

**Remote access between the hosts:** every host runs Tailscale (`modules/common`); the desktop runs sshd reachable only over the tailnet, authorizing the laptop's `~/.ssh/id_ed25519`. The laptop's `ssh desktop` block forwards its ssh-agent, so the desktop needs no keys of its own for GitHub.
