# Main fish configuration.

set fish_greeting ''

set --export EDITOR vim
set --export GOPATH ~/.local/go

# Allow only color control codes through.
set --export LESS '-R'

# CDPATH is used to expand non-absolute paths as well as $PWD,
# e.g. `cd linux` -> `cd ~/src/linux`.
# If exported, other `cd` implementations might become noisy.
set --global CDPATH . ~/src ~


# MANPATH is inferred from PATH, so ~/.local/bin implies ~/.local/share/man.
set --global --path fish_user_paths \
    ~/bin \
    ~/.local/bin \
    $GOPATH/bin \
    ~/.cargo/bin

# Set up OCaml.
if [ -f ~/.opam/opam-init/init.fish ]
    # source ~/.opam/opam-init/init.fish

    # opam's setup uses deprecated fish syntax, so it's copypasted here.
    # TODO: remove ASAP.`
    if isatty
        cat ~/.opam/opam-init/env_hook.fish | string replace '^' '2>' | source
    end

    source /Users/eth/.opam/opam-init/variables.fish > /dev/null 2> /dev/null; or true
end


if command --quiet direnv
    direnv hook fish | source
end


source ~/.config/aliases


# Event handlers.

if fish_version_at_least 3.2.0
    function __on_fish_preexec --on-event fish_preexec
        __on_preexec $argv
    end
    function __on_fish_postexec --on-event fish_postexec
        set --global __postexec_pipestatus $pipestatus
        __on_postexec $argv
    end
else
    # Workaround to stop these handlers running on fish_prompt as well.
    function __on_fish_preexec --on-event fish_preexec
        if [ "$argv" ]
            __on_preexec $argv
            set --global __preexec_ran
        end
    end
    function __on_fish_postexec --on-event fish_postexec
        set --global __postexec_pipestatus $pipestatus
        if set --query __preexec_ran
            __on_postexec $argv
        end
        set --erase __preexec_ran
    end
end

if set --query TMUX
    function __update_variables_from_tmux --on-event fish_preexec
        inherit_variables_from_tmux SSH_AUTH_SOCK SSH_CONNECTION
    end
end


# Backwards compatibility.

if not fish_version_at_least 3.2.0
    function fish_is_root_user
        contains -- $USER root toor
    end
end


# Per-OS configuration.

set --local os (operating_system | string lower)
if [ -f ~/.config/fish/config-$os.fish ]
    source ~/.config/fish/config-$os.fish
end
