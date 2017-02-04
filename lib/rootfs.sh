#!/usr/bin/env bash
#############################################################
# Sub functions to work with rootfs
#############################################################
# Valeriy Soloviov <weldpua2008@gmail.com>
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

function rootfs_extract(){
    local _ROOTFS_IMGGZ="${1:-}"
    local DEST="${2:-}"
    local show_path_image=$(lstrip_to_width "$_ROOTFS_IMGGZ" 10||echo "$_ROOTFS_IMGGZ")
    local show_path_dest=$(lstrip_to_width "$DEST" 13||echo "$DEST")

    echon_str " -> Extracting rootfs image $(basename ${_ROOTFS_IMGGZ:-rootfs.img.gz}) ..."
    [[ "x${_ROOTFS_IMGGZ}" = "x" ]] && die "The \$_ROOTFS_IMGGZ is undefined"  

  	echo_str "  -> Extracting ${show_path_image} to ${show_path_dest} ... "
	case $_ROOTFS_IMGGZ in
		*img.gz)
			[[ -f "${_ROOTFS_IMGGZ%.*}" ]] && $SUDO rm -f "${_ROOTFS_IMGGZ%.*}" 2>/dev/null ||true 
			yes| $SUDO gunzip -f "${_ROOTFS_IMGGZ}" || die " Can't gunzip ${_ROOTFS_IMGGZ}"
			cd "$DEST" || die " Can't gunzip to  ${DEST} because can't change folder"			
			$SUDO cpio -i <  "${_ROOTFS_IMGGZ%.*}" &>/dev/null || die " cpio -i < ${_ROOTFS_IMGGZ%.*}"
			cd "${OLDPWD}" ||true
		;;
		*)
			die "Unsupported extention rootfs: ${_ROOTFS_IMGGZ##.*}"
		;;
	esac    
  	echo_success
}


function chroot_update_grub()
{ 
  local chroot=$1
  local block_device=$2

  $SUDO mount --bind /dev  $chroot/dev  || return 1
  $SUDO mount --bind /proc $chroot/proc || return 1
  $SUDO mount --bind /sys  $chroot/sys  || return 1
  $SUDO chroot $chroot grub-install $block_device || return 2
  $SUDO chroot $chroot update-initramfs -u -k $(uname -r)  &> /dev/null  || return 3
  $SUDO chroot $chroot update-grub || return 4
  $SUDO chroot $chroot ln -sf /boot/vmlinuz* /vmlinuz || return 5
  $SUDO chroot $chroot ln -sf /boot/initrd.img* /initrd.img || return 5
  $SUDO umount -l $chroot/{dev,proc,sys} &>/dev/null || true
  $SUDO umount -l $chroot/{dev,proc,sys} &>/dev/null  || true

  return 0
}
