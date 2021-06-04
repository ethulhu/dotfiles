{ pkgs, config, ... }:

let
  inherit (pkgs) lib;

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
    python38Packages.autopep8
    screen
    unrar
  ];

  guiPkgs = with pkgs; [
    brightnessctl
    chromium
    eidolon
    feh
    libreoffice
    mupdf
    ripcord
    vlc
    wl-clipboard
  ];

in {
  imports = [ ./home.window-manager.nix ];

  nixpkgs.overlays = [ mozilla ];

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
      ripgrep
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
      url-launcher = "firefox";

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

  programs.mpv = { enable = true; };

  services.redshift = {
    enable = true;
    package = pkgs.redshift-wlr;
    latitude = 51.5;
    longitude = -0.1;
  };
}
