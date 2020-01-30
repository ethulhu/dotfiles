function fish_prompt --description 'Write out the prompt'

	set -l color_normal (set_color normal)
	set -l color_cwd
	set -l suffix

	switch $USER
	case root toor
		if set -q fish_color_cwd_root
			set color_cwd (set_color $fish_color_cwd_root)
		else
			set color_cwd (set_color $fish_color_cwd)
		end
		set suffix '#'
	case '*'
		set color_cwd (set_color $fish_color_cwd)
		set suffix '>'
	end

	if [ $TERM = "dumb" ]
		return
	end
	if [ (tput colors) -eq 1 ]
		echo -n -s "$USER "(prompt_pwd)"$suffix"
	else
		echo -n -s "$USER" ' ' "$color_cwd" (prompt_pwd) "$color_normal" "$suffix "
	end
end
