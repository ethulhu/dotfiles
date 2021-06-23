{ config, lib, pkgs, ... }:
let
  inherit (builtins) getEnv;
  inherit (lib) mkIf optionals optionalString;

  guiCfg = config.eth.gui;
  wallpapersCfg = config.eth.gui.wallpapers;

in {
  config = mkIf guiCfg.enable {
    programs.alacritty = {
      enable = true;
      settings = {
        env.TERM = "xterm-256color";
        import = optionals wallpapersCfg.enable
          [ "~/.cache/wal/colors-alacritty.yml" ];
      };
    };

    # https://addy-dclxvi.github.io/post/configuring-urxvt/.
    programs.urxvt = {
      enable = true;
      fonts = [ "xft:monospace:size=10" ];
      scroll.bar.enable = true;
      iso14755 = false;
      keybindings = {
        "Shift-Control-C" = "eval:selection_to_clipboard";
        "Shift-Control-V" = "eval:paste_clipboard";
        "Shift-M-C" = "perl:clipboard:copy";
        "Shift-M-V" = "perl:clipboard:paste";
      };
      extraConfig = {
        iso14755_52 = false;
        "clipboard.autocopy" = "True";
        "matcher.button" = "1";
        termName = "xterm-256color";
        perl-ext-common = "default,matcher,clipboard";
        underlineURLs = "True";
        url-launcher = "xdg-open";
      };
    };

    xresources.extraConfig = optionalString wallpapersCfg.enable ''
      #include "${getEnv "HOME"}/.cache/wal/colors.Xresources"
      #include "${getEnv "HOME"}/.cache/wal/colors-urxvt.Xresources"
    '';
  };
}
