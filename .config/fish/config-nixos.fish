# NixOS-specific configuration.

set -x PATH ~/.local/bin/linux $PATH

function __fish_command_not_found_handler --on-event fish_command_not_found --argument-names command
  set -l db '/nix/var/nix/profiles/per-user/root/channels/nixos/programs.sqlite'
  if [ ! -f $db ]
    __fish_default_command_not_found_handler $argv
  end

  function path_of_package --argument-names package
    nix-build --no-out-link '<nixpkgs>' --attr $package
  end

  set -l sqlite3 (path_of_package sqlite)/bin/sqlite3

  set -l num_packages (command $sqlite3 $db "select count (distinct package) from Programs where name = '$command'")
  set -l packages (command $sqlite3 $db "select distinct package from Programs where name = '$command'")

  __fish_default_command_not_found_handler $argv
  switch $num_packages
    case 0

    case 1
      switch (read --prompt-str="It is provided by package $packages; add it to PATH? [y/N] " --nchars=1)
        case y
          set -x PATH (path_of_package $packages)/bin $PATH
          commandline --replace "$argv"
      end

    case '*'
      echo "It is provided by Nix packages:"
      for package in $packages
        echo "  $package"
      end
  end
end
