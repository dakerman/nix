{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

{
  options.gaming = {
    enable = mkEnableOption "Enable gaming support (Steam, GameMode, Gamescope, MangoHud)";
  };

  config = mkIf config.gaming.enable {
    # Runs Steam in an FHS sandbox, pulls in 32-bit graphics/audio libraries,
    # and installs udev rules for game controllers (hardware.steam-hardware).
    programs.steam = {
      enable = true;
      # Community Proton fork with extra game fixes and media codecs.
      # Select it per game: right-click → Properties → Compatibility.
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };

    # GameMode switches the CPU governor to performance and raises process
    # priority while a game runs (start games with `gamemoderun %command%`).
    # Users need to be in the "gamemode" group for the renice part to work.
    programs.gamemode = {
      enable = true;
      settings.general = {
        renice = 10; # priority boost for the game process (gamemode default is 0 = off)
      };
    };

    # Nested compositor for upscaling: render at a lower resolution and scale up
    # with FSR, e.g. `gamescope -w 1920 -h 1200 -F fsr -f -- %command%`.
    # Deliberately NOT setting capSysNice — its setcap wrapper breaks gamescope
    # when launched from inside Steam's sandboxed runtime.
    programs.gamescope.enable = true;

    # FPS/frametime overlay: add `mangohud %command%` to a game's launch options.
    environment.systemPackages = [ pkgs.mangohud ];

    # Many Windows games under Proton map far more memory regions than the Linux
    # default allows and crash without this (SteamOS ships the same value).
    boot.kernel.sysctl."vm.max_map_count" = 2147483642;
  };
}
