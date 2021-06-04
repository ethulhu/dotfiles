let
  inherit (builtins) abort getAttr hasAttr head match readFile;

  trimSpace = s:
    let m = match "[[:space:]]*([^[:space:]]+)[[:space:]]*" s;
    in (head m);

  hostname = trimSpace (readFile /etc/hostname);

  getAttrOrDefault = name: set: default:
    if hasAttr name set then getAttr name set else default;
in {
  byHostname = set:
    let
      default =
        getAttrOrDefault "_default" set (abort "missing _default value");
    in getAttrOrDefault hostname set default;
}
