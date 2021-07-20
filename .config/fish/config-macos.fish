# macOS-specific configuration.

# Homebrew on AArch64 is in /opt/.
if [ (uname -m) = 'arm64' ]
    set --append fish_user_paths /opt/homebrew/bin
end

set --prepend fish_user_paths ~/.local/bin/macos
set --append fish_user_paths /Applications/OpenSCAD.app/Contents/MacOS

set --local python_version (python3 --version | string match --regex '[[:digit:]]+\.[[:digit:]]+')
set --export PYTHONPATH ~/.local/lib/python$python_version/site-packages
set --prepend fish_user_paths ~/Library/Python/$python_version/bin
