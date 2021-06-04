{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption;
  inherit (lib.types) nullOr str;

  mkDefaultValue = description:
    mkOption {
      type = nullOr str;
      default = null;
      description = description;
    };

in {
  options.eth.defaults = {
    browser = mkDefaultValue "Default browser.";
    terminal = mkDefaultValue "Default terminal emulator.";
  };

  config = { };
}
