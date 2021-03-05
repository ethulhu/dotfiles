set --local function_name (basename (status filename) .fish)

function $function_name --wraps rm
    if not status is-interactive
        command rm $argv
    else
        set --local items
        for arg in $argv
            if [ -e $arg ]
                set --append items $arg
            end
        end

        if [ (count $items) -eq 0 ]
            command rm $argv
        else
            set --local num_dirs  (find $items -type d | count)
            set --local num_files (find $items -type f | count)

            if confirm (status function)": delete $num_files files and $num_dirs dirs?"
                command rm $argv
            end
        end
    end
end
