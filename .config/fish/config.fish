# Main fish configuration.

set fish_greeting ''

# MANPATH is inferred from PATH, so ~/.local/bin implies ~/.local/share/man.

# Go.
set --export GOPATH ~/.local/go
set --prepend PATH $GOPATH/bin

# Rust.
set --prepend PATH ~/.cargo/bin

# OCaml.
if command --quiet opam; and opam var prefix >/dev/null ^/dev/null
    if status is-interactive
        # This stops `opam switch` telling us to reload the environment.
        set --global --export OPAMNOENVNOTICE true
    end

    function __update_opam_env --on-event fish_prompt
        if not set --query OPAM_SWITCH_PREFIX; or [ (opam var prefix) != $OPAM_SWITCH_PREFIX ]
            # Source everything except PATH.
            opam env --shell=fish --readonly \
                | string match --invert 'set -gx PATH *' \
                | source

            # In-place replace all paths matching $opam_root/*.
            set --local opam_root (opam var root)
            set --local opam_switch_bin "$OPAM_SWITCH_PREFIX/bin"
            for i in (seq (count $PATH))
                if string match --quiet -- "$opam_root/*" $PATH[$i]
                    set PATH[$i] $opam_switch_bin
                end
            end

            # If there were no pre-existing $opam_root/* matches, prepend it.
            if not contains -- $opam_switch_bin $PATH
                set --prepend PATH $opam_switch_bin
            end
        end
    end

    __update_opam_env

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
