{ pkgs, config, ... }:
let
  inherit (builtins) head match readFile;
  inherit (pkgs) lib;

  trimSpace = s:
    let m = match "[[:space:]]*([^[:space:]]+)[[:space:]]*" s;
    in (head m);
  hostname = trimSpace (readFile /etc/hostname);

  sway = {
    inherit (config.wayland.windowManager.sway.config) modifier;

    terminal = {
      chibi = "alacritty";
      kittencake = "urxvt";
    };

    input = let
      keyboard = {
        xkb_layout = "us";
        xkb_variant = "colemak";
        xkb_options = "caps:escape";
      };
    in {
      kittencake = {
        "type:keyboard" = keyboard;
        "type:touchpad" = { natural_scroll = "enabled"; };
      };
      chibi = {
        "type:keyboard" = keyboard;
        "type:touch" = { calibration_matrix = "0 1 0 -1 0 1"; };
      };
    };

    output = {
      chibi = { "eDP-1" = { transform = "90"; }; };
      kittencake = { };
    };

    commands = let
      inherit (config.wayland.windowManager.sway.config) menu modifier terminal;
      brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
    in {

      brightness_up = "exec ${brightnessctl} set 5%+";
      brightness_down = "exec ${brightnessctl} set 5%-";

      launch_terminal = "exec ${terminal}";
      launch_menu = "exec ${menu}";

      reload_sway = "reload";
      kill_window = "kill";

      confirm_logout = ''
        exec swaynag \
            --type warning \
            --message 'Exit sway? This will end your Wayland session.' \
            --button 'Yes, exit sway' 'swaymsg exit' \
            --dismiss-button 'Cancel'
      '';
      confirm_shutdown = ''
        exec swaynag \
            --type warning \
            --message 'Shutdown?' \
            --button 'Yes, shutdown' 'exec systemctl poweroff' \
            --dismiss-button 'Cancel'
      '';
    };
  };

in {

  home.packages = with pkgs; [ font-awesome powerline-fonts ];

  # This is needed for i3status-rust,
  # for pkgs.powerline-fonts and pkgs.fonts-awesome.
  fonts.fontconfig.enable = true;

  programs.i3status-rust = {
    enable = true;
    bars = {
      default = {
        icons = "awesome5";
        theme = "gruvbox-dark";
        blocks = [
          {
            block = "net";
            device = "wlp2s0";
            format = "{signal_strength}|{ssid}|{ip}";
            interval = 5;
          }
          { block = "sound"; }
          {
            block = "cpu";
            interval = 1;
            format = "{barchart} {utilization}";
          }
          {
            block = "battery";
            interval = 10;
            format = "{percentage} {time}";
          }
          {
            block = "time";
            interval = 60;
            format = let
              weekday = "%a";
              week_number = "%V";
              short_month = "%b";
              month_day = "%m";
              hours_minutes = "%R";
            in "${weekday} wk ${week_number}, ${short_month} ${month_day} ${hours_minutes}";
          }
        ];
      };
    };
  };

  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = "Mod4";
      terminal = sway.terminal.${hostname};
      output = sway.output.${hostname};
      input = sway.input.${hostname};
      keybindings = lib.mkOptionDefault {
        "${sway.modifier}+Return" = sway.commands.launch_terminal;
        "${sway.modifier}+Shift+c" = sway.commands.kill_window;
        "${sway.modifier}+Shift+q" = sway.commands.confirm_logout;
        "${sway.modifier}+Shift+r" = sway.commands.reload_sway;
        "${sway.modifier}+p" = sway.commands.launch_menu;
        XF86MonBrightnessUp = sway.commands.brightness_up;
        XF86MonBrightnessDown = sway.commands.brightness_down;

        # NB: This requires setting:
        #
        #   services.logind.extraConfig = "HandlePowerKey=ignore";
        #
        # in /etc/nixos/configuration.nix.
        # TODO: Use systemd-inhibit instead.
        XF86PowerOff = sway.commands.confirm_shutdown;
      };
      bars = [{
        position = "top";
        colors = {
          background = "#3c3836";
          separator = "#666666";
          statusline = "#ebdbb2";
          focusedWorkspace = {
            background = "#458588";
            border = "#458588";
            text = "#ebdbb2";
          };
          activeWorkspace = {
            background = "#83a598";
            border = "#83a598";
            text = "#ebdbb2";
          };
          inactiveWorkspace = {
            background = "#504945";
            border = "#504945";
            text = "#ebdbb2";
          };
        };
        statusCommand =
          "${config.programs.i3status-rust.package}/bin/i3status-rs ~/.config/i3status-rust/config-default.toml";
      }];
      startup = [{
        command = ''
          swayidle -w \
                   timeout 300 'swaylock -f -c 000000' \
                   timeout 600 'swaymsg "output * dpms off"' \
                        resume 'swaymsg "output * dpms on"' \
                   before-sleep 'swaylock -f -c 000000'
        '';
      }];
    };
  };
}
