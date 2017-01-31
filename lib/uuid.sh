
#!/usr/bin/env bash
#############################################################
# Sub functions to work with uuid
#############################################################
generate_uuid(){
    UUID=$($SUDO cat /proc/sys/kernel/random/uuid 2> /dev/null || $SUDO  uuidgen  2> /dev/null|| echo "")

    [ "x${UUID}" = "x" ] && return 1
     echo "${UUID}"
	return 0
}
