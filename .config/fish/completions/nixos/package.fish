set --local command (basename (status filename) .fish)

set --local subcommands install uninstall path

complete \
  --command $command \
  --condition "not __fish_seen_subcommand_from $subcommands" \
  --exclusive \
  --arguments path \
  --description 'Show the path of a Nixpkgs package'

complete \
  --command $command \
  --condition "not __fish_seen_subcommand_from $subcommands" \
  --exclusive \
  --arguments install \
  --description 'Add a Nixpkgs package to the PATH'

complete \
  --command $command \
  --condition "not __fish_seen_subcommand_from $subcommands" \
  --exclusive \
  --arguments uninstall \
  --description 'Remove a Nixpkgs package from the PATH'
