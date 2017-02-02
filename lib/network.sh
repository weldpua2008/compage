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

nics_amount(){
  local amount=$(find /sys/class/net/ -name "eth[0-9]" 2> /dev/null|wc -l)
  echo $amount
}

# nics_ip(){
#   $SUDO ip a li dev $PUBLIC_INTERFACE |grep "inet " |awk -F '[ /]+' '{print $3}'
# }

# echo "cleaning up udev rules"
# rm /etc/udev/rules.d/70-persistent-net.rules
# mkdir /etc/udev/rules.d/70-persistent-net.rules
# rm -rf /dev/.udev/
# rm /lib/udev/rules.d/75-persistent-net-generator.rules
