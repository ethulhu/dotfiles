# dotfiles

## quickstart

```sh
$ git clone --bare git@github.com:ethulhu/dotfiles .dotfiles
$ git --git-dir="${HOME}/.dotfiles/" --work-tree="${HOME}" checkout
$ git --git-dir="${HOME}/.dotfiles/" --work-tree="${HOME}" config --local status.showUntrackedFiles no
```

## links

- https://www.atlassian.com/git/tutorials/dotfiles
