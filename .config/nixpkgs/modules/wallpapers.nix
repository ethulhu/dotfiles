{ config, lib, pkgs, ... }:
let
  inherit (lib) escapeShellArg mkEnableOption mkIf mkOption;
  inherit (lib.types) str;
  inherit (pkgs) writeShellScript;

  cfg = config.eth.gui.wallpapers;

  set_random_wallpaper = writeShellScript "wl-rotate-wallpaper" ''
    set -eu

    ${pkgs.pywal}/bin/wal \
      --saturate 0.4 \
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
