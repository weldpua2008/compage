#!/usr/bin/env bash
#############################################################
# Sub functions to work with checkmk
#############################################################

checkmk_addhost(){
	local user=$1
	local secret=$2
	local checkmk=$3
	local host=$4

	echo "Adding $host to check_mk"
	$SUDO curl -s "http://${checkmk}/radware/check_mk/webapi.py?action=add_host&_username=${user}&_secret=${secret}" -d 'request={ "hostname": "'"${host}"'", "folder": ""}' || return 1

	echo "Discovering services"
	$SUDO curl -s "http://${checkmk}/radware/check_mk/webapi.py?action=discover_services&_username=${user}&_secret=${secret}&mode=refresh" -d 'request={"hostname": "'"${host}"'"}' || return 2

	echo "Activating changes"
	$SUDO curl -s "http://${checkmk}/radware/check_mk/webapi.py?action=activate_changes&_username=${user}&_secret=${secret}" || return 3
	return 0

}
