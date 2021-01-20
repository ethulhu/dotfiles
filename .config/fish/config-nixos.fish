# NixOS-specific configuration.

set --prepend PATH ~/.local/bin/linux

set --prepend fish_function_path ~/.config/fish/functions/nixos
set --prepend fish_complete_path ~/.config/fish/completions/nixos

function __fish_command_not_found_handler --on-event fish_command_not_found --argument-names command
    set -l db '/nix/var/nix/profiles/per-user/root/channels/nixos/programs.sqlite'
    if [ ! -f $db ]
        __fish_default_command_not_found_handler $argv
    end

    set -l sqlite3 (package path sqlite)/bin/sqlite3

    set -l num_packages (command $sqlite3 $db "select count (distinct package) from Programs where name = '$command'")
    set -l packages (command $sqlite3 $db "select distinct package from Programs where name = '$command'")

    __fish_default_command_not_found_handler $argv
    switch $num_packages
        case 0

        case 1
            switch (read --prompt-str="It is provided by package $packages; add it to PATH? [y/N] " --nchars=1)
                case y
                    package install $package
                    commandline --replace "$argv"
            end

        case '*'
            echo "It is provided by Nix packages:"
            for package in $packages
                echo "  $package"
            end
    end
end
