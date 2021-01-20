set --local function_name (basename (status filename) .fish)

function $function_name --description 'Manage Nixpkgs in the current shell' --argument-names command package
  if [ (count $argv) -ne 2 ]
    echo 'Usage: '(status function)' <install|uninstall|path> <package>'
    echo
    echo 'Summary: Install or show the path of a Nixpkgs package.'
    return 1
  end

  switch $command
    case install
      if set --local path (nix-build --no-out-link '<nixpkgs>' --attr $package)
        set --append PATH $path/bin
      end

    case uninstall
      if set --local path (nix-build --no-out-link '<nixpkgs>' --attr $package)
        if set --local index (contains --index $path/bin $PATH)
          set --erase PATH[$index]
        end
      end

    case path
      nix-build --no-out-link '<nixpkgs>' --attr $package

    case '*'
      echo (status function)": Unknown command: $command"
  end
end
