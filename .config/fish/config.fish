set fish_greeting ''

# MANPATH is inferred from PATH, so ~/.local/bin implies ~/.local/share/man.

# Go.
set -x GOPATH ~/.local/go
if [ -d $GOPATH ]
  set -x PATH $GOPATH/bin $PATH
end

# Rust.
if [ -d ~/.cargo ]
	set -x PATH ~/.cargo/bin $PATH
end

set -x PATH ~/.local/bin ~/bin $PATH

switch (uname -s)
case Darwin
  set -x PATH ~/.local/bin/macos $PATH

  set -l python_version (python3 --version | sed -E 's/.* ([[:digit:]]+\.[[:digit:]]+).*/\1/')
	set -x PATH ~/Library/Python/$python_version/bin $PATH
	set -x PYTHONPATH ~/.local/lib/python$python_version/site-packages $PYTHONPATH

case Linux
	set -x PATH ~/.local/bin/linux $PATH

  if [ -f /etc/debian_version ]
    set -x PATH ~/.local/bin/debian $PATH

    if getent group netdev >/dev/null
      alias wpa_cli='/usr/sbin/wpa_cli'
    end
  end
end

if command -q direnv
  eval (direnv hook fish)
end

set -x EDITOR vim

source ~/.config/aliases

# OCaml / opam configuration.
if [ -f ~/.opam/opam-init/init.fish ]
  # source ~/.opam/opam-init/init.fish

  # There is a bug in `opam env` that adds `.` to PATH.
  # This is a workaround, and should be removed when opam > 2.0.7.
  if isatty
    set -gx OPAMNOENVNOTICE true;
    function __opam_env_export_eval --on-event fish_prompt;
      eval (opam env --shell=fish --readonly ^ /dev/null | sed 's/://g');
    end
  end
	source ~/.opam/opam-init/variables.fish

  alias ocaml='rlwrap ocaml'
end

# Event handlers.
function __on_fish_preexec --on-event fish_preexec
  if command --quiet gpg-connect-agent
    gpg-connect-agent updatestartuptty /bye >/dev/null
  end
end

function __on_fish_postexec --on-event fish_postexec
end

if [ -d /nix/store ]
  function __fish_command_not_found_handler --on-event fish_command_not_found --argument-names command
    set -l db '/nix/var/nix/profiles/per-user/root/channels/nixos/programs.sqlite'
    if [ ! -f $db ]
      __fish_default_command_not_found_handler $argv
    end

    function path_of_package --argument-names package
      nix-build --no-out-link '<nixpkgs>' --attr $package
    end

    set -l sqlite3 (path_of_package sqlite)/bin/sqlite3

    set -l num_packages (command $sqlite3 $db "select count (distinct package) from Programs where name = '$command'")
    set -l packages (command $sqlite3 $db "select distinct package from Programs where name = '$command'")

    __fish_default_command_not_found_handler $argv
    switch $num_packages
      case 0

      case 1
        switch (read --prompt-str="It is provided by package $packages; add it to PATH? [y/N] " --nchars=1)
          case y
            set -x PATH (path_of_package $packages)/bin $PATH
            commandline --replace "$argv"
        end

      case '*'
        echo "It is provided by Nix packages:"
        for package in $packages
          echo "  $package"
        end
    end
  end
end
