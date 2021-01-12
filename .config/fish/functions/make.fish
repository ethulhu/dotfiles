function (basename (status filename) .fish) --wraps make --description 'ascend the filesystem, looking for Makefiles'
  fish --private --command "
    while ! [ -f 'Makefile' -o -f 'makefile' -o $PWD = $HOME -o $PWD = '/' ]
      builtin cd ..
    end

    pwd 1>&2
    command make $argv
  "
end
