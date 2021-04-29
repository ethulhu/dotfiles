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


# Set up OCaml if `opam` has been added to the PATH.
function __set_up_opam --on-variable PATH
    if command --quiet opam; and command opam var prefix >/dev/null ^/dev/null
        if set --query __opam_set_up
            return
        end
        set --global __opam_set_up true

        if status is-interactive
            # This stops `opam switch` telling us to reload the environment.
            set --global --export OPAMNOENVNOTICE true
        end

        function __update_opam_env --on-event fish_preexec --on-event fish_postexec
            if [ (command opam var prefix) != "$OPAM_SWITCH_PREFIX" ]
                # Source everything except PATH.
                command opam env --shell=fish --readonly \
                    | string match --invert 'set -gx PATH *' \
                    | source

                # Trigger updating the PATH.
                emit opam_switch_changed
            end
        end

        function __update_opam_path --on-event opam_switch_changed
            set --local opam_root (command opam var root)
            set --local new_switch_bin (command opam var prefix)/bin

            # Replace all paths matching $opam_root/*.
            for path in $fish_user_paths
                if string match --quiet -- "$opam_root/*" $path
                    set fish_user_paths[(contains --index -- $path $PATH)] $new_switch_bin
                end
            end

            # If there were no pre-existing $opam_root/* matches, prepend it.
            if not contains -- $new_switch_bin $fish_user_paths
                set --prepend fish_user_paths $new_switch_bin
            end
        end

        # Erase any opam switches in PATH from fish's caller (e.g. tmux).
        set --local opam_root (command opam var root)
        for path in $PATH
            if string match --quiet -- "$opam_root/*" $path
                set --erase PATH[(contains --index -- $path $PATH)]
            end
        end

        # Initial opam environment.
        __update_opam_env
        __update_opam_path

        alias ocaml='rlwrap ocaml'
        alias ml='ocaml'

        function opam \
                --wraps opam \
                --description 'Unset OCaml-related environment variables before running opam'

            # `env -u` isn't in POSIX, but is on macOS & Debian & NixOS.
            # https://pubs.opengroup.org/onlinepubs/9699919799/utilities/env.html
            env \
                -u DUNE_CACHE \
                -u DUNE_PROFILE \
                -u OCAMLRUNPARAM \
                opam $argv
        end
    end
end
__set_up_opam


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
