#!/usr/bin/env bash
#############################################################
# Sub functions to manage processes
#############################################################

process_get_pids_byname(){
	local pid_name="${1:-}" # e.g. sshd.*tty
	$SUDO ps waxl|grep 'sshd.*tty'|grep -v grep|awk '{print $3}'	
}

