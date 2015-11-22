#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
    echo "This script uses functionality which requires root privileges"
    exit 1
fi

# Start the build with an empty ACI
acbuild --debug begin

# In the event of the script exiting, end the build
trap "{ export EXT=$?; acbuild --debug end && exit $EXT; }" EXIT

# Name the ACI
acbuild --debug set-name samsung-ag/mikeln/ansible-appc

# Based on Samsung-ag ansible-docker
acbuild --debug dep add quay.io/samsung_ag/kraken_ansible

# Add a mount point for files to serve
acbuild --debug mount add etc-inventory-ansible /etc/inventory.ansible
acbuild --debug mount add opt-kraken /opt/kraken
acbuild --debug mount add opt-ansible-private-key /opt/ansible/private_key
acbuild --debug mount add ansible /ansible

# Run apache, and remain in the foreground
acbuild --debug set-exec -- /sbin/my_init

# Write the result
acbuild --debug write --overwrite appc_kraken_ansible.aci
