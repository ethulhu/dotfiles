function (basename (status filename) .fish) --description 'Inherit environment variables from a tmux session.'

  set -l variables (tmux show-environment)

  for name in $argv
    if set -l variable (string replace --filter "$name=" '' -- $variables)
      set --export $name $variable
    else
      set --erase $name
    end
  end
end
