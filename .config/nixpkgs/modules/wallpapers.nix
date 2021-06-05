{ config, lib, pkgs, ... }:
let
  inherit (lib) escapeShellArg mkEnableOption mkIf mkOption;
  inherit (lib.types) str;
  inherit (pkgs) writeShellScript;

  cfg = config.eth.gui.wallpapers;

  dwellSeconds = 1;

  set_rotating_wallpaper = writeShellScript "wl-rotate-wallpaper" ''

    # Fail on unset variables, but allow exceptions,
    # because pidof & kill will fail if there's only 1 swaybg.
    set -u

    # swaybg only projects an image while it is running,
    # so we need to keep the old one alive for a time.
    # we do this by sleeping for a dwell period.
    while true; do
        # Gather existing swaybg instances.
        pids="$(pidof swaybg)"

        # Create our new one.
        ${pkgs.swaybg}/bin/swaybg \
            --image "$(find ${
              escapeShellArg cfg.directory
            } -type f | shuf -n1)" \
            --mode fill &

        # Wait for our new one to start.
        sleep ${toString dwellSeconds}

        # Kill all the old ones.
        kill $pids

        # Wait.
        sleep ${toString cfg.refreshPeriod}
    done
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

  config = mkIf cfg.enable {
    assertions = [{
      assertion = config.eth.gui.enable;
      message =
        "Must enable GUI (eth.gui.enable) to enable wallpapers (eth.gui.wallpapers.enable).";
    }];

    systemd.user.services.rotate-wallpaper = {
      Unit = {
        Description = "Set wallpaper";
        PartOf = cfg.systemdTarget;
        Requires = cfg.systemdTarget;
        After = cfg.systemdTarget;
      };
      Service = { ExecStart = "${set_rotating_wallpaper}"; };
      Install = { WantedBy = [ cfg.systemdTarget ]; };
    };
  };
}
