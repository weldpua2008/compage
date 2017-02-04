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

