# Main fish configuration.

set fish_greeting ''

# MANPATH is inferred from PATH, so ~/.local/bin implies ~/.local/share/man.

# Go.
set --export GOPATH ~/.local/go
set --prepend PATH $GOPATH/bin

# Rust.
set --prepend PATH ~/.cargo/bin

# OCaml.
if [ -f ~/.opam/opam-init/init.fish ]
  # source ~/.opam/opam-init/init.fish

  # There is a bug in `opam env` that adds `.` to PATH.
  # This is a workaround, and should be removed when opam > 2.0.7.
  if status is-interactive
    set --global --export OPAMNOENVNOTICE true;
    function __opam_env_export_eval --on-event fish_prompt;
      opam env --shell=fish --readonly ^/dev/null | string replace ':' '' | source
    end
  end
	source ~/.opam/opam-init/variables.fish

  alias ocaml='rlwrap ocaml'
  alias ml='ocaml'
end

set --prepend PATH ~/.local/bin ~/bin

set --export EDITOR vim

# Allow only color control codes through.
set --export LESS '-R'

if command --quiet direnv
  direnv hook fish | source
end

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

set --local os (operating_system | string lower)
if [ -f ~/.config/fish/config-$os.fish ]
    source ~/.config/fish/config-$os.fish
end
