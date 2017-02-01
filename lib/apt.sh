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

function apt_createlist(){
    # echo 'APT::Install-Suggests "0";
    # APT::Install-Recommends "0";'>> /etc/apt/apt.conf
     $SUDO mkdir $1 || return 1
     $SUDO apt-get -d --print-uris -y install -o=dir::cache=$1/ $1 > $1/$1.list || return 2
}

# adding key by path
function apt_addkey()
{
    local apt_key=${1:-}
    local KEY_SERVER=${2:-}
    if [[  -e  "${apt_key}" ]];then
        ${SUDO} cat ${apt_key} |  apt-key add -
    
    # adding apt key by id    
    elif [[  "${KEY_SERVER}" != "" ]]; then
        #statements
        ${SUDO} apt-key adv --keyserver ${KEY_SERVER} --recv $apt_key
    fi

}
