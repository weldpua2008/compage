#!/usr/bin/env bash
#############################################################
# Build Script SDK
#############################################################
# Valeriy Solovyov <weldpua2008@gmail.com>
#
# Description:
# ------------
# This script is  a generic  skeleton for  build script  with
# useful functions and libraries.
#
# Designed  to  run set of  build steps  which are discovered
# recursively  inside  the project directory , according it's
# version and modification/branch.
#############################################################
#  version 1.0.22
#	- fixing success on fail

###################################
# THIS VARIABLES SHOULD BE EXPORTED
# IN YOU ENVIROMENT (JENKINS/SSH/ETC)
###################################
# use: export VAR_NAME="value"
#
# Required variables
# ------------------
# PRODUCT_NAME
# MAJOR_RELEASE
# VERSION
# CUSTOM_MODIFICATION
#
# Example:
# --------
# PRODUCT_NAME="ExampleProject"
# MAJOR_RELEASE="1"
# VERSION="1.1.1"
# CUSTOM_MODIFICATION="fix1"


# internal variables
__RUNFILE=$(readlink -f "${BASH_SOURCE[0]}")
readonly RUN_DIR="$( dirname "${__RUNFILE}" )"
if [ "x${RUN_DIR}" = "x" ];then
    echo "Can't detect \$RUN_DIR"
    exit 100
fi

LOCKFILE="$RUN_DIR/build.lock"
LOCK_FD=100

INCLUDE=(
    "$RUN_DIR/lib/functions"    
    "$RUN_DIR/lib/optparse/optparse.bash"
    "${RUN_DIR}/lib/filysystem.sh"
    "${RUN_DIR}/lib/archive.sh"
    "${RUN_DIR}/lib/rootfs.sh"
    "${RUN_DIR}/lib/get_artifact.sh"
    "${RUN_DIR}/lib/qcow.sh"
)

# import all libraries
for ((i = 0; i < ${#INCLUDE[@]}; i++)); do
    if [ ! -e "${INCLUDE[$i]}" ]; then
        echo "ERROR: ${INCLUDE[$i]} library is missing"
    else
        source "${INCLUDE[$i]}"
    fi
done

# load getopts
opts=$(discover "getopts.sh")
source $opts
source $(optparse.build)

# use sudo if needed
[ "${USE_SUDO:-false}" == "true" ] && SUDO=$(which sudo 2> /dev/null||echo "sudo") || SUDO=""

# log to file
[ "x${LOG_FILE:-}" != "x" ] && logToFile

# use lock if needed
if [ "${USE_LOCK:-false}" == "true" ]; then
    lock || die "Only one instance can run at a time"
fi

function cleanup() {
    require_file "cleanup.sh"
}

function initVariables() {
    require_file "init_vars.sh"
}

function on_exit()
{
    local _exit_code=${1:-1}

    [ "${USE_LOCK:-false}" == "true" ] && lock_remove
    # [[ $exit_code -eq 126 || $exit_code -eq 127 ]] && exit $exit_code

    cleanup
    echo ""
    echo "###############################"

    if [[ $_exit_code -eq 0 ]]; then
        echo "JOB FINISHED SUCCESSFULY"
    else
        echo "JOB FAILED"
    fi

    exit $_exit_code
}

# setup trap function
function sigHandler()
{
    if type on_exit | grep -i function &> /dev/null; then
        trap 'on_exit $?' EXIT
    else
        echo "ERROR: on_exit function is not defined"
        exit 127
    fi

    # run clenup function
    trap cleanup HUP TERM INT
}

function main() {
    require_file "_build_steps.sh"
}

# FLOW START
sigHandler
initVariables
main
