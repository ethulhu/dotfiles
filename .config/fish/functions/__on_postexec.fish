set --local function_name (basename (status filename) .fish)

function $function_name --description 'Run after every command.'

    set --local pipe_status (__fish_print_pipestatus "[" "]" "|" (set_color $fish_color_status) (set_color --bold $fish_color_status) $__postexec_pipestatus)
    if [ "$pipe_status" ]
        echo $pipe_status
    end
end
