# append to the history file, don't overwrite it
shopt -s histappend

# keep all history forever.
HISTSIZE=-1
# HISTIGNORE

# update the window size after each command, setting LINES and COLUMNS.
shopt -s checkwinsize

# `**` matches all files and zero or more directories and subdirectories.
shopt -s globstar 2>/dev/null  # only exists from 4.0 onwards.


# Go.
export GOPATH='~/go'
export PATH="${GOPATH}/bin:${PATH}"

# Rust.
if [ -d ~/.cargo ]; then
	export PATH=~/.cargo/bin:${PATH}
fi

# MANPATH is inferred from PATH based on these.
export PATH=~/bin:${PATH}
export PATH=~/.local/bin:${PATH}

if [ $(uname -s) = 'Darwin' ]; then
  export PYTHONPATH="${HOME}/.local/lib/python3.7/site-packages"
fi

export EDITOR='vim'

source ~/.config/aliases


if [ -d ~/.bashrc.d ]; then
	for rc in ~/.bashrc.d/*.rc; do
		source "${rc}"
	done
fi

# make less more friendly for non-text input files, see lesspipe(1).
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

num_colors="$(tput colors)"
if [ "${num_colors}" ] && [ "${num_colors}" -ge 8 ]; then
	true  # colors-only stuff?
fi
