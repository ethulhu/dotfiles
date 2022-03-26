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
    p7zip
    plan9port
    pre-commit
    rustc
    rustc.doc
    scim
    unrar
    unzip
    zip
  ];

  london = {
    latitude = 51.5;
    longitude = -0.1;
  };

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

  # Enable the lorri nix-env / direnv daemon.
  services.lorri.enable = true;

  # Mount USB disks under /run/media.
  services.udiskie.enable = true;

  eth = {
    gui = {
      enable = select.byHostname {
        __default__ = false;
        chibi = true;
        kittencake = true;
      };
      browser = "luakit";
      terminal = select.byHostname {
        chibi = "${pkgs.alacritty}/bin/alacritty";
        kittencake = "${pkgs.rxvt-unicode}/bin/urxvt";
      };
      latitude = london.latitude;
      longitude = london.longitude;
      wallpapers = {
        enable = true;
        directory = "${getEnv "HOME"}/walls";
        refreshPeriod = "1h";
      };
      extraPackages = with pkgs; [
        appimage-run
        brightnessctl
        chromium
        eidolon
        feh
        firefox
        libreoffice
        luaformatter
        luakit
        mpv
        mupdf
        ripcord
        vivaldi-widevine # Required DRM plugin for Chromium.
        vlc
        wev
      ];
    };
  };

  home.stateVersion = "20.03";
}
