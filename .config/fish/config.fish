set fish_greeting ''


# Go.
set -x GOPATH ~/go
set -x PATH $GOPATH/bin $PATH

# Rust.
if [ -d ~/.cargo ]
	set -x PATH ~/.cargo/bin $PATH
end

# MANPATH is inferred from PATH based on these.
set -x PATH ~/bin $PATH
set -x PATH ~/.local/bin $PATH

switch (uname -s)
case Darwin
	set -x PYTHONPATH $HOME/.local/lib/python3.7/site-packages
case Linux
	set -x SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
	set -x GPG_TTY (tty)
	set -x PATH ~/.local/bin/debian $PATH

	if [ -d ~/.local/go ]
		set -x PATH ~/.local/go/bin $PATH
	end

	if getent group netdev >/dev/null
		alias wpa_cli='/usr/sbin/wpa_cli'
	end
end

set -x EDITOR vim

source ~/.config/aliases
