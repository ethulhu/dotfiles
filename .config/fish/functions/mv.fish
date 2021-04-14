set --local function_name (basename (status filename) .fish)

function $function_name --wraps mv
    if not status is-interactive
        command mv $argv
    else
        if [ (count $argv) -gt 0 -a -e "$argv[-1]" ]
            if confirm (status function):" overwrite $argv[-1]?"
                command mv $argv
            end
        else
            command mv $argv
        end
    end
end
