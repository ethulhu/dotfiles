set --local command (basename (status filename) .fish)

function __complete_opam_switches --description 'List opam switches'
    for switch in (command opam switch list --safe --short)
        printf "%s\t%s\n" $switch "OCaml $switch"
    end
end

function __complete_opam_vars --description 'List opam vars'
    opam var --safe | sed -n \
        -e '/^PKG:/d' \
        -e '/^<><>/d' \
        -e 's%^\\([^#= ][^ ]*\\).*%\\1%p'
end

function __complete_opam_current_subcommand
    set --local cmd (commandline --current-process --tokenize --cut-at-cursor)
    echo $cmd[2]
end

function __complete_opam_previous_token_is --argument-names token
    set --local cmd (commandline --current-process --tokenize --cut-at-cursor)
    [ "$cmd[-1]" = "$token" ]
end

set --local subcommands (__complete_cmdliner_commands $command | string replace --regex '[[:space:]].*' '')


# Generic completions.

complete \
    --command $command \
    --condition "not __fish_seen_subcommand_from $subcommands; and not __fish_should_complete_switches" \
    --exclusive \
    --arguments "(__complete_cmdliner_commands $command)"

complete \
    --command $command \
    --condition "not __fish_seen_subcommand_from $subcommands; and __fish_should_complete_switches" \
    --exclusive \
    --arguments "(__complete_cmdliner_flags $command)"

complete \
    --command $command \
    --condition "__fish_seen_subcommand_from $subcommands; and not __fish_should_complete_switches" \
    --exclusive \
    --arguments "(__complete_cmdliner_commands $command (__complete_opam_current_subcommand))"

complete \
    --command $command \
    --condition "__fish_seen_subcommand_from $subcommands; and __fish_should_complete_switches" \
    --exclusive \
    --arguments "(__complete_cmdliner_flags $command (__complete_opam_current_subcommand))"


# Specific subcommand completions.

complete \
    --command $command \
    --condition '__fish_seen_subcommand_from help' \
    --exclusive \
    --arguments "(__complete_cmdliner_commands $command)"

complete \
    --command $command \
    --condition '__fish_seen_subcommand_from switch' \
    --exclusive \
    --arguments '(__complete_opam_switches)'

complete \
    --command $command \
    --condition '__fish_seen_subcommand_from switch' \
    --exclusive \
    --arguments '(__complete_opam_switches)'

complete \
    --command $command \
    --condition '__fish_seen_subcommand_from var' \
    --exclusive \
    --arguments '(__complete_opam_vars)'


# Specific flag completions.

complete \
    --command $command \
    --condition '__complete_opam_previous_token_is --switch' \
    --exclusive \
    --arguments '(__complete_opam_switches)'
