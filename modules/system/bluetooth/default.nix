{ config, lib, ... }:
with lib;

{
  options.bluetooth = {
    enable = mkEnableOption "Enable Bluetooth";
  };

  config = mkIf config.bluetooth.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };
}
