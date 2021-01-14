set -l function_name (basename (status filename) .fish)

function $function_name --wraps make --description 'Ascend the filesystem, looking for Makefiles.'
  fish --private --command "
    while ! [ -f 'Makefile' -o -f 'makefile' -o $PWD = $HOME -o $PWD = '/' ]
      builtin cd ..
    end

    pwd 1>&2
    command make $argv
  "
end
