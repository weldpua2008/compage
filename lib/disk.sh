#!/usr/bin/env bash
#############################################################
# Sub functions to work with disk
#############################################################
function find_bleckdevice(){
  local chosen_block_dev
  local b_device_size
  local b_device
  local byte=$((1024**3))
  local HDD_MIN_SIZE_GB=${1:-0}
  local min_size_b=$((${HDD_MIN_SIZE_GB:-0}*$byte))

  # iterate over sysfs entries and find eligable block device 
  for b_device in $(sfdisk -s|grep -v total |sed -r 's/\/dev\/([a-z].*):.*/\1/g');do
      if (( $(cat /sys/block/$b_device/removable) == 0 ));then
          size_b=$(blockdev  --getsize64 /dev/$b_device)
          if (( $size_b >= $min_size_b ));then
             chosen_block_dev=/dev/$b_device
             break
          fi
      fi
  done
  # not found - return error
  [ -z "$chosen_block_dev" ] && return $HDD_SPACE_ERROR
  # prepare the chosen block device
  _prepare_block_device $chosen_block_dev || return $HDD_PART_ERROR
  # deploy rootfs
  if [[ $MODE == "production" ]];then
    _deploy_rootfs_persist $chosen_block_dev || return $DEPLOY_ROOTFS_ERROR
  else
    _deploy_rootfs $chosen_block_dev || return $DEPLOY_ROOTFS_ERROR
  fi
}

#---------------------------------------------------------------------------
# Disable SCSI WRITE_SAME, which is not supported by underlying disk
# emulation.  Run on boot from, eg, /etc/rc.local
#
# See http://www.it3.be/2013/10/16/write-same-failed/
#
# Written by Ewen McNeill <ewen@naos.co.nz>, 2014-07-17
#---------------------------------------------------------------------------
function disable_write_same(){
	find /sys/devices -name max_write_same_blocks |
    while read DISK; do
        $SUDO echo 0 >"${DISK}"
    done
}


# create_raw_image()
# {
#   local WORK_DIR=${1:-/tmp/$$}
#   local path_to_raw_image=$WORK_DIR/base.img

#   dd if=/dev/zero of=$path_to_raw_image bs=1 count=1 seek=${HDD_SIZE}G || return 1
#   FREE_LOOP_DEVICE=$($SUDO losetup -f)
#   $SUDO losetup $FREE_LOOP_DEVICE $path_to_raw_image

#   $SUDO parted --script $FREE_LOOP_DEVICE mktable msdos
#   $SUDO parted --script --align optimal $FREE_LOOP_DEVICE mkpart primary ext4 1MiB 1536MiB mkpart primary ext4 1536MiB 96% mkpart primary linux-swap 96% 100%
#   $SUDO parted --script $FREE_LOOP_DEVICE set 1 boot on
#   $SUDO kpartx -av $FREE_LOOP_DEVICE

#   local free_loop_name=${FREE_LOOP_DEVICE##/dev/}
#   local loop_root_partition=${free_loop_name}p1
#   local loop_apps_partition=${free_loop_name}p2
#   local loop_swap_partition=${free_loop_name}p3

#   [ ! -e /dev/mapper/$loop_root_partition ] && {
#    echo "FATAL: loop device doesn't have any partitons"
#    return 1
#   }
 
#   mkfs.ext4 /dev/mapper/$loop_root_partition
#   e2fsck -y -f /dev/mapper/$loop_root_partition
#   e2label /dev/mapper/$loop_root_partition ROOT

#   mkfs.ext4 /dev/mapper/$loop_apps_partition
#   e2fsck -y -f /dev/mapper/$loop_apps_partition
#   e2label /dev/mapper/$loop_apps_partition APPS

#   mkswap -f -L SWAP /dev/mapper/$loop_swap_partition

# #  local MOUNT_POINT=$(mktemp -d $BUILD_ROOT/XXXXX --suffix _loop_mnt)
#   MOUNT_POINT=`mktemp -d $MPOINT`
#   mount /dev/mapper/$loop_root_partition $MOUNT_POINT
#   unsquashfs -d $MOUNT_POINT/extracted $WORK_DIR/rootfs-va.squashfs
#   mv $MOUNT_POINT/extracted/* $MOUNT_POINT
#   rm -rf $MOUNT_POINT/extracted
#   mount /dev/mapper/$loop_apps_partition $MOUNT_POINT/var/lib/lxc

#   local rand_name=$(uuidgen|awk -F- '{print $1}')
#   echo "vp-$rand_name" > $MOUNT_POINT/etc/hostname
#   sed -i "s/rdwr-virt-platform/vp-$rand_name/g" $MOUNT_POINT/etc/hosts
 
#   mount --bind /dev $MOUNT_POINT/dev
#   chroot $MOUNT_POINT mount -t proc none /proc
#   chroot $MOUNT_POINT mount -t sysfs none /sys

#   }
vmdk_from_raw()
{
  local path_to_raw_image_sys=${1:-raw.img}
  local path_to_vmdk_image_sys=${2:-disk1.vmdk}
  
  $SUDO qemu-img convert -p -O vmdk  $path_to_raw_image_sys ${path_to_vmdk_image_sys}_v4 || return 1
  # rm -f $path_to_raw_image_sys
  $SUDO vmware-vdiskmanager -r ${path_to_vmdk_image_sys}_v4 -t 5 $path_to_vmdk_image_sys || return 2
  # rm -f ${path_to_vmdk_image_sys}_v4
  return 0
}
