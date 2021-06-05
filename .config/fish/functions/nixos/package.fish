set --local function_name (basename (status filename) .fish)

function '__'$function_name'_install' \
    --description 'Add a package to the current fish_user_paths' \
    --argument-names package

    if set --local path (nix-build --no-out-link '<nixpkgs>' --attr $package)
        set --append fish_user_paths $path/bin
    end
end

function '__'$function_name'_uninstall' \
    --description 'Remove a package from the current fish_user_paths' \
    --argument-names package

    if set --local path (nix-build --no-out-link '<nixpkgs>' --attr $package)
        if set --local index (contains --index $path/bin $fish_user_paths)
            set --erase fish_user_paths[$index]
        end
    end
end

function '__'$function_name'_path' \
    --description 'Print the Nix store path of a package' \
    --argument-names package

    nix-build --no-out-link '<nixpkgs>' --attr $package
end

function '__'$function_name'_search' \
    --description 'Search for a matching package'

    nix search $argv
end

function $function_name \
    --description 'Manage Nixpkgs in the current shell' \
    --argument-names subcommand package

    set --local this (status function)

    if [ (count $argv) -lt 2 ]
        echo 'Usage:'
        echo '    '(status function)' <cmd> <package>'
        echo
        echo 'Description:'
        echo '    '(functions --details --verbose $this | tail -n1)
        echo
        echo 'Available commands:'

        set --local prefix '__'$this'_'
        for f in (functions --all | grep $prefix)
            echo '    '(string replace -- $prefix '' $f)'|'(functions --details --verbose $f | tail -n1)
        end | column -t -s'|'

        return 1
    end

    set --local subcommand_fn '__'(status function)"_$subcommand"
    if functions --query $subcommand_fn
        eval $subcommand_fn $argv[2..-1]
    else
        echo (status function)": Unknown command: $subcommand"
    end
end
