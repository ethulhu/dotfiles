set --local function_name (basename (status filename) .fish)

function $function_name --wraps tmux
    # Do regular tmux if being used in a script, or we're in a tmux already, or if there are arguments.
    if not status is-interactive; or set --query TMUX; or [ (count $argv) -gt 0 ]
        command tmux $argv
    else
        set --local sessions (tmux list-sessions -F '#{session_name}')

        if [ (count $sessions) -eq 0 ]
            command tmux
        else
            echo '     n  {new session}'
            for session in $sessions
                echo $session
            end | nl

            set idx (read --nchars 1 --prompt-str 'which session? ')
            if [ $idx = q ]
                return 0
            else if [ $idx = n ]
                command tmux
            else if string match --quiet --regex '[[:digit:]]' $idx; and [ $idx -le (count $sessions) ]
                command tmux attach -t $sessions[$idx]
            else
                echo (status function)": invalid index: '$idx'"
                return 1
            end
        end
    end
end
