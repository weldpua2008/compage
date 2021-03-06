#!/usr/bin/env bash
#############################################################
# Sub functions to manage processes
#############################################################

process_get_pids_byname(){
	local pid_name="${1:-}" # e.g. sshd.*tty
	$SUDO ps waxl|grep 'sshd.*tty'|grep -v grep|awk '{print $3}'	
}

##################################
# find $DISPLAY for process
##################################
process_get_dispay(){
    #pid=$(ps   -C $process_name -o pid=|head -1| tr -d ' ') 
    local pid=${1:-}
    DISPLAY=$($SUDO cat /proc/$PID/environ 2> /dev/null | strings | awk 'BEGIN{FS="=";} $1=="DISPLAY" {print $2; exit}')
    [ "$DISPLAY" = "" ] && return 1
    echo "$DISPLAY"
    return 0
}

process_getredis_data(){
  # display listen port's
  # $SUDO ps -Af 2> /dev/null|grep redis| awk  '$NF ~ /:/ {split($NF,port,":");print port[2]}'
  n=2
  # display host
  # $SUDO ps -Af 2> /dev/null|grep redis| awk  '$NF ~ /:/ {split($NF,port,":");print port[1]}'
  #n=1
  
  $SUDO ps -Af 2> /dev/null|grep redis| awk  '$NF ~ /:/ {split($NF,port,":");print port['$n']}'|sort|uniq
  
}
