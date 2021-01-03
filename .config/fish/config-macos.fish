# macOS-specific configuration.

# Homebrew on AArch64 is in /opt/.
if [ -d /opt/homebrew/bin ]
  set -x PATH /opt/homebrew/bin $PATH
end

set -x PATH ~/.local/bin/macos $PATH

set -l python_version (python3 --version | sed -E 's/.* ([[:digit:]]+\.[[:digit:]]+).*/\1/')
set -x PATH ~/Library/Python/$python_version/bin $PATH
set -x PYTHONPATH ~/.local/lib/python$python_version/site-packages $PYTHONPATH
