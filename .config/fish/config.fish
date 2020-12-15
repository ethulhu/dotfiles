set fish_greeting ''

# MANPATH is inferred from PATH, so ~/.local/bin implies ~/.local/share/man.

# Go.
set -x GOPATH ~/.local/go
if [ -d $GOPATH ]
  set -x PATH $GOPATH/bin $PATH
end

# Rust.
if [ -d ~/.cargo ]
	set -x PATH ~/.cargo/bin $PATH
end

set -x PATH ~/.local/bin ~/bin $PATH

switch (uname -s)
case Darwin
  set -x PATH ~/.local/bin/macos $PATH

  set -l python_version (python3 --version | sed -E 's/.* ([[:digit:]]+\.[[:digit:]]+).*/\1/')
	set -x PATH ~/Library/Python/$python_version/bin $PATH
	set -x PYTHONPATH ~/.local/lib/python$python_version/site-packages $PYTHONPATH

case Linux
	set -x PATH ~/.local/bin/debian $PATH

	set -x SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
	set -x GPG_TTY (tty)

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
