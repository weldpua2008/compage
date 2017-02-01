#!/usr/bin/env bash
#############################################################
# Sub functions to work with lxc
#############################################################
#  if $SUDO test -f "/root/.ssh/known_hosts"; then
#     echo "adding new ssh RSA key fingerprint"
#     $SUDO ssh-keygen -f /root/.ssh/known_hosts -R localhost || true
#  fi
#  $SUDO ssh-keyscan -H localhost >> /root/.ssh/known_hosts || true

# # adding key if need
# if  $SUDO test -f "/root/.ssh/id_rsa.pub";then
#   $SUDO ssh-keygen -b 2048 -t rsa -f /root/.ssh/id_rsa -N ""
# fi
# # Check the ssh connection to localhost and add auth key
# $SUDO ssh -o PasswordAuthentication=no  root@localhost ls /
# if [ $? -ne 0 ];then
#     $SUDO cat /root/.ssh/id_rsa.pub | $SUDO tee -a  /root/.ssh/authorized_keys
# fi
# $SUDO cat /root/.ssh/id_rsa.pub | $SUDO tee -a $LXC_DIR/$NEW/root/.ssh/authorized_keys
# $SUDO chroot $LXC_DIR/$NEW bash -c 'echo -e "\n" |  ssh-keygen -N "" -t rsa'
# Start LXC with ssh connection to 
# ssh  -o PasswordAuthentication=no root@localhost lxc-start -n ${NEW} -d
# $SUDO lxc-wait -n ${LXC_NAME} -s 'RUNNING|STOPPED' -t 5 || true

##############################################################
# lxc-ls -f -F name,state,ipv4 
##############################################################
lxc_ip(){
	local LXC_CT=${1:-}
	$SUDO lxc-ls -f -F ipv4 $NEW |tail -1 |tr -d ' '
	return $?
}

lxc_name(){
	local LXC_CT=${1:-}
	local wait_timeout=${2:-5}
	$SUDO lxc-wait -n ${LXC_CT} -s 'RUNNING|STOPPED' -t ${wait_timeout:-5} 
	return $?
}

 