# dotfiles

## quickstart

Fish:

```sh
$ git clone --bare git@github.com:ethulhu/dotfiles .dotfiles
$ git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout
$ git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME config --local status.showUntrackedFiles no
```

Bash:

```sh
$ git clone --bare git@github.com:ethulhu/dotfiles .dotfiles
$ git --git-dir="${HOME}/.dotfiles/" --work-tree="${HOME}" checkout
$ git --git-dir="${HOME}/.dotfiles/" --work-tree="${HOME}" config --local status.showUntrackedFiles no
```

it should be possible to run `dotfiles add ~/.*` and catch everything needing importing.

## links

- https://www.atlassian.com/git/tutorials/dotfiles
