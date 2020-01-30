set fish_greeting ''


# Go.
set -x GOPATH ~/go
set -x PATH $GOPATH/bin $PATH

# Rust.
if [ -d ~/.cargo ]
  set -x PATH ~/.cargo/bin $PATH
end

# MANPATH is inferred from PATH based on these.
set -x PATH ~/bin $PATH
set -x PATH ~/.local/bin $PATH

if [ (uname -s) = 'Darwin' ]
  set -x PYTHONPATH $HOME/.local/lib/python3.7/site-packages
end

set -x EDITOR vim

source ~/.config/aliases
