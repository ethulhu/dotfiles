# Debian-specific configuration.

set -x PATH ~/.local/bin/linux $PATH

if getent group netdev >/dev/null
  alias wpa_cli='/usr/sbin/wpa_cli'
end
