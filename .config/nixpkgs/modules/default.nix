{ ... }:
let
  inherit (builtins) attrNames filter map match readDir;

  readFiles = dir:
    let
      entries = readDir dir;
      filenames =
        filter (name: entries.${name} == "regular") (attrNames entries);
    in map (name: dir + "/${name}") filenames;

  isNix = f: (match ".*.nix" "${f}") != null;

in {
  require = filter (p: p != ./default.nix) (filter (isNix) (readFiles ./.));
}
