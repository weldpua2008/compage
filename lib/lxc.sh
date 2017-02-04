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

lxc_expose_port ()
{
	local PUBLIC_PORT=${1:-}
	local PRIVATE_PORT=${2:-}
#	echo Usage: $0 '<External TCP port> <Service TCP port> <Container name>'
  $SUDO iptables -t nat -A PREROUTING -d ${PUBLIC_IP}  -p tcp  -m tcp --dport ${PUBLIC_PORT} -j DNAT --to ${PRIVATE_IP}:${PRIVATE_PORT} || return 1
  $SUDO iptables -A FORWARD -d ${PRIVATE_IP} -i ${PRIVATE_INTERFACE}  -p tcp -m tcp --dport ${PRIVATE_PORT} -j ACCEPT || return 2
# Already configured via interfaces
#  iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
}

lxc_privateip(){
	local CONTAINER=${1:-}
	[ "$CONTAINER" = "" ]&& return 1
	PRIVATE_IP=$(lxc-ls -f -F ipv4 $CONTAINER 2> /dev/null|head -1 |tr -d ' ')
	[[ ! $PRIVATE_IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] && return 2
	echo $PRIVATE_IP
	return 0
}

lxc_cgroup_show()
{
	local domain=${1:-}
	shift 1
	# Example keys:
	# "cpuset.cpus" "devices.list"
	for key in $@;do
		$SUDO lxc-cgroup --name  $domain $key|| return 1
	done
	return 0
}
