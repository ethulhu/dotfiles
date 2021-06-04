let
  inherit (builtins) getAttr hasAttr head match readFile throw;

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
        getAttrOrDefault "__default__" set (throw "missing __default__ value");
    in getAttrOrDefault hostname set default;
}
