{ config, lib, pkgs, ... }:
with lib;

{
  options.graphics = {
    enable = mkEnableOption "Enable graphics hardware";

    nvidia = mkEnableOption "Nvidia graphics";

    intel = {
      enable = mkEnableOption "Intel graphics";

      generation = mkOption {
        type = types.enum [ "legacy" "modern" "arc" ];
        default = "modern";
        description = ''
          Intel GPU generation:
          - "legacy": Pre-Broadwell (Sandy Bridge, Ivy Bridge, Haswell) - uses i965 VA-API driver
          - "modern": Broadwell through Tiger Lake (2014-2020) - uses iHD VA-API driver
          - "arc": Alder Lake / Meteor Lake / Lunar Lake and Intel Arc discrete GPUs (2021+)
                   Uses iHD VA-API driver and the xe kernel driver (not i915)
        '';
      };
    };

    amd = mkOption {
      type = types.bool;
      default = false;
      description = "Enable AMD graphics support";
    };
  };

  config = mkIf config.graphics.enable {
    environment.systemPackages = with pkgs; [ vulkan-tools ];

    services.xserver.videoDrivers =
      (optional config.graphics.amd "amdgpu")
      ++ (optional config.graphics.nvidia "nvidia")
      ++ (optional config.graphics.intel.enable "modesetting");

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages =
        with pkgs;
        [
          mesa
          libva
          libva-utils
          libva-vdpau-driver
          libvdpau-va-gl
          mangohud
        ]
        ++ (optionals (config.graphics.intel.enable && config.graphics.intel.generation == "legacy") [
          intel-vaapi-driver  # LIBVA_DRIVER_NAME=i965
          intel-ocl
        ])
        ++ (optionals (config.graphics.intel.enable && config.graphics.intel.generation != "legacy") [
          intel-media-driver  # LIBVA_DRIVER_NAME=iHD
          intel-compute-runtime
        ]);
      extraPackages32 = with pkgs; [ mangohud ];
    };

    hardware.cpu.intel.updateMicrocode = mkIf config.graphics.intel.enable true;

    # Early KMS for smoother boot.
    # Arc/Lunar Lake uses the xe driver; legacy/modern Intel uses i915.
    boot.initrd.kernelModules = mkIf config.graphics.intel.enable (
      if config.graphics.intel.generation == "arc" then [ "xe" ] else [ "i915" ]
    );

    hardware.nvidia = mkIf config.graphics.nvidia {
      modesetting.enable = true;
      powerManagement.enable = true;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    environment.variables = {
      __NVFBC_CAPTURE = mkIf config.graphics.nvidia "1";
      LIBVA_DRIVER_NAME = mkIf config.graphics.intel.enable (
        if config.graphics.intel.generation == "legacy" then "i965" else "iHD"
      );
      VDPAU_DRIVER = mkIf config.graphics.intel.enable "va_gl";
    };
  };
}
