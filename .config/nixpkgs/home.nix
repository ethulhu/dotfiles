{ pkgs, config, ... }:

let
  inherit (pkgs) lib;

  unstableTarball = fetchTarball
    "https://github.com/NixOS/nixpkgs-channels/archive/nixpkgs-unstable.tar.gz";

  mozilla = import (fetchTarball
    "https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz");

  unstable = self: super: {
    pre-commit = (import unstableTarball { }).pre-commit;
    ripcord = (import unstableTarball { }).ripcord;
  };

  devPkgs = with pkgs; [
    clang
    entr
    gitAndTools.tig
    goimports
    html-tidy
    imagemagick
    jq
    latest.rustChannels.stable.rust
    nix-prefetch-git
    pre-commit
    python3
    screen
  ];

  guiPkgs = with pkgs; [
    chromium
    feh
    libreoffice
    font-awesome
    mupdf
    renpy
    powerline-fonts
    ripcord
    vlc
    wl-clipboard
  ];

in {
  nixpkgs.overlays = [ mozilla unstable ];

  home.stateVersion = "20.03";

  home.packages = with pkgs;
    [
      ag
      appimage-run
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
      terminal = "alacritty";
      output = { "eDP-1" = { transform = "90"; }; };
      input = {
        "type:keyboard" = {
          xkb_layout = "us";
          xkb_variant = "colemak";
          xkb_options = "caps:escape";
        };
        "type:touch" = { calibration_matrix = "0 1 0 -1 0 1"; };
      };
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
              --message 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' \
              --button 'Yes, exit sway' 'swaymsg exit'
        '';
        "${modifier}+Shift+r" = "reload";
        "${modifier}+p" = "exec ${menu}";
        XF86MonBrightnessDown = "exec ${brightnessctl} set 5%-";
        XF86MonBrightnessUp = "exec ${brightnessctl} set +5%";
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
