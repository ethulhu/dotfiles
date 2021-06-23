{ config, lib, pkgs, ... }:
let
  inherit (lib) escapeShellArg mkEnableOption mkIf mkOption;
  inherit (lib.types) str;
  inherit (pkgs) writeShellScript;

  cfg = config.eth.gui.wallpapers;
  guiCfg = config.eth.gui;

  set_random_wallpaper = writeShellScript "wl-rotate-wallpaper" ''
    set -eu

    readonly day_or_night="$(
      ${pkgs.sunwait}/bin/sunwait \
        poll \
        daylight \
        "${toString guiCfg.latitude}N" \
        "${toString guiCfg.longitude}E" \
      || true
    )"

    if [ "$day_or_night" = 'DAY' ]; then
      readonly light_or_dark="-l"
    else
      readonly light_or_dark=""
    fi

    ${pkgs.pywal}/bin/wal \
      --saturate 0.4 \
      "$light_or_dark" \
      -i ${escapeShellArg cfg.directory}
  '';

in {
  options.eth.gui.wallpapers = {
    enable = mkEnableOption "Whether to enable rotating wallpapers.";

    directory = mkOption {
      type = str;
      description = "Path to the wallpapers directory.";
    };

    refreshPeriod = mkOption {
      type = str;
      description = "How frequently to rotate the wallpaper.";
      example = "15s";
    };

    systemdTarget = mkOption {
      type = str;
      default = "sway-session.target";
      description = "Systemd target to bind to.";
    };
  };

  config = mkIf (config.eth.gui.enable && cfg.enable) {
    systemd.user.services.rotate-wallpaper = {
      Unit = {
        Description = "Set wallpaper";
        PartOf = cfg.systemdTarget;
        Requires = cfg.systemdTarget;
        After = cfg.systemdTarget;
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${set_random_wallpaper}";
      };
      Install = { WantedBy = [ cfg.systemdTarget ]; };
    };
    systemd.user.timers.rotate-wallpaper = {
      Unit = { Description = "Set wallpaper"; };
      Timer = {
        OnUnitActiveSec = cfg.refreshPeriod;
        Persistent = true;
      };
      Install = { WantedBy = [ "timers.target" ]; };
    };
  };
}
