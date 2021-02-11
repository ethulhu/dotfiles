set --local function_name (basename (status filename) .fish)

function $function_name --wraps make --description 'Ascend the filesystem, looking for Makefiles.'

    set --local dir (fish --private --command "
        while ! [ -f 'Makefile' -o -f 'makefile' -o $PWD = $HOME -o $PWD = '/' ]
          builtin cd ..
        end
        pwd
    ")

    echo (status function)": $dir" 1>&2
    command make --directory=$dir $argv
end
