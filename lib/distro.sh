#!/usr/bin/env bash
#############################################################
# Sub functions to work with Distributions
#############################################################
# Valeriy Soloviov <weldpua2008@gmail.com>
#############################################################
distro_isubuntu(){
	$SUDO sh -c "lsb_release -sd || cat /etc/*release /etc/issue"|grep -i -E "ubuntu|debian" &>/dev/null
    [ $? -eq 0 ] && return 0
    return 1
}

distro_iscentos(){
	$SUDO sh -c "lsb_release -sd || cat /etc/*release /etc/issue"|grep -i -E "centos|redhat" &>/dev/null
    [ $? -eq 0 ] && return 0
    return 1
}
