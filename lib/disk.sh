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
