# Main fish configuration.

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

# OCaml.
if [ -f ~/.opam/opam-init/init.fish ]
  # source ~/.opam/opam-init/init.fish

  # There is a bug in `opam env` that adds `.` to PATH.
  # This is a workaround, and should be removed when opam > 2.0.7.
  if status is-interactive
    set -gx OPAMNOENVNOTICE true;
    function __opam_env_export_eval --on-event fish_prompt;
      opam env --shell=fish --readonly ^/dev/null | string replace ':' '' | source
    end
  end
	source ~/.opam/opam-init/variables.fish

  alias ocaml='rlwrap ocaml'
end

set -x PATH ~/.local/bin ~/bin $PATH

if command -q direnv
  direnv hook fish | source
end

set -x EDITOR vim

# CDPATH is used to expand non-absolute paths as well as $PWD,
# e.g. `cd linux` -> `cd ~/src/linux`.
# If exported, other `cd` implementations might become noisy.
set --global CDPATH . ~/src

source ~/.config/aliases


# Event handlers.

function __on_fish_preexec --on-event fish_preexec
  if command --quiet gpg-connect-agent
    gpg-connect-agent updatestartuptty /bye >/dev/null
  end
end
if set --query TMUX
  function __update_variables_from_tmux --on-event fish_preexec
    inherit_variables_from_tmux SSH_AUTH_SOCK SSH_CONNECTION
  end
end

function __on_fish_postexec --on-event fish_postexec
end


# Per-OS configuration.

set -l os (operating_system | string lower)
if [ -f ~/.config/fish/config-$os.fish ]
    source ~/.config/fish/config-$os.fish
end
