#!/usr/bin/env bash
#############################################################
# Sub functions to work with system
#############################################################
total_ram_kb(){
	local total_ram=$(grep MemTotal /proc/meminfo|sed  "s#MemTotal: *\([0-9]*\) *kB#\1#")
	echo $total_ram	
}

total_ram_p(){
	local memory_usage=$($SUDO awk '/^MemTotal:/ {total=$2} /^MemFree:/ {free=$2} /^Buffers:/ {buffers=$2} /^Cached:/ {cached=$2} END { printf("%3.1f%%", (total-(free+buffers+cached))/total*100)}' /proc/meminfo)
	echo $memory_usage
}

swap_usage(){
	local swap_usage=`$SUDO  awk '/^SwapTotal:/ { total=$2 } /^SwapFree:/ { free=$2} END {
    if (total > 0)
        printf("%3.1f%%", (total-free)/total*100) ;
     else
       printf("%d",0);}' /proc/meminfo`
       echo $swap_usage
}

load_avarage(){
	local load_avarage=`$SUDO awk '{print $1}' /proc/loadavg`	
	echo $load_avarage
}

uptime_human(){
	local h_uptime=`awk '{uptime=$1} END {days = int(uptime/86400); hours = int((uptime-(days*86400))/3600); printf("%d days, %d hours", days, hours)}' /proc/uptime`
	echo $h_uptime
}
processes_total(){
	local processes=`/bin/ls -d /proc/[0-9]* | wc -l`
	echo $processes
}

# Regenerate ssh keys if not-exist into SystemD 
# ExecStartPre=-/bin/bash -c '[[ ! -f /etc/ssh/ssh_host_rsa_key || ! -f /etc/ssh/ssh_host_dsa_key || ! -f /etc/ssh/ssh_host_ecdsa_key || ! -f /etc/ssh/ssh_host_ed25519_key ]] && dpkg-reconfigure -f noninteractive  openssh-server'

# get selected timezone
function get_timezone()
{
    # debian workaround to find current timezone
    local tz=$(diff -s /etc/localtime /usr/share/zoneinfo/`cat /etc/timezone 2>/dev/null || echo 'Asia/Jerusalem'`)
    [[ "$tz" =~ ^Files[[:space:]]/etc/localtime[[:space:]]and[[:space:]]/usr/share/zoneinfo/(.*)[[:space:]]are.* ]]
    echo ${BASH_REMATCH[1]}
}

# How to list all variables names and their current values
# http://askubuntu.com/questions/275965/how-to-list-all-variables-names-and-their-current-values
# To show a list including the "shell variables" you can enter the next command:
# ( set -o posix ; set ) | less
# compgen -v
#
# This must print all shell variables names. You can get a list before and after sourcing your file just like with "set" to diff which variables are new (as explained in the other answers). But keep in mind such filtering with diff can filter out some variables that you need but were present before sourcing your file
# for i in _ {a..z} {A..Z}; do eval "echo \${!$i@}" ; done | xargs printf "%s\n"
# pure BASH solution (no external commands used):
# for i in _ {a..z} {A..Z}; do
#    for var in `eval echo "\\${!$i@}"`; do
#       echo $var
#       # you can test if $var matches some criteria and put it in the file or ignore
#    done 
# done
# set -a
# printenv 
# xterm -e bash --noprofile --norc
# declare -p 
# If you're only interested in environment variables, use
# declare -xp
