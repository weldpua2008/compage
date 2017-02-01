#!/usr/bin/env bash
#############################################################
# Sub functions to work with ssh
#############################################################
sshkeys_chroot()
{
  local MOUNTP=$1
  chroot $MOUNTP /bin/bash -x <<'EOF'
     rm /etc/ssh/ssh_host*key* || true
     ssh-keygen -q -f /etc/ssh/ssh_host_key -N '' -t rsa1 || return 1
     ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa || return 2
     ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa || return 3
     ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa -b 521 || return 4
EOF

}
