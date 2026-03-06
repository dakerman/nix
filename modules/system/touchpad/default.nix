{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

{
  options.touchpad = {
    enable = mkEnableOption "Enable touchpad support";
  };

  config = mkIf config.touchpad.enable {
    services.libinput.enable = true;
  };
}
