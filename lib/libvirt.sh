#!/usr/bin/env bash
#############################################################
# Sub functions to manage Virsh/libvirt/KVM
#############################################################
function libvirt_stopvm()
{
	local LIBVIRT_GUEST=${1:-}
	[ "${LIBVIRT_GUEST}" = "" ] && return 1
	$SUDO virsh destroy $LIBVIRT_GUEST || return 2
	return 0
}
function libvirt_removevm()
{
	local LIBVIRT_GUEST=${1:-}
	[ "${LIBVIRT_GUEST}" = "" ] && return 1
	libvirt_stopvm "${LIBVIRT_GUEST}" || true
	$SUDO virsh undefine $LIBVIRT_GUEST || return 2
	return 0
}

kvm_check_extentions()
{
  local ext=$($SUDO egrep -m1 -w '^flags[[:blank:]]*:' /proc/cpuinfo | egrep -wo '(vmx|svm)')
  if [[ -z $ext ]];then
     echo "\nWARNING: your CPU does not support KVM extensions." 
     return 1
  fi
  $SUDO modprobe msr &>/dev/null

  local kvm=1
  case $ext in
       # Intel based CPUs
       "vmx")  local bit=$(rdmsr --bitfield 0:0 0x3a 2>/dev/null)
               if (($bit == 1)); then
                   bit=$(rdmsr --bitfield 2:2 0x3a 2>/dev/null)
                   (($bit == 0)) && kvm=0
               fi
               ;;

       # AMD based CPUs
       "svm") local bit=$(rdmsr --bitfield 4:4 0xc0010114 2>/dev/null)
              (( $bit == 1 )) && kvm=0
              ;;
  esac

  if (($kvm == 0));then
      echo  "\nWARNING: Hardware Acceleration($ext) is disabled by BIOS."  
      return 2
  fi
  return 0
}

libvirt_console(){
	#clear
  	$SUDO virsh console --force $@ || return 1
  	return 0
}

#virsh domiflist
#virsh domblklist
#virsh nodememstat
#virsh  nodecpustats --percent
#virsh nodeinfo
