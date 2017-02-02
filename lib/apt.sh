#!/usr/bin/env bash
#############################################################
# Sub functions to work with apt
#############################################################
# get $1 repo that we need check
#	  $2 distribution of repo
function is_aptrepoexist(){
    local REPO=${1:-}
    local DISTRIBUTION=${2:-}
    set -o pipefail || true
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

function print_uries_forceinstall()
{
    local PKGs=$1
    local LINKS_FILE=$2
    set -o pipefail || true
    ${SUDO}  apt-get -d --print-uris -y install -f $PKGs  | ${SUDO} tee -a  $LINKS_FILE
    [ ${PIPESTATUS[0]} -ne 0 ] && return 1
    return 0
}
############################################################################################
# print uries with dependencies
############################################################################################
function apt_printuries(){
    local PKG="${1:-}"
    shift 1   
    set -o pipefail || true
    local dependencies=$(apt-cache depends $PKG | grep \"  Depends:\" |  sed 's/  Depends://' | sed ':a;N;$!ba;s/\n//g')
    $SUDO apt-get --print-uris --yes -d  --reinstall $@ install $PKG $dependencies | grep ^\' | cut -d\' -f2 || return 1
    [ ${PIPESTATUS[0]} -ne 0 ] && return 2
    return 0    
}