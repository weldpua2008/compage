
#!/usr/bin/env bash
#############################################################
# Sub functions to work with ip, network
#############################################################
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

