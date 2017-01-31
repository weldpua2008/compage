#!/usr/bin/env bash
#############################################################
# Sub functions to work with apt-key
#############################################################

# get $1 repo that we need check
function is_aptkeyexist(){
    local KEY="$1"
    # key was not specified
    [ "$KEY" = "" ] && return 127            
    ${SUDO} apt-key list 2>/dev/null|grep -w "${KEY}"  &> /dev/null
    # KEY FOUND
    [ $? -eq 0 ] && return 0
    # KEY NOT FOUND
    return 1
}