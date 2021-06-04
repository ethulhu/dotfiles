{ pkgs, config, ... }:

let
  inherit (pkgs) lib;

  select = import ./select.nix;

in {
  imports = [ ./home.gui.nix ];

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
    rustc
    scim
    screen
    tmux
    unrar
    unzip
    wget
    whois
    zip
  ];

  eth = {
    gui = {
      enable = select.byHostname {
        __default__ = false;
        chibi = true;
        kittencake = true;
      };
      browser = "firefox";
      terminal = select.byHostname {
        chibi = "${pkgs.alacritty}/bin/alacritty";
        kittencake = "${pkgs.rxvt-unicode}/bin/urxvt";
      };
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

  home.stateVersion = "20.03";
}
