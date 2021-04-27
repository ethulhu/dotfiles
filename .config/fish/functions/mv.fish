set --local function_name (basename (status filename) .fish)

function $function_name --wraps mv
    # Do regular mv if being used in a script, there is no destination, or the destination is clear.
    if not status is-interactive; or [ (count $argv) -eq 0 ]; or not [ -e "$argv[-1]" ]
        command mv $argv
    else
        if [ -f "$argv[-1]" ]
            if confirm (status function):" overwrite $argv[-1]?"
                command mv $argv
            end
        else
            command mv $argv
        end
    end
end
