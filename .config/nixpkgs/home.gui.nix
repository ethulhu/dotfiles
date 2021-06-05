{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf mkOption mkOptionDefault;
  inherit (lib.types) enum listOf package str;

  select = import ./select.nix;

  cfg = config.eth.gui;

  sway = {
    inherit (config.wayland.windowManager.sway.config) modifier;

    input = let
      keyboard = {
        xkb_layout = "us";
        xkb_variant = "colemak";
        xkb_options = "caps:escape";
      };
    in select.byHostname {
      kittencake = {
        "type:keyboard" = keyboard;
        "type:touchpad" = { natural_scroll = "enabled"; };
      };
      chibi = {
        "type:keyboard" = keyboard;
        "type:touch" = { calibration_matrix = "0 1 0 -1 0 1"; };
      };
    };

    output = select.byHostname {
      chibi = { "eDP-1" = { transform = "90"; }; };
      kittencake = { };
    };

    commands = let
      inherit (config.wayland.windowManager.sway.config) menu;

      brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
    in {

      brightness_up = "exec ${brightnessctl} set 5%+";
      brightness_down = "exec ${brightnessctl} set 5%-";

      launch_terminal = "exec ${cfg.terminal}";
      launch_menu = "exec ${menu}";

      reload_sway = "reload";
      kill_window = "kill";

      take_screenshot = "exec ${pkgs.grim}/bin/grim";

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

      reload_xrdb = "${pkgs.xorg.xrdb}/bin/xrdb -merge $HOME/.Xresources";
    };
  };

in {
  options.eth.gui = {
    enable = mkEnableOption
      "Whether to enable the Window Manager & associated tooling";

    browser = mkOption {
      type = enum [ "firefox" ];
      description = "Default browser.";
    };

    terminal = mkOption {
      type = str;
      description = "Default terminal emulator.";
    };

    extraPackages = mkOption {
      type = listOf package;
      default = [ ];
      description = "Extra packages to install when GUI is enabled.";
    };
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs;
      [ font-awesome powerline-fonts wl-clipboard ] ++ cfg.extraPackages;

    # This is needed for i3status-rust, for powerline-fonts and fonts-awesome.
    fonts.fontconfig.enable = true;

    services.redshift = {
      enable = true;
      package = pkgs.redshift-wlr;
      latitude = 51.5;
      longitude = -0.1;
    };

    # Terminal emuators.

    programs.alacritty = {
      enable = true;
      settings = { env.TERM = "xterm-256color"; };
    };

    # https://addy-dclxvi.github.io/post/configuring-urxvt/.
    programs.urxvt = {
      enable = true;
      fonts = [ "xft:monospace:size=10" ];
      scroll.bar.enable = true;
      keybindings = {
        "Shift-Control-C" = "eval:selection_to_clipboard";
        "Shift-Control-V" = "eval:paste_clipboard";
        "Shift-M-C" = "perl:clipboard:copy";
        "Shift-M-V" = "perl:clipboard:paste";
      };
      extraConfig = {
        "clipboard.autocopy" = "True";
        "matcher.button" = "1";
        termName = "xterm-256color";
        perl-ext-common = "default,matcher,clipboard";
        underlineURLs = "True";
        url-launcher = cfg.browser;

        # special
        foreground = "#93a1a1";
        background = "#141c21";
        cursorColor = "#afbfbf";

        # black
        color0 = "#263640";
        color8 = "#4a697d";

        # red
        color1 = "#d12f2c";
        color9 = "#fa3935";

        # green
        color2 = "#819400";
        color10 = "#a4bd00";

        # yellow
        color3 = "#b08500";
        color11 = "#d9a400";

        # blue
        color4 = "#2587cc";
        color12 = "#2ca2f5";

        # magenta
        color5 = "#696ebf";
        color13 = "#8086e8";

        # cyan
        color6 = "#289c93";
        color14 = "#33c5ba";

        # white
        color7 = "#bfbaac";
        color15 = "#fdf6e3";
      };
    };

    # Window manager.

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
        terminal = cfg.terminal;
        output = sway.output;
        input = sway.input;
        keybindings = mkOptionDefault {
          "${sway.modifier}+Return" = sway.commands.launch_terminal;
          "${sway.modifier}+Shift+3" = sway.commands.take_screenshot;
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
        startup = [
          {
            command = ''
              swayidle -w \
                       timeout 300 'swaylock -f -c 000000' \
                       timeout 600 'swaymsg "output * dpms off"' \
                            resume 'swaymsg "output * dpms on"' \
                       before-sleep 'swaylock -f -c 000000'
            '';
          }
          {
            command = sway.commands.reload_xrdb;
            always = true;
          }
        ];
      };
    };
  };
}
