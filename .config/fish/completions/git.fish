set --local command (basename (status filename) .fish)

set --local builtin_completions $__fish_data_dir/completions/git.fish


# Include builtin completions.

if [ -f $builtin_completions ]
    source $builtin_completions
end


# git-remove-branch, similar to builtin git-switch.

complete \
    --command $command \
    --condition '__fish_git_using_command remove-branch' \
    --no-files \
    --keep-order \
    --arguments '(__fish_git_local_branches)'
