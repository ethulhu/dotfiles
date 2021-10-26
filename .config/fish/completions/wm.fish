set --local command (basename (status filename) .fish)

complete \
    --command $command \
    --condition "not __fish_seen_subcommand_from (command $command --list-subcommands)" \
    --exclusive \
    --arguments "(command $command --fish-completion)"
