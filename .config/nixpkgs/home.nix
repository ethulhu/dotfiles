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
    mupdf
    renpy
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
      in lib.mkOptionDefault {
        "${modifier}+Return" = "exec ${terminal}";
        "${modifier}+Shift+c" = "kill";
        "${modifier}+Shift+q" =
          "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";
        "${modifier}+Shift+r" = "reload";
        "${modifier}+p" = "exec ${menu}";
        XF86MonBrightnessDown = "exec brightnessctl set 5%-";
        XF86MonBrightnessUp = "exec brightnessctl set +5%";
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
          "i3status-rs /home/eth/.config/i3status-rust/config.toml";
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
