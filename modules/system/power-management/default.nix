{ config, lib, ... }:
with lib;

{
  options.power-management = {
    enable = mkEnableOption "Enable power management";

    cpuVendor = mkOption {
      type = types.nullOr (types.enum [ "amd" "intel" ]);
      default = null;
      description = ''
        CPU vendor for vendor-specific power settings.
        Set to "amd" for AMD P-State and platform profile settings.
        Set to "intel" for Intel P-State/HWP energy policy settings.
        Set to null to skip vendor-specific CPU settings.
      '';
    };

    gpuVendor = mkOption {
      type = types.nullOr (types.enum [ "amd" ]);
      default = null;
      description = ''
        GPU vendor for vendor-specific power settings.
        Currently only "amd" is supported. Set to null to skip.
      '';
    };

    powerModes = {
      ac = mkOption {
        type = types.str;
        default = "performance";
        description = "CPU frequency governor on AC power";
      };
      battery = mkOption {
        type = types.str;
        default = "powersave";
        description = "CPU frequency governor on battery";
      };
    };
  };

  config = mkIf config.power-management.enable {
    powerManagement.cpuFreqGovernor = "powersave";

    services.upower.enable = true;

    # Lid close behavior.
    # KDE PowerDevil handles screen locking; logind handles suspend.
    services.logind = {
      lidSwitch = "suspend";              # Lid close on battery: suspend
      lidSwitchExternalPower = "suspend"; # Lid close on AC: suspend
      lidSwitchDocked = "ignore";         # Lid close when docked: ignore
    };

    # TLP conflicts with power-profiles-daemon (enabled by KDE Plasma by default)
    services.power-profiles-daemon.enable = false;

    services.tlp = {
      enable = true;
      settings = mkMerge [
        {
          # CPU scaling governor
          CPU_SCALING_GOVERNOR_ON_AC = config.power-management.powerModes.ac;
          CPU_SCALING_GOVERNOR_ON_BAT = config.power-management.powerModes.battery;

          # Disable CPU boost on battery (significant power savings)
          CPU_BOOST_ON_AC = 1;
          CPU_BOOST_ON_BAT = 0;

          # PCIe power management
          PCIE_ASPM_ON_AC = "default";
          PCIE_ASPM_ON_BAT = "powersupersave";

          # Runtime PM for PCI devices
          RUNTIME_PM_ON_AC = "auto";
          RUNTIME_PM_ON_BAT = "auto";

          # USB autosuspend
          USB_AUTOSUSPEND = 1;

          # SATA/NVMe power management
          SATA_LINKPWR_ON_AC = "med_power_with_dipm";
          SATA_LINKPWR_ON_BAT = "min_power";
          AHCI_RUNTIME_PM_ON_AC = "auto";
          AHCI_RUNTIME_PM_ON_BAT = "auto";

          # WiFi power saving
          WIFI_PWR_ON_AC = "off";
          WIFI_PWR_ON_BAT = "on";

          # Sound power saving
          SOUND_POWER_SAVE_ON_AC = 0;
          SOUND_POWER_SAVE_ON_BAT = 1;
          SOUND_POWER_SAVE_CONTROLLER = "Y";
        }

        (mkIf (config.power-management.cpuVendor == "intel") {
          # Intel P-State/HWP energy policy
          CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
          CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        })

        (mkIf (config.power-management.cpuVendor == "amd") {
          # AMD P-State energy policy and platform profile
          CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
          CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
          PLATFORM_PROFILE_ON_AC = "balanced";
          PLATFORM_PROFILE_ON_BAT = "low-power";
        })

        (mkIf (config.power-management.gpuVendor == "amd") {
          AMDGPU_POWER_DPM_STATE_ON_AC = "balanced";
          AMDGPU_POWER_DPM_STATE_ON_BAT = "battery";
          AMDGPU_DPM_PERF_LEVEL_ON_AC = "auto";
          AMDGPU_DPM_PERF_LEVEL_ON_BAT = "low";
        })
      ];
    };
  };
}
