set --local command (basename (status filename) .fish)

function __complete_dune_aliases --description 'Built-in aliases'
    printf "%s\t%s\n"  @all          'Build everything'
    printf "%s\t%s\n"  @check        'Build targets needed for tooling support'
    printf "%s\t%s\n"  @default      'Build default targets'
    printf "%s\t%s\n"  @doc          'Build documentation for public libraries'
    printf "%s\t%s\n"  @doc-private  'Build documentation for all libraries'
    printf "%s\t%s\n"  @install      'Build installable artifacts'
    printf "%s\t%s\n"  @lint         'Run linting tools'
    printf "%s\t%s\n"  @runtest      'Build & run tests'
end


function __complete_dune_current_subcommand
    set --local cmd (commandline --current-process --tokenize --cut-at-cursor)
    echo $cmd[2]
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
    --arguments "(__complete_cmdliner_commands $command (__complete_dune_current_subcommand))"

complete \
    --command $command \
    --condition "__fish_seen_subcommand_from $subcommands; and __fish_should_complete_switches" \
    --exclusive \
    --arguments "(__complete_cmdliner_flags $command (__complete_dune_current_subcommand))"


# Specific subcommand completions.

complete \
    --command $command \
    --condition '__fish_seen_subcommand_from help' \
    --exclusive \
    --arguments "(__complete_cmdliner_commands $command)"

complete \
    --command $command \
    --condition '__fish_seen_subcommand_from build' \
    --exclusive \
    --arguments "(__complete_dune_aliases)"
