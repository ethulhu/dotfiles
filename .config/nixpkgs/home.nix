{ pkgs, config, ... }:

let
  inherit (builtins) getEnv;

  select = import ./select.nix;

  mediaPackages = with pkgs; [
    exiftool
    ffmpeg
    id3v2
    imagemagick
    mkvtoolnix-cli
    youtube-dl
  ];

  developmentPackages = with pkgs; [
    go
    goimports
    jq
    mosquitto
    mu
    newsboat
    nixops
    p7zip
    pre-commit
    rustc
    rustc.doc
    scim
    unrar
    unzip
    zip
  ];

in {
  imports = [ ./modules/default.nix ];

  nixpkgs.overlays = [ (self: super: { eth = { inherit select; }; }) ];

  home.packages = with pkgs;
    [
      direnv
      dnsutils
      entr
      file
      git
      gitAndTools.tig
      html-tidy
      htop
      iotop
      killall
      moreutils
      mosh
      nix-prefetch-git
      nixfmt
      python3
      python38Packages.autopep8
      reuse
      ripgrep
      rlwrap
      screen
      tmux
      wget
      whois
    ] ++ (select.byHostname {
      __default__ = [ ];
      chibi = developmentPackages ++ mediaPackages;
      kittencake = developmentPackages ++ mediaPackages;
      valkyrie = developmentPackages ++ mediaPackages;
    });

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
      wallpapers = {
        enable = true;
        directory = "${getEnv "HOME"}/walls";
        refreshPeriod = "15s";
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
