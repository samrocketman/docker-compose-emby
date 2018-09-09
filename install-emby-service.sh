#!/bin/bash
# Created by Sam Gleske
# Installs the emby.service file as a systemd service

set -aueEo pipefail

#
# ENVIRONMENT
#

DESTINATION=/etc/systemd/system/emby.service
export EMBY_DOCKER_HOME="${PWD}"

#
# FUNCTIONS
#

function msg() {
  echo "${@}" >&2
}; declare -rf msg

function die() {
  msg "${@}"
  exit 1
}; declare -rf die

function checksum() {
  envsubst < emby.service | sha256sum | awk '{ print $1 }'
}; declare -rf checksum

function sha256sum() {
  if type -P sha256sum > /dev/null; then
    command sha256sum "${@}"
  elif type -P shasum > /dev/null; then
    command shasum -a 256 "${@}"
  else
    echo "ERROR: could not find a sha256sum program."
    exit 1
  fi
}; declare -rf sha256sum

#
# MAIN EXECUTION
#

# pre-flight checks before modifying the system
# just adding an extra layer of safety / quality
[ "${USER:-$(whoami)}" = root ] ||
  die 'ERROR: must be run as root to install the systemd service.'
[ -d /lib/systemd ] && type -P systemctl > /dev/null ||
  die 'ERROR: must be run on a system which uses systemd for init.'
type -P envsubst > /dev/null ||
  die 'ERROR: missing gettext package.  "yum install gettext" or "apt install gettext"'
[ -r emby.service ] ||
  die 'ERROR: no emby.service found.  Are you in the right working directory?'
type -P docker > /dev/null && type -P docker-compose > /dev/null ||
  die 'ERROR: Missing Docker or docker-compose.  This is required to run the service.'

# Try to install the service.
if [ -f "${DESTINATION}" ] && sha256sum -c - <<< "$(checksum)  ${DESTINATION}"; then
  msg 'SKIPPED: emby.service is already installed.'
else
  msg 'Installing systemd emby.service.'
  envsubst < emby.service > "${DESTINATION}"
  systemctl daemon-reload
fi

# Give the final help message.
cat >&2 <<'EOF'
With emby.service installed you are now ready to control the service.  This
script only installs the service and does not control the service for you.

This script is idempotent and can be safely run multiple times to see this
message agin.

=== SERVICE CONTROL ===
Start the service.
    systemctl start emby.service
Stop the service.
    systemctl stop emby.service
Ensure the service autostarts on reboot.
    systemctl enable emby.service
Stop the service from autostarting on reboot.
    systemctl disable emby.service

=== DEBUGGING EMBY SERVICE ===
View the current service status.
    systemctl status emby.service
View the systemd logs for the service.
    journalctl -u emby.service
EOF
