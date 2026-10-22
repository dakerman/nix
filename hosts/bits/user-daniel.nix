# Home Manager for daniel on the work laptop. Shared config is in
# modules/common/home.nix; this file has what only makes sense on this machine.

{ pkgs, ... }:

{
  home.stateVersion = "25.11";

  programs.ssh.settings = {
    "github.com" = {
      HostName = "github.com";
      IdentityFile = "~/.ssh/id_ed25519_bits";
      IdentitiesOnly = true;
      AddKeysToAgent = "yes";
    };
    "github-personal" = {
      HostName = "github.com";
      IdentityFile = "~/.ssh/id_rsa";
      IdentitiesOnly = true;
      AddKeysToAgent = "yes";
    };
    # The home desktop, over Tailscale (MagicDNS resolves the bare name).
    # ForwardAgent: git and gh over there use this laptop's keys through the
    # forwarded agent, so no keys are kept on the desktop.
    desktop = {
      HostName = "desktop";
      User = "daniel";
      IdentityFile = "~/.ssh/id_ed25519";
      IdentitiesOnly = true;
      ForwardAgent = true;
    };
  };

  # Edit code that lives on the desktop from here: "Remote-SSH: Connect to
  # Host..." → desktop. The VS Code server it installs over there runs via nix-ld.
  programs.vscode.profiles.default.extensions = [
    pkgs.vscode-extensions.ms-vscode-remote.remote-ssh
  ];

  # Hardware video decoding on the Arc 140V (Lunar Lake), for both profiles.
  programs.firefox.profiles =
    let
      hwDecode = {
        # Enable VA-API hardware video decoding for normal playback, e.g. YouTube
        # (uses Intel iHD driver via LIBVA_DRIVER_NAME).
        "media.ffmpeg.vaapi.enabled" = true;
        # Hardware-decode VP8/VP9 WebRTC video (video calls: Meet, Zoom web, Teams).
        # Default since Firefox 156; kept explicit so it survives a default change.
        "media.navigator.mediadatadecoder_vpx_enabled" = true;
        # Hardware-decode AV1 in WebRTC calls (Meet uses AV1). Off by default in
        # Firefox 156; the Arc 140V has an AV1 decoder. Note: Firefox on Linux has no
        # hardware *encoding* for calls, so the camera stream is still CPU-encoded.
        "media.navigator.mediadatadecoder_av1_enabled" = true;
        # Force HW decode even though Firefox hasn't allowlisted this brand-new GPU
        # (Arc 140V / Lunar Lake); otherwise it can silently fall back to software.
        "media.hardware-video-decoding.force-enabled" = true;
      };
    in
    {
      work.settings = hwDecode;
      private.settings = hwDecode;
    };

  # Plasma touchpad settings
  programs.plasma.input.touchpads = [
    {
      name = "SNSL0028:00 2C2F:0028 Touchpad";
      vendorId = "2c2f";
      productId = "0028";
      rightClickMethod = "twoFingers";
      tapToClick = true;
      # Prevent accidental drags from tap+slide (was picking up tabs/windows)
      tapAndDrag = false;
      tapDragLock = false;
      scrollMethod = "twoFingers";
      disableWhileTyping = true;
      accelerationProfile = "none";
      pointerSpeed = 0;
      naturalScroll = true;
    }
  ];
}
