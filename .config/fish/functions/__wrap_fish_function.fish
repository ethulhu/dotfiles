set --local function_name (basename (status filename) .fish)

function $function_name --description 'Load a fish function from a file, giving it a new name, falling back to an alias if the function file does not exist.'

  argparse 'n/name=' 'p/path=' 'f/fallback=' -- $argv
  or return 1

  if not set --query _flag_name _flag_path _flag_fallback
    echo (status function)': Missing flags!'
    return 1
  end

  if [ -f $_flag_path ]
    cat $_flag_path | string replace --regex '^function [^[:space:]]+ ' "function $_flag_name " | source
  else
    alias $_flag_name $_flag_fallback
  end
end
