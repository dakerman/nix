---
name: Vimium Firefox extension
description: Daniel wants to add Vimium (keyboard-driven browsing) to his Firefox config, modeled after the reference repo's setup
type: project
---

Daniel wants to add Firefox with the Vimium extension for keyboard-driven browsing.

**Why:** Wants to use the keyboard more and the mouse less when browsing.

**How to apply:** When Daniel is ready, add `programs.firefox` to `bits/user-daniel.nix` with Vimium via `pkgs.nur.repos.rycee.firefox-addons.vimium`. Use the reference repo's Firefox module (`/home/daniel/workspace/nix-home/modules/users/firefox/default.nix`) as a starting point — it also includes ublock-origin, bitwarden, privacy-badger, and other useful extensions worth offering. Note: the reference repo uses NUR for Firefox addons, so the NUR flake input may need to be added.
