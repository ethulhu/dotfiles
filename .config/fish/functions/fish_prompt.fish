set --local function_name (basename (status filename) .fish)

function $function_name --description 'Write out the prompt'

    if [ $TERM = 'dumb' ]
        return
    end

    set --local color_cwd $fish_color_cwd
    set --local suffix '>'

    if fish_is_root_user
        if set --query fish_color_cwd_root
            set color_cwd $fish_color_cwd_root
        end
        set suffix '#'
    end

    set --local prompt_user $USER
    set --local prompt_hostname
    if set --query SSH_CONNECTION
        set prompt_user (set_color $fish_color_user) $USER (set_color normal)
        set prompt_hostname '@' (set_color $fish_color_host_remote) $hostname (set_color normal)
    end

    set --local prompt_repo_name (git rev-parse --show-toplevel ^/dev/null)
    if [ "$prompt_repo_name" != '' ]
       set prompt_repo_name ' ['(basename $prompt_repo_name)']'
    end

    echo -n -s \
        $prompt_user $prompt_hostname ' ' \
        (set_color $color_cwd) (prompt_pwd) (set_color normal) \
        $prompt_repo_name (fish_vcs_prompt) (set_color normal) \
        $suffix ' '
end
