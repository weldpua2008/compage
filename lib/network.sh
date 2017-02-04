#!/usr/bin/env bash
#############################################################
# Sub functions to work with ip, network
#############################################################

# (echo $IP | grep -Eq '^[1-9][0-9]{0,2}\.[1-9][0-9]{0,2}\.[1-9][0-9]{0,2}\.[1-9][0-9]{0,2}$') && echo $IP || (echo "No IP defined" && exit 1)

valid_ipv4()
{
  local ip=$1
  local stat=1

  if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
      OIFS=$IFS
      IFS='.'
      ip=($ip)
      IFS=$OIFS
      ((${ip[0]} <= 255 && ${ip[1]} <= 255 && ${ip[2]} <= 255 && ${ip[3]} <= 255))
      stat=$?
   fi
   return $stat
}

valid_mask()
{
  local mask=$1
  grep -E -q '^(254|252|248|240|224|192|128)\.0\.0\.0|255\.(254|252|248|240|224|192|128|0)\.0\.0|255\.255\.(254|252|248|240|224|192|128|0)\.0|255\.255\.255\.(254|252|248|240|224|192|128|0)' <<< "$mask"
  return $?
}


network_nics_amount(){
  local amount=$($SUDO find /sys/class/net/ -name "eth[0-9]" 2> /dev/null|wc -l)
  echo $amount
}

network_taps_amount(){
   local amount=$($SUDO /sys/class/net -name "tap[0-9]"|wc -l)
   echo $amount
}

network_isbridge(){
    local brName=${1:-}
    [ -d /sys/class/net/${brName} ] && return 0
    return 1
}

# nics_ip(){
#   $SUDO ip a li dev $PUBLIC_INTERFACE |grep "inet " |awk -F '[ /]+' '{print $3}'
# }

# echo "cleaning up udev rules"
# rm /etc/udev/rules.d/70-persistent-net.rules
# mkdir /etc/udev/rules.d/70-persistent-net.rules
# rm -rf /dev/.udev/
# rm /lib/udev/rules.d/75-persistent-net-generator.rules

## delete old-style interface
#tunctl -d $INTERFACE &> /dev/null
#ip tuntap del mode tap $INTERFACE &> /dev/null

network_add_bridge(){
    local INTERFACE=${1:-br0}
    $SUDO brctl addbr $INTERFACE || return 1
    $SUDO brctl setfd  $INTERFACE 0 || return 2
    $SUDO brctl stp $INTERFACE off || return 3
# iptables -A FORWARD -p all -i $INTERFACE -j ACCEPT
    $SUDO ip link set $INTERFACE up || return 4
    
    return 0
}

network_iface_by_indx()
{
	local indx=${1:-2}
	$SUDO ip link |awk -F: '/^'${indx:-2}':/{gsub(" ","") ;print $2}'
}
network_iface_ip(){
	local iface=${1:-}
	# ifconfig $iface 2>/dev/null | grep -Eo "inet (addr:)?([0-9]*\.){3}[0-9]*" | grep -Eo "([0-9]*\.){3}[0-9]*"

}
network_iface_mask(){
	local iface=${1:-}
	#ifconfig $iface 2>/dev/null | grep -Eo ' (Mask:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*'
}
network_iface_maddr(){
	local iface=${1:-}
	local name_space=${2:-}
	[ "$name_space" ="" ] && \ 
	$SUDO  ip address show $iface 2> /dev/null| grep -F \"link/ether\" | awk '{FS=\" \"; print $2}' || \
	$SUDO ip netns exec $name_space ip address show $iface 2> /dev/null| grep -F \"link/ether\" | awk '{FS=\" \"; print $2}'
}
#first_dns=`cat /etc/resolv.conf | grep -i nameserver | grep -Eo '([0-9]*\.){3}[0-9]*' | head -1`
#second_dns=`cat /etc/resolv.conf | grep -i nameserver | grep -Eo '([0-9]*\.){3}[0-9]*' | head -2 | tail -1`
#search_pfx=`cat /etc/resolv.conf  | grep search | awk '{print $NF}'`


# All nics 
#ip -d -o link list 2> /dev/null|grep -e "[0-9]: "|awk -F " " '{print $2}'|sed "s/://g"

#  Bridges have those folders
# "/sys/class/net/%s/master" or "/sys/class/net/%s/brport" or "/sys/class/net/%s/bridge"
# TUN and TAP devices have a /sys/class/net/tap0/tun_flags file

# Macvtap
# ip -d -o link show  $iface| grep '@'
# ip -d -o link show $iface|sed 's/^[^>]*>//'|grep -w macvtap

# Dummy
# ip -d -o link show $iface|sed 's/^[^>]*>//'|grep -w dummy 

network_linkstate(){
	local iface=${1:-}
	local name_space=${2:-} 
	[ "$name_space" ="" ] && \
		$SUDO ip link show $iface 2> /dev/null|grep -e \"[0-9]: \"  | awk '{FS=\" \"; print $9}' || \
		$SUDO ip netns exec $name_space ip link show $iface 2> /dev/null|grep -e \"[0-9]: \"  | awk '{FS=\" \"; print $9}'
}
network_prepare_ns(){
	local pid=${1:-$$}
	$SUDO rm -f /var/run/netns/$pid || return 1
	$SUDO mkdir -p /var/run/netns/ || return 2
	$SUDO ln -s /proc/$pid/ns/net /var/run/netns/$pid || return 3
	return 0

}