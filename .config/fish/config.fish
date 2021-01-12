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
  if isatty
    set -gx OPAMNOENVNOTICE true;
    function __opam_env_export_eval --on-event fish_prompt;
      eval (opam env --shell=fish --readonly ^ /dev/null | sed 's/://g');
    end
  end
	source ~/.opam/opam-init/variables.fish

  alias ocaml='rlwrap ocaml'
end

set -x PATH ~/.local/bin ~/bin $PATH

if command -q direnv
  eval (direnv hook fish)
end

set -x EDITOR vim

# CDPATH is used to expand non-absolute paths as well as $PWD,
# e.g. `cd linux` -> `cd ~/src/linux`.
set -x CDPATH ~/src . $CDPATH

source ~/.config/aliases


# Event handlers.

function __on_fish_preexec --on-event fish_preexec
  if command --quiet gpg-connect-agent
    gpg-connect-agent updatestartuptty /bye >/dev/null
  end
end

function __on_fish_postexec --on-event fish_postexec
end


# Builtin wrappers.

# Use fish's own `cd` wrapper if possible,
# because it has features such as history.
if [ -f $__fish_data_dir/functions/cd.fish ]
  cat $__fish_data_dir/functions/cd.fish \
    | sed 's/^function cd /function __builtin_cd /' \
    | source
else
  alias __builtin_cd 'builtin cd'
end


# fish_prompt pre-computes.

set -g prompt_user $USER
set -g prompt_hostname
if set -q SSH_CLIENT; or set -q SSH_CONNECTION; or set -q SSH_TTY
  set -g prompt_user (set_color $fish_color_user) $USER (set_color normal)
  set -g prompt_hostname '@' (set_color $fish_color_host_remote) $hostname (set_color normal)
end


# Per-OS configuration.

set -l os (operating_system | string lower)
if [ -f ~/.config/fish/config-$os.fish ]
    source ~/.config/fish/config-$os.fish
end
