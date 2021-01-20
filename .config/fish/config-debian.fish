# Debian-specific configuration.

set --prepend PATH ~/.local/bin/linux

if getent group netdev >/dev/null
    alias wpa_cli='/usr/sbin/wpa_cli'
end
