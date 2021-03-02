set --local function_name (basename (status filename) .fish)

function $function_name --argument-names at_least --description 'Is the fish version recent enough?'

    set --local lowest (
        begin
            echo $version
            echo $at_least
        end | sort | head -n1
    )

    test $lowest = $at_least
end
