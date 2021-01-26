set --local function_name (basename (status filename) .fish)

function $function_name --description 'Replace groff ASCII escapes with the relevant characters'
    cat \
        | string replace --all '\\N\'45\'' '-' \
        | string replace --all '\\N\'46\'' '.' \
        | string replace --all '\\N\'39\'' "'"
end
