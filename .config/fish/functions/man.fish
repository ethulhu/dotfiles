set --local function_name (basename (status filename) .fish)

function $function_name --wraps man --argument-names query

    # Use fish's own `man` wrapper if possible.
    if not functions --query __builtin_man
        __wrap_fish_function \
            --name __builtin_man \
            --path $__fish_data_dir/functions/man.fish \
            --fallback 'command man'
    end

    if status is-interactive; and [ (count $argv) -eq 1 ]

        set --local candidates (__builtin_man -a --path $query 2>/dev/null)

        if [ (count $candidates) -gt 1 ]

            # Filter out trivial duplicates.
            set --local i 1
            while [ $i -lt (count $candidates) ]
                for j in (seq (math $i + 1) (count $candidates))
                    if diff -q $candidates[$i] $candidates[$j] >/dev/null
                        set --append deletions $j
                    end
                end
                if set --query deletions
                    set --erase candidates[$deletions]
                    set --erase deletions
                end
                set i (math $i + 1)
            end

            # If there is more than 1 candidate, ask the user to decide.
            set --local idx 1
            if [ (count $candidates) -gt 1 ]
                for candidate in $candidates
                    echo $candidate
                end | nl
                set idx (read --nchars 1 --prompt-str 'which manpage? ')

                if not string match --quiet --regex '[[:digit:]]' $idx; or not [ 1 -le $idx -a $idx -le (count $candidates) ]
                    echo (status function)": invalid index: '$idx'"
                    return 1
                end
            end

            __builtin_man $candidates[$idx]
        else
            __builtin_man $argv
        end
    else
        __builtin_man $argv
    end
end
