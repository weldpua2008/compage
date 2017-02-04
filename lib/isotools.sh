#!/usr/bin/env bash
#############################################################
# Sub functions to work with iso
#############################################################
# Valeriy Soloviov <weldpua2008@gmail.com>
#############################################################
isotools_create(){
	local source_tree=$1
	local target_iso=$2
	$SUDO mkisofs -r -J -joliet-long -o $target_iso $source_tree || return 1
	return 0
}

isotools_create_with_isolinux(){
	local source_tree=$1
	local target_iso=$2
	local isohdpf=${3:-isolinux/isohdpfx.bin}
	cd $path_to_iso_src
	$SUDO xorriso -as mkisofs -r -J -joliet-long -l -cache-inodes \
-isohybrid-mbr $isohdpf -partition_offset 16 \
-A "Application ISO"  -b isolinux/isolinux.bin -c \
isolinux/boot.cat -no-emul-boot -boot-load-size 4 \
-boot-info-table -o $target_iso . 
 [ $? -ne 0 ] && return 1 

 return 0
}

