
#!/usr/bin/env bash
#############################################################
# Sub functions to manage users
#############################################################
update_root_pw(){
    local ROOT_PASSWORD="${1:-}"
    [ "x${ROOT_PASSWORD}" = "x" ] && exit 1
	echo -e "${ROOT_PASSWORD:-password}\n${ROOT_PASSWORD:-password}" | $SUDO passwd root
	return $?
}
