set --local function_name (basename (status filename) .fish)

function $function_name --wraps cp
    if not status is-interactive
        command cp $argv
    else
        if [ (count $argv) -gt 0 -a -e "$argv[-1]" ]
            if confirm (status function):" overwrite $argv[-1]?"
                command cp $argv
            end
        else
            command cp $argv
        end
    end
end
