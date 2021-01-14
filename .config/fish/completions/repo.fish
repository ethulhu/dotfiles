set -l wrapper (basename (status filename) .fish)

complete --command $wrapper --condition "not __fish_seen_subcommand_from (command $wrapper --list-subcommands)" --exclusive --arguments "(command $wrapper --fish-completion)"
