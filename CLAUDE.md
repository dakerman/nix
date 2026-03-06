# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Apply configuration (makes it permanent)
sudo nixos-rebuild switch --flake .#bits

# Test configuration without making it permanent
sudo nixos-rebuild test --flake .#bits

# Build without activating (smoke test)
sudo nixos-rebuild build --flake .#bits

# Check flake validity (syntax/type errors)
nix flake check

# Update all flake inputs
nix flake update

# Update a single input (e.g. nixpkgs)
nix flake update nixpkgs

# Format all .nix files
nix fmt
```

## Architecture

This is a NixOS flake configuration for a single host called `bits` (x86_64-linux).

**Inputs:** `nixpkgs` (25.11 stable), `nixpkgs-unstable`, and `home-manager` (release-25.11).

**Entry point:** `flake.nix` → `bits/default.nix` constructs the `nixosSystem`, passing `pkgs-unstable` as a `specialArg` so it's available in any module as a parameter.

**Module layout:**
- `bits/configuration.nix` — host-specific system config (users, packages, services, locale, boot)
- `bits/user-daniel.nix` — Home Manager config for the `daniel` user (VS Code, user packages, dotfiles)
- `bits/hardware-configuration.nix` — hardware scan output (LUKS device, filesystems)
- `modules/system/` — reusable NixOS modules auto-imported by `modules/system/default.nix`
  - `fingerprint/` — custom module; adds `fingerprint.enable` and `fingerprint.driver` options (`goodix` | `elan` | `generic`)
  - `touchpad/` — custom module; adds `touchpad.enable` option

**Home Manager** is wired in as a NixOS module in `bits/default.nix` (inline config block with `useGlobalPkgs = true`, `useUserPackages = true`). User-level config (apps, dotfiles, settings) goes in `bits/user-daniel.nix`. System-level config stays in `bits/configuration.nix`.

**Adding new system-wide modules:** create a subdirectory under `modules/system/` with a `default.nix` and add it to the imports list in `modules/system/default.nix`.

**Using unstable packages:** access via the `pkgs-unstable` argument (already available in any module due to `specialArgs`). Example in use: `pkgs-unstable.claude-code`.
