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

  programs.mpv = { enable = true; };

  services.redshift = {
    enable = true;
    package = pkgs.redshift-wlr;
    latitude = 51.5;
    longitude = -0.1;
  };
}
