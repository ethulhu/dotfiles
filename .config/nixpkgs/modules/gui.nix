{ config, lib, pkgs, ... }:
let
  inherit (builtins) listToAttrs map;
  inherit (lib) mkEnableOption mkIf mkOption mkOptionDefault optionalString;
  inherit (lib.types) enum float listOf package str;
  inherit (pkgs) writeShellScript writeText;
  inherit (pkgs.eth) select;

  cfg = config.eth.gui;

  xdgMime = mimes: app:
    listToAttrs (map (mime: {
      name = mime;
      value = app;
    }) mimes);

  mimes = {
    browser = [ "text/html" "x-scheme-handler/http" "x-scheme-handler/https" ];
  };

  sway = {
    inherit (config.wayland.windowManager.sway.config) modifier;

    input = let
      keyboard = {
        xkb_layout = "us";
        xkb_variant = "colemak";
        xkb_options = "caps:escape";
      };
      mouse = { natural_scroll = "enabled"; };

      # A custom keymap to remap the X201's |\ key to `~, like a Mac.
      thinkpad_keyboard = writeText "thinkpad_colemak.xkb" ''
        xkb_keymap {
          xkb_keycodes  { include "evdev+aliases(qwerty)" };
          xkb_types     { include "complete" };
          xkb_compat    { include "complete" };
          xkb_symbols   { include "pc+us(colemak)+inet(evdev)+capslock(escape)"
            replace key <LSGT> { [ grave, asciitilde ] };
          };
        };
      '';
    in select.byHostname {
      kittencake = {
        "1:1:AT_Translated_Set_2_keyboard".xkb_file = "${thinkpad_keyboard}";
        "type:keyboard" = keyboard;
        "type:pointer" = mouse;
        "type:touchpad" = { natural_scroll = "enabled"; };
      };
      chibi = {
        "type:keyboard" = keyboard;
        "type:pointer" = mouse;
        "type:touch" = { calibration_matrix = "0 1 0 -1 0 1"; };
      };
    };

    output = select.byHostname {
      chibi = { "eDP-1" = { transform = "90"; }; };
      kittencake = {
        "Lenovo Group Limited 0x4011 0x00000000" = { position = "0 250"; };
        "Samsung Electric Company SyncMaster 9CQ857691B" = {
          position = "1280 0";
        };
      };
    };

    menu = "${writeShellScript "dmenu" ''
      set -e

      readonly colors_sh="$HOME/.cache/wal/colors.sh"

      if [ -f "$colors_sh" ]; then
        source "$colors_sh"
        dmenu() {
          ${pkgs.dmenu}/bin/dmenu \
            -nb "$color0" \
            -nf "$color15" \
            -sb "$color1" \
            -sf "$color15"
        }
      else
        dmenu() {
          ${pkgs.dmenu}/bin/dmenu
        }
      fi

      ${pkgs.dmenu}/bin/dmenu_path \
        | dmenu \
        | ${pkgs.findutils}/bin/xargs swaymsg exec --
    ''}";

    commands = let
      inherit (config.wayland.windowManager.sway.config) menu;

      brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
    in {

      brightness_up = "exec ${brightnessctl} set 5%+";
      brightness_down = "exec ${brightnessctl} set 5%-";

      volume_up = "exec ${pkgs.alsaUtils}/bin/amixer -q set Master 5%+ unmute";
      volume_down =
        "exec ${pkgs.alsaUtils}/bin/amixer -q set Master 5%- unmute";
      mute = "exec ${pkgs.alsaUtils}/bin/amixer -q set Master toggle";

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

    pywalTheme = let
      bar = bar: attr:
        { border, background, text }:
        "bar ${bar} colors ${attr} ${border} ${background} ${text}";
      client = class:
        { border, background, text, indicator ? "", childBorder ? "" }:
        "client.${class} ${border} ${background} ${text} ${indicator} ${childBorder}";
    in ''
      include "$HOME/.cache/wal/colors-sway"
      output * background $wallpaper fill
      ${client "focused" {
        border = "$color0";
        background = "$background";
        text = "$foreground";
        indicator = "$color7";
        childBorder = "$color2";
      }}
      bar main colors background $background
      bar main colors statusline $foreground
      bar main colors separator $foreground
      ${bar "main" "active_workspace" {
        border = "$color0";
        background = "$color2";
        text = "$background";
      }}
      ${bar "main" "focused_workspace" {
        border = "$color0";
        background = "$color2";
        text = "$background";
      }}
      ${bar "main" "inactive_workspace" {
        border = "$color0";
        background = "$background";
        text = "$foreground";
      }}
      ${bar "main" "urgent_workspace" {
        border = "$color0";
        background = "$color7";
        text = "$background";
      }}
    '';
  };

in {
  options.eth.gui = {
    enable = mkEnableOption
      "Whether to enable the Window Manager & associated tooling";

    browser = mkOption {
      type = enum [ "firefox" "luakit" ];
      description = "Default browser.";
    };

    terminal = mkOption {
      type = str;
      description = "Default terminal emulator.";
    };

    latitude = mkOption {
      type = float;
      description = "Latitude, between -90.0 & 90.0";
    };
    longitude = mkOption {
      type = float;
      description = "Longitude, between -180.0 & 180.0";
    };

    extraPackages = mkOption {
      type = listOf package;
      default = [ ];
      description = "Extra packages to install when GUI is enabled.";
    };
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs;
      [ font-awesome powerline-fonts wdisplays wl-clipboard ]
      ++ cfg.extraPackages;

    # This is needed for i3status-rust, for powerline-fonts and fonts-awesome.
    fonts.fontconfig.enable = true;

    services.redshift = {
      enable = true;
      package = pkgs.redshift-wlr;
      latitude = cfg.latitude;
      longitude = cfg.longitude;
    };

    xdg = {
      mimeApps = {
        enable = true;
        associations.added = xdgMime mimes.browser "${cfg.browser}.desktop";
        defaultApplications = xdgMime mimes.browser "${cfg.browser}.desktop";
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
                month_day = "%d";
                hours_minutes = "%R";
              in "${weekday} wk ${week_number}, ${short_month} ${month_day} ${hours_minutes}";
            }
          ];
        };
      };
    };

    wayland.windowManager.sway = {
      enable = true;
      extraConfig = ''
        ${optionalString cfg.wallpapers.enable sway.pywalTheme}
      '';
      config = {
        modifier = "Mod4";
        terminal = cfg.terminal;
        menu = sway.menu;
        output = sway.output;
        input = sway.input;
        keybindings = mkOptionDefault {
          "${sway.modifier}+Return" = sway.commands.launch_terminal;
          "${sway.modifier}+Alt+3" = sway.commands.take_screenshot;
          "${sway.modifier}+Shift+c" = sway.commands.kill_window;
          "${sway.modifier}+Shift+q" = sway.commands.confirm_logout;
          "${sway.modifier}+Shift+r" = sway.commands.reload_sway;
          "${sway.modifier}+p" = sway.commands.launch_menu;

          "${sway.modifier}+Shift+Left" = "move workspace to output left";
          "${sway.modifier}+Shift+Right" = "move workspace to output right";
          "${sway.modifier}+Shift+Up" = "move workspace to output up";
          "${sway.modifier}+Shift+Down" = "move workspace to output down";

          "${sway.modifier}+Shift+h" = "move workspace to output left";
          "${sway.modifier}+Shift+l" = "move workspace to output right";
          "${sway.modifier}+Shift+k" = "move workspace to output up";
          "${sway.modifier}+Shift+j" = "move workspace to output down";

          XF86MonBrightnessUp = sway.commands.brightness_up;
          XF86MonBrightnessDown = sway.commands.brightness_down;

          XF86AudioRaiseVolume = sway.commands.volume_up;
          XF86AudioLowerVolume = sway.commands.volume_down;
          XF86AudioMute = sway.commands.mute;

          # NB: This requires setting:
          #
          #   services.logind.extraConfig = "HandlePowerKey=ignore";
          #
          # in /etc/nixos/configuration.nix.
          # TODO: Use systemd-inhibit instead.
          XF86PowerOff = sway.commands.confirm_shutdown;
        };
        bars = [{
          id = "main";
          position = "top";
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
