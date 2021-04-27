set --local function_name (basename (status filename) .fish)

function $function_name --wraps cp
    # Do regular cp if being used in a script, there is no destination, or the destination is clear.
    if not status is-interactive; or [ (count $argv) -eq 0 ]; or not [ -e "$argv[-1]" ]
        command cp $argv
    else
        if [ -f "$argv[-1]" ]
            if confirm (status function):" overwrite $argv[-1]?"
                command cp $argv
            end
        else
            command cp $argv
        end
    end
end
