#!/usr/bin/env bash
#############################################################
# Sub functions to manage users
#############################################################
users_update_root_pw(){
    local ROOT_PASSWORD="${1:-}"
    [ "x${ROOT_PASSWORD}" = "x" ] && exit 1
    set -o pipefail || true
	echo -e "${ROOT_PASSWORD:-password}\n${ROOT_PASSWORD:-password}" | $SUDO passwd root
	return $?
}

users_update_pw(){
	local user=$1
	local passwd=$2
	$SUDO usermod -p "$(echo $passwd | openssl passwd -stdin)" $user || return 1
	return 0 
}
