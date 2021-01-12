function __wrap_fish_function --description 'Load a fish function from a file, giving it a new name, falling back to an alias if the function file does not exist.'
  argparse --name __wrap_fish_function 'n/name=' 'p/path=' 'f/fallback=' -- $argv
  or return

  if not set --query _flag_name _flag_path _flag_fallback
    echo "halp"
    return 1
  end

  if [ -f $_flag_path ]
    cat $_flag_path | sed -E "s/^function [^[:space:]]+ /function $_flag_name /" | source
  else
    alias $_flag_name $_flag_fallback
  end
end
