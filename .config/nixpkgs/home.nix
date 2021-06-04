{ pkgs, config, ... }:

let
  inherit (pkgs) lib;

  select = import ./select.nix;

  mozilla = import (fetchTarball
    "https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz");

in {
  imports = [ ./home.defaults.nix ./home.gui.nix ];

  eth = {
    defaults = {
      terminal = select.byHostname {
        chibi = "${pkgs.alacritty}/bin/alacritty";
        kittencake = "${pkgs.rxvt-unicode}/bin/urxvt";
      };
      browser = "firefox";
    };
    gui = {
      enable = true;
      extraPackages = with pkgs; [
        appimage-run
        brightnessctl
        firefox
        chromium
        eidolon
        feh
        libreoffice
        mpv
        mupdf
        ripcord
        vlc
      ];
    };
  };

  nixpkgs.overlays = [ mozilla ];

  home.stateVersion = "20.03";

  home.packages = with pkgs; [
    ag
    direnv
    dnsutils
    entr
    file
    gitAndTools.tig
    go
    goimports
    html-tidy
    htop
    imagemagick
    iotop
    jq
    killall
    latest.rustChannels.stable.rust
    moreutils
    mosh
    mosquitto
    mu
    newsboat
    nix-prefetch-git
    nixfmt
    nixops
    p7zip
    pre-commit
    python3
    python38Packages.autopep8
    reuse
    ripgrep
    rlwrap
    scim
    screen
    tmux
    unrar
    unzip
    wget
    whois
    zip
  ];
}
