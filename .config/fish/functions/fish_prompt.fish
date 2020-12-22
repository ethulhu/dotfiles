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

  function prompt_repo
    if pwd | grep -q -E "^$HOME/src/.+"
      echo -n ' ['
      pwd | sed "s|^$HOME/src/\([^/]*\).*\$|\1|"
      echo -n ']'
    end
  end

  set -l prompt_hostname
  if set -q SSH_CLIENT; or ssh -q SSH_CONNECTION; or ssh -q SSH_TTY
    set prompt_hostname "@$hostname"
  end

  # Write pipestatus
  set -l prompt_status (__fish_print_pipestatus " [" "]" "|" (set_color $fish_color_status) (set_color --bold $fish_color_status) $last_pipestatus)

  echo -n -s \
    $USER $prompt_hostname ' ' \
    (set_color $color_cwd) (prompt_pwd) (set_color normal) \
    (prompt_repo) (fish_vcs_prompt) (set_color normal) \
    $prompt_status $suffix ' '
end
