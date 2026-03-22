{ config, lib, pkgs, ... }:
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

    # Enable high-quality Bluetooth audio codecs via Wireplumber
    services.pipewire.wireplumber.extraConfig.bluetoothEnhancements = {
      "monitor.bluez.properties" = {
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-msbc" = true;
        "bluez5.enable-hw-volume" = true;
        "bluez5.codecs" = [
          "sbc"
          "sbc_xq"
          "aac"
          "ldac"
          "aptx"
          "aptx_hd"
          "aptx_ll"
          "aptx_ll_duplex"
          "aptx_adaptive"
        ];
      };
    };

    # aptX codec support library
    environment.systemPackages = [ pkgs.libfreeaptx ];
  };
}
