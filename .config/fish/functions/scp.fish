set --local function_name (basename (status filename) .fish)

function $function_name --wraps scp
    if not status is-interactive
        command scp $argv
    else
        set --local num_paths 0
        set --local num_colons 0
        for arg in $argv
            if string match --quiet -- '-*' $arg
                continue
            end
            set num_paths (math $num_paths + 1)
            if string match --quiet -- '*:*' $arg
                set num_colons (math $num_colons + 1)
            end
        end
        if [ $num_paths -gt 0 -a $num_colons -eq 0 ]
            if confirm (status function)": no host:path given; continue anyway?"
                command scp $argv
            end
        end
        command scp $argv
    end
end
