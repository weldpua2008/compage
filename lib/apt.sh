#!/usr/bin/env bash
#############################################################
# Sub functions to work with apt
#############################################################
# get $1 repo that we need check
#	  $2 distribution of repo
function is_aptrepoexist(){
    local REPO=${1:-}
    local DISTRIBUTION=${2:-}
    
    if [ "x${REPO:-}" != "x"  ] && [ "x${DISTRIBUTION}" != "x" ];then
    	${SUDO} find /etc/apt/ -name "*.list" | xargs cat | grep  ^[[:space:]]*deb[[:space:]][^[:space:]]*${REPO}[^[:space:]]*[[:space:]]${DISTRIBUTION}[^[:space:]]*  &> /dev/null
        [ $? -eq 0 ] && return 0        
        return 1
    elif [ "x${REPO:-}" != "x"  ]; then    	
        #${SUDO} find /etc/apt/ -name "*.list" | xargs cat | grep  ^[[:space:]]*deb | grep -w "${REPO}" &> /dev/null
        ${SUDO} find /etc/apt/ -name "*.list" | xargs cat | grep  ^[[:space:]]*deb[[:space:]][^[:space:]]*${REPO}[^[:space:]]*[[:space:]] &> /dev/null
        [ $? -eq 0 ] && return 0        
        return 1
    fi 
    echo "repository was not specified right ${REPO}"
    return 127
    
}


function install_deb(){
    set +e
    local command="$1"
    local installation_src="$2"    
    which ${command} &>/dev/null
    if [ $? -ne 0 ];then
        ${SUDO} apt-get --no-install-recommends install -y ${installation_src}
    fi
    set -e

}


