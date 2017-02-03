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