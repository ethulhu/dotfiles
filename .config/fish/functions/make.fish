function (basename (status filename) .fish) --wraps make --description 'ascend the filesystem, looking for Makefiles'
  fish --private --command "
    while ! [ -f 'Makefile' -o -f 'makefile' -o (pwd) = $HOME -o (pwd) = '/' ]
      cd ..
    end

    pwd 1>&2
    command make $argv
  "
end
