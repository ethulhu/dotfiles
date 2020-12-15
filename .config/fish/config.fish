set fish_greeting ''

# Go.
set -x GOPATH ~/.local/go
if [ -d $GOPATH ]
  set -x PATH $GOPATH/bin $PATH
end

# Rust.
if [ -d ~/.cargo ]
	set -x PATH ~/.cargo/bin $PATH
end

# MANPATH is inferred from PATH based on these.
set -x PATH ~/bin $PATH
set -x PATH ~/.local/bin $PATH

switch (uname -s)
case Darwin
  set -l python_version (python3 --version | sed -E 's/.* ([[:digit:]]+\.[[:digit:]]+).*/\1/')
	set -x PATH $HOME/Library/Python/$python_version/bin $PATH
	set -x PYTHONPATH $HOME/.local/lib/python$python_version/site-packages $PYTHONPATH
case Linux
	set -x SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
	set -x GPG_TTY (tty)
	set -x PATH ~/.local/bin/debian $PATH

	if getent group netdev >/dev/null
		alias wpa_cli='/usr/sbin/wpa_cli'
	end
end

set -x EDITOR vim

source ~/.config/aliases

# OCaml / opam configuration.
if [ -f ~/.opam/opam-init/init.fish ]
	source ~/.opam/opam-init/init.fish

	alias ocaml='rlwrap ocaml'
end

# Event handlers.
function __on_fish_preexec --on-event fish_preexec
  if command -v gpg-connect-agent >/dev/null
    gpg-connect-agent updatestartuptty /bye >/dev/null
  end
end

function __on_fish_postexec --on-event fish_postexec
end
