#!/usr/bin/env bash
#############################################################
# Sub functions to work with qcow files
#############################################################
# Valeriy Soloviov <weldpua2008@gmail.com>
#############################################################
#   version 1.0.1 (29/8/16) <weldpua2008@gmail.com>
#   - adding debug
#############################################################
if type die 2> /dev/null| grep -i function &> /dev/null; then
	__dieexist=true
else
	die()
	{
	    echo $@
	    exit 2
	}
fi


function mount_qcow(){
	local QCOW_FILE="${1:-}"
	local _QCOW_MOUNTPOINT="${2:-}"
	local _MOUNT_PARTITION="${3:-1}"
	local show_qcowpath=$(lstrip_to_width "$QCOW_FILE" 28||echo "$path")
	local show_mp_qcowpath=$(lstrip_to_width "$_QCOW_MOUNTPOINT" 12||echo "$path")
	set +e
    # load ndb if need
    ${SUDO} lsmod 2> /dev/null |grep -wq nbd || (${SUDO} modprobe nbd max_part=${max_part:-8} || die "   -> nbd modules [FAILED]")
    echon_str " -> Mounting QCOW by path..."
    
     [[ "x${_QCOW_MOUNTPOINT}" = "x" ]] && die "\$_QCOW_MOUNTPOINT is empty"
    # while mount | grep nbd${nodeIndx} > /dev/null
    # do nodeIndx=$(( ${nodeIndx} + 1 )) 
    # done

    # if [ $nodeIndx -gt 9 ]; then
    #   echo "No qemu-nbd nodes available. Free one than try again."
    #   exit 100
    # fi
    __try_mount=0
    for x in /sys/class/block/nbd[0-9]{1,} ; do     	
        S=$(cat $x/size)
        if [ "$S" = "0" ] ; then
        	((__try_mount=__try_mount+1))
        	IS_MOUNTED="no"
            dev_name=$(basename $x)
            ${SUDO} qemu-nbd -d /dev/${dev_name} >/dev/null || true
            echo_str "  ->>connecting ${show_qcowpath} to /dev/${dev_name}..."
            ${SUDO} qemu-nbd -c /dev/${dev_name} "${QCOW_FILE}" >/dev/null &&  IS_MOUNTED="yes" ||   ${SUDO} qemu-nbd -d /dev/${dev_name} >/dev/null
            if [ "${IS_MOUNTED:-no}" != "yes" ];then
            	echo "[FAIL]"
            	continue
            fi
            echo_success
            break
        fi
    done
    [[ "${IS_MOUNTED:-no}" != "yes" ]] && die "	->Failed to connect ${QCOW_FILE} to nbd, tried $__try_mount times"
        
    sleep 5
    echo_str " ->>Mounting ${show_qcowpath} at ${show_mp_qcowpath} ..."
    local _mount_devpartition="/dev/${dev_name}p${_MOUNT_PARTITION}"
    # ${SUDO} qemu-nbd -c /dev/nbd${nodeIndx} vDP_BSP_SKELETON_BOOT.qcow2
    [[ ! -d "${_QCOW_MOUNTPOINT}" ]] && ${SUDO} mkdir -p "${_QCOW_MOUNTPOINT}"
    ${SUDO} mount ${_mount_devpartition} "${_QCOW_MOUNTPOINT}" >/dev/null|| die "Can't mount ${_mount_devpartition} at ${_QCOW_MOUNTPOINT}"
    echo_success
}

# unmounting qcow image and disconnecting it by path to file
function umount_qcow_bypath(){
	local QCOW_FILE="${1:-}"
	local show_qcowpath=$(lstrip_to_width "$QCOW_FILE" 22||echo "$path")
	set +e
	if [ "x${QCOW_FILE}" != "x" ];then
		echon_str " -> Unmounting qcow $show_qcowpath by path..."
		for x in /sys/class/block/nbd[0-9]{1,} ; do 
	        S=$(cat $x/size)
	        if [ "$S" != "0" ] ; then
	        	dev_name=$(basename "$x")
	        	# continue if link is wrong
	        	[[ ! -f "/sys/class/block/${dev_name}/pid" ]] && continue	        	
	        	_nbd_pid=$(${SUDO}  echo /proc/*/task/$(cat "/sys/class/block/${dev_name}/pid" 2>/dev/null)|head -1|cut -d'/' -f3)
	        	[[ "x${_nbd_pid}" = "x" ]] && continue
	        	if  [[ $(${SUDO}  ps -f -p${_nbd_pid} 2>/dev/null|grep "${QCOW_FILE}") ]];then 	        				        		
	        		[[ "$dev_name" = "/" || "x$dev_name" = "x"  ]] && continue
	        		echo_str " >>Unmounting /dev/$dev_name ..."
	        		msg="[DONE]"
	        		for _mounteddev in $($SUDO mount 2>/dev/null| grep ^/dev/${dev_name} |awk '{print $1}' );do 
	        			msg=""
	        		    [[ "$_mounteddev" = "/dev" || "x$_mounteddev" = "x"  ]] && continue
	        			echo -n " $_mounteddev..."
	        			$SUDO umount $_mounteddev && echo_success || echo "[FAIL]"
	        		done
	        		# fix 
	        		sleep 1
	        		echo "$msg"
	        		echo_str " ->>Disconnecting /dev/$dev_name ..."
	        		[[ $($SUDO mount 2>/dev/null| grep ^/dev/${dev_name}  ) ]] && msg="[FAIL]"	        		
	        		${SUDO} qemu-nbd -d /dev/$dev_name >/dev/null ||msg="[FAIL]"
	        		echo "$msg"
	        	fi
	        fi
	    done
	fi
}
