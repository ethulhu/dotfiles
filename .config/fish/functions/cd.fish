function cd --argument-names path

  # Use fish's own `cd` wrapper if possible,
  # because it has features such as history.
  if not functions --query __builtin_cd
    __wrap_fish_function \
      --name '__builtin_cd' \
      --path $__fish_data_dir/functions/cd.fish \
      --fallback 'builtin cd'
  end

  if [ ! $path ]
    __builtin_cd ~
  else if [ -f $path ]
    __builtin_cd (dirname $path)
  else
    __builtin_cd $path
  end
end
