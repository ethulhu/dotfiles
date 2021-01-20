set --local command (basename (status filename) .fish)

complete \
  --command $command \
  --wraps "git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
