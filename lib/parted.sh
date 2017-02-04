#!/usr/bin/env bash
#############################################################
# Sub functions to work with parted
#############################################################
function parted_mkgpt(){
	local block_dev=$1
	$SUDO  parted --script $block_dev mktable gpt mklabel gpt || return 1
	return 0
}

# 
#  parted --script --align optimal $block_dev mkpart primary 1MiB 3MiB mkpart primary fat32 3MiB 300MiB mkpart primary ext4 300MiB ${rootfs_end}MiB mkpart primary ext4 ${rootfs_end}MiB ${persist_end}MiB mkpart primary linux-swap ${persist_end}MiB ${swap_end}MiB mkpart primary ext4 ${swap_end}MiB 100% && \
#  parted --script --align optimal $block_dev name 1 bios name 2 efi name 3 flash name 4 persistence name 5 swap name 6 storage && \
#  parted --script --align optimal $block_dev set 1 bios_grub on set 6 lvm on && \
#  partprobe $block_dev 
#  mkswap -L SWAP ${block_dev}5
#  mke2fs -F -t ext2 ${block_dev}1
#  mkdosfs -F 32 -I ${block_dev}2
#  mke2fs -F -t ext4 -L $ROOTFS_LABEL ${block_dev}3
#  mke2fs -F -t ext4 -L $PERSISTENCE_LABEL ${block_dev}4
#  mke2fs -F -t ext4 -b 4096 -L STORAGE /dev/VolGroupVP/storage
