set --local function_name (basename (status filename) .fish)

function $function_name --description 'Inherit environment variables from a tmux session.'

  set --local variables (tmux show-environment)

  for name in $argv
    if set --local variable (string replace --filter "$name=" '' -- $variables)
      set --export $name $variable
    else
      set --erase $name
    end
  end
end
