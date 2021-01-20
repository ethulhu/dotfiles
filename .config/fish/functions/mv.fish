set --local function_name (basename (status filename) .fish)

function $function_name --description 'Stop interactive use of mv'

    if status is-interactive
        echo (status function)": Don't use `mv`, use `move` or `rename`."
        return 1
    end

    command mv $argv
end
