# macOS-specific configuration.

# Homebrew on AArch64 is in /opt/.
if [ (uname -m) = 'arm64' ]
    set --prepend PATH /opt/homebrew/bin
end

set --prepend PATH ~/.local/bin/macos

set --local python_version (python3 --version | string match --regex '[[:digit:]]+\.[[:digit:]]+')
set --prepend --export PYTHONPATH ~/.local/lib/python$python_version/site-packages
set --prepend PATH ~/Library/Python/$python_version/bin
