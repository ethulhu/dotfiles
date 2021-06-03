{ pkgs, ... }:

let
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

  programs.ssh = {
    enable = true;
    forwardAgent = true;
  };
}
