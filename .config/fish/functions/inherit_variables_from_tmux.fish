set -l function_name (basename (status filename) .fish)

function $function_name --description 'Inherit environment variables from a tmux session.'

  set -l variables (tmux show-environment)

  for name in $argv
    if set -l variable (string replace --filter "$name=" '' -- $variables)
      set --export $name $variable
    else
      set --erase $name
    end
  end
end
