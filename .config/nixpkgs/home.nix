{ pkgs, config, ... }:

let
  inherit (pkgs) lib;
  inherit (builtins) readFile;

  hostname = readFile /etc/hostname;

  mozilla = import (fetchTarball
    "https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz");

  devPkgs = with pkgs; [
    entr
    gitAndTools.tig
    goimports
    html-tidy
    imagemagick
    jq
    latest.rustChannels.stable.rust
    nix-prefetch-git
    nixfmt
    p7zip
    pre-commit
    python3
    screen
    unrar
  ];

  guiPkgs = with pkgs; [
    brightnessctl
    chromium
    eidolon
    feh
    font-awesome
    mupdf
    pavucontrol
    powerline-fonts
    ripcord
    vlc
    wl-clipboard
  ];

in {
  nixpkgs.overlays = [ mozilla ];

  home.stateVersion = "20.03";

  home.packages = with pkgs;
    [
      ag
      direnv
      dnsutils
      file
      go
      htop
      iotop
      killall
      moreutils
      mosh
      mosquitto
      mu
      newsboat
      nixops
      reuse
      rlwrap
      scim
      tmux
      unzip
      wget
      whois
      zip
    ] ++ devPkgs ++ guiPkgs;

  programs.firefox = { enable = true; };

  programs.alacritty = {
    enable = true;
    settings = { env.TERM = "xterm-256color"; };
  };

  programs.mpv = { enable = true; };

  services.redshift = {
    enable = true;
    package = pkgs.redshift-wlr;
    latitude = 51.5;
    longitude = -0.1;
  };

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
            format = "{barchart} {utilization}%";
          }
          {
            block = "battery";
            interval = 10;
            format = "{percentage}% {time}";
          }
          {
            block = "time";
            interval = 60;
            format = "%a %d/%m %R";
          }
        ];
      };
    };
  };

  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = "Mod4";
      terminal = if hostname == "chibi" then "alacritty" else "urxvt";
      output = let
        chibi = { "eDP-1" = { transform = "90"; }; };
        kittencake = { };
      in if hostname == "chibi" then chibi else kittencake;
      input = let
        keyboard = {
          xkb_layout = "us";
          xkb_variant = "colemak";
          xkb_options = "caps:escape";
        };
        kittencake = {
          "type:keyboard" = keyboard;
          "type:touchpad" = { natural_scroll = "enabled"; };
        };
        chibi = {
          "type:keyboard" = keyboard;
          "type:touch" = { calibration_matrix = "0 1 0 -1 0 1"; };
        };
      in if hostname == "chibi" then chibi else kittencake;
      keybindings = let
        inherit (config.wayland.windowManager.sway.config)
          menu modifier terminal;
        brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
      in lib.mkOptionDefault {
        "${modifier}+Return" = "exec ${terminal}";
        "${modifier}+Shift+c" = "kill";
        "${modifier}+Shift+q" = ''
          exec swaynag \
              --type warning \
              --message 'Exit sway? This will end your Wayland session.' \
              --button 'Yes, exit sway' 'swaymsg exit' \
              --dismiss-button 'Cancel'
        '';
        "${modifier}+Shift+r" = "reload";
        "${modifier}+p" = "exec ${menu}";
        XF86MonBrightnessDown = "exec ${brightnessctl} set 5%-";
        XF86MonBrightnessUp = "exec ${brightnessctl} set +5%";

        # NB: This requires setting:
        #
        #   services.logind.extraConfig = "HandlePowerKey=ignore";
        #
        # in /etc/nixos/configuration.nix.
        # TODO: Use systemd-inhibit instead.
        XF86PowerOff = ''
          exec swaynag \
              --type warning \
              --message 'Shutdown?' \
              --button 'Yes, shutdown' 'exec systemctl poweroff' \
              --dismiss-button 'Cancel'
        '';
      };
      bars = [{
        position = "top";
        colors = {
          statusline = "#ffffff";
          background = "#323232";
          inactiveWorkspace = {
            border = "#32323200";
            background = "#32323200";
            text = "#5c5c5c";
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
