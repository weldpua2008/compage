#!/usr/bin/env bash
#############################################################
# Sub functions to work with Apache Hadoop YARN
#############################################################
function kill_yarn_applications(){
    local APPLICATION=${1:-}
    local APP_STATES=${2:-NEW,NEW_SAVING,SUBMITTED,ACCEPTED}    
    local USER=${3:-}
    set -o pipefail || true
       
    [ "x${APPLICATION:-}" = "x"  ] && APPLICATION="application"
    ${SUDO} yarn application -list -appStates ${APP_STATES} | grep "^${APPLICATION}" | ${SUDO} xargs -n 1 -I % ${SUDO} yarn application -kill "%"
    return 0    
}
