set --local function_name (basename (status filename) .fish)

function $function_name --wraps cd --argument-names path

  # Use fish's own `cd` wrapper if possible,
  # because it has features such as history.
  if not functions --query __builtin_cd
    __wrap_fish_function \
      --name '__builtin_cd' \
      --path $__fish_data_dir/functions/cd.fish \
      --fallback 'builtin cd'
  end

  if not status is-interactive
    __builtin_cd $argv
  end

  if [ "$path" -a -f "$path" ]
    __builtin_cd (dirname $path)
  else
    __builtin_cd $argv
  end
end
