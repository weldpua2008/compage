#!/usr/bin/env bash
#############################################################
# Sub functions to work with pip
#############################################################

function pip_install(){
   
    local install_package="$1"    
    ${SUDO} ${PIP} install ${install_package}
    return $?
}

function pip_install_ge(){
    set +e
    local install_package="$1"
    local install_version="$2"
    ${SUDO} ${PIP} install --upgrade "${install_package}>=${install_version}" #--force-reinstall
    set -e
}


function pip_install_latest(){
   set +e
    local install_package="$1"
    echo "${SUDO} ${PIP} install --upgrade ${install_package}"
    ${SUDO} ${PIP} install --upgrade ${install_package} #--force-reinstall
    set -e
}

function pip_install_version(){
    set +e
    local install_package="$1"
    local install_version="$2"
    echo "${SUDO} ${PIP} install --upgrade ${install_package}==${install_version}"
    ${SUDO} ${PIP} install --upgrade "${install_package}==${install_version}" #--force-reinstall

    # fail on falcon==0.2.0 but install falcon 0.2
    ${SUDO} ${PIP} list 2> /dev/null|grep "${install_package}" |grep "${install_version}" &> /dev/null
    if [ $? -ne 0 ];then
        local first_part=`echo "${install_version}"| cut -d \. -f 1`
        local sec_part=`echo "${install_version}"| cut -d \. -f 2`
        set -e
        ${SUDO} ${PIP} list 2> /dev/null|grep "${install_package}" |grep "${first_part}.${sec_part}" &> /dev/null
    fi
}

function pip_install_fromgit()
{
    local url=${1:-1}
    if [[ "${url}" =~ git+git:// ]];then
    	$SUDO pip install ${url}
    elif [[ "${url}" =~ git:// ]]; then
    	
    	$SUDO pip install git+${url}
    else
    	$SUDO pip install git+git://${url}
    fi
    return $?
}

####################  Create venv  ###########################################################################
#
# 1).setup right PIP variable for ve
#
##############################################################################################################

function create_ve(){
    local PY_VERSION=${1:-2.7}
    local VENV_PATH=${2:-/tmp/virtenv}
     echo " ---- create ve ----- "
    }
    }
    PIP=${VENV_PATH}/bin/pip-${PY_VERSION}
    if ${SUDO} test  ! -x "${PIP}";then
        echo "Can't find  ${PIP} in ve"
        PIP=${VENV_PATH}/bin/pip${PY_VERSION}
        if ${SUDO} test  ! -x "${PIP}";then
            echo "Can't find  ${PIP} in ve"
            exit 1
        fi
    fi

    echo 'Creating "venv" environment...'
    if [ -d ${VENV_PATH} ]; then
        ${SUDO} rm -rf ${VENV_PATH}
    fi

    ${SUDO} mkdir -p ${VENV_PATH}

    # Create virtualenv and install necessary packages
    ${SUDO} virtualenv --no-site-packages --setuptools -p ${PATH_TO_PYTHON_BIN} ${VENV_PATH}
    . ${VENV_PATH}/bin/activate
     echo " ----  ----- "
}
