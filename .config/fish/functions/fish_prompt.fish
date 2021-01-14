function fish_prompt --description 'Write out the prompt'
  set -l last_pipestatus $pipestatus

	if [ $TERM = "dumb" ]
		return
	end

	set -l color_cwd $fish_color_cwd
	set -l suffix '>'

  if contains -- $USER root toor
    if set -q fish_color_cwd_root
      set color_cwd $fish_color_cwd_root
    end
    set suffix '#'
  end

  set -l prompt_user $USER
  set -l prompt_hostname
  if set --query SSH_CONNECTION
    set prompt_user (set_color $fish_color_user) $USER (set_color normal)
    set prompt_hostname '@' (set_color $fish_color_host_remote) $hostname (set_color normal)
  end

  set -l prompt_repo_name (string replace --regex --filter "$HOME/src/([^/]*).*" ' [$1]' $PWD; or true)

  # Write pipestatus.
  set -l prompt_status (__fish_print_pipestatus " [" "]" "|" (set_color $fish_color_status) (set_color --bold $fish_color_status) $last_pipestatus)

  echo -n -s \
    $prompt_user $prompt_hostname ' ' \
    (set_color $color_cwd) (prompt_pwd) (set_color normal) \
    $prompt_repo_name (fish_vcs_prompt) (set_color normal) \
    $prompt_status $suffix ' '
end
