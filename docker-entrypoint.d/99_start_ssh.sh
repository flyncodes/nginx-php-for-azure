#!/bin/bash

mkdir -p /var/run/sshd
/usr/sbin/sshd

# add ssh to upstart
if [[ -f /etc/service/sshd/down ]]; then
    rm -f /etc/service/sshd/down
fi
