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


