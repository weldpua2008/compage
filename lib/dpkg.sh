#!/usr/bin/env bash
#############################################################
# Sub functions to work with apt
#############################################################
# Return version: 
# $1 - dpkg package
function dpkg_get_version(){
    local PACKAGE=${1:-}
    local DISTRIBUTION=${2:-}
    set -o pipefail || true
    if [ "x${PACKAGE:-}" != "x"  ];then
    	${SUDO} dpkg-query --showformat='\${Version}\n' --show ${PACKAGE} 2> /dev/null || return 1
      
      return 0
    fi    
     return 1
}
