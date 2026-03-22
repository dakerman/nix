{
  config,
  lib,
  ...
}:
with lib;

let
  cfg = config.speaker-eq;

  # Parametric EQ bands for thin laptop speakers.
  # Adapted from ThinkPad Z13 Gen 1 profile.
  # Boost low-mids for warmth, cut upper-mids to reduce harshness.
  # PipeWire duplicates this mono graph for each channel automatically.
  bands = [
    { name = "low_shelf"; label = "bq_lowshelf"; freq = 120;  q = 0.9; gain = 2.0;  } # Add warmth
    { name = "eq_160";    label = "bq_peaking";  freq = 160;  q = 1.6; gain = 2.6;  } # Add body
    { name = "eq_200";    label = "bq_peaking";  freq = 200;  q = 1.6; gain = 1.4;  } # Low-mid fill
    { name = "eq_300";    label = "bq_peaking";  freq = 300;  q = 1.6; gain = 0.5;  } # Slight fill
    { name = "eq_500";    label = "bq_peaking";  freq = 500;  q = 1.6; gain = -1.3; } # Reduce boxiness
    { name = "eq_800";    label = "bq_peaking";  freq = 800;  q = 1.6; gain = -3.7; } # Cut harshness
    { name = "eq_1k";     label = "bq_peaking";  freq = 1000; q = 1.6; gain = -4.1; } # Cut metallic ring
    { name = "eq_2k";     label = "bq_peaking";  freq = 2000; q = 1.6; gain = -3.2; } # Reduce shrillness
    { name = "eq_4k";     label = "bq_peaking";  freq = 4000; q = 1.6; gain = -1.7; } # Tame brightness
  ];

  mkNode = band: {
    type = "builtin";
    name = band.name;
    label = band.label;
    control = {
      "Freq" = band.freq;
      "Q" = band.q;
      "Gain" = band.gain;
    };
  };

  mkLink = i: {
    output = "${(elemAt bands i).name}:Out";
    input = "${(elemAt bands (i + 1)).name}:In";
  };
in
{
  options.speaker-eq = {
    enable = mkEnableOption "PipeWire parametric EQ for laptop speakers";
  };

  config = mkIf cfg.enable {
    services.pipewire.extraConfig.pipewire."99-speaker-eq" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";
          args = {
            "node.description" = "Speaker EQ";
            "media.name" = "Speaker EQ";
            "filter.graph" = {
              nodes = map mkNode bands;
              links = genList mkLink (length bands - 1);
            };
            "capture.props" = {
              "node.name" = "effect_input.speaker_eq";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
            };
            "playback.props" = {
              "node.name" = "effect_output.speaker_eq";
              "node.passive" = true;
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
            };
          };
        }
      ];
    };
  };
}
