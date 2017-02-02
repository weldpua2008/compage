#!/usr/bin/env bash
#############################################################
# Sub functions to get artifacts
#############################################################
# Valeriy Soloviov <weldpua2008@gmail.com>
#############################################################
#   version 1.0.1 (29/8/16) <weldpua2008@gmail.com>
#   - adding debug
#############################################################

if type die 2> /dev/null| grep -i function &> /dev/null; then
    __dieexist=true
else
    die()
    {
        echo $@
        exit 2
    }
fi

# avoid exists path
function _prepare_output_path_clean()
{    
    local OUTPUT="${1:-}"    
    local step=0
    local _file="$(basename "${1:-}")"
    
    while [[ -d "${OUTPUT}" ]]; do       
        if [ "${OUTPUT:$((${#OUTPUT}-1)):1}" = '/' ];then
            OUTPUT+="${_file}"
        else
            OUTPUT+="/${_file}"
        fi
    done

    if [ "${OUTPUT:$((${#OUTPUT}-1)):1}" = '/' ];then
        OUTPUT+="${_file}"
    fi

    while [[ -f "${OUTPUT}" ]]; do        
        step=$((step+1))
        OUTPUT="${OUTPUT}${step}"
    done   
    echo "${OUTPUT}"

}

# prepare path
# if $1 - folder OUTPUT=$1/$(basename "$1")
# else - OUTPUT=$1
function _prepare_output_path()
{    
    local OUTPUT="${1:-}"    
    local step=0
    local _file="$(basename "${1:-}")"
    if [ -d "${OUTPUT}" ];then
       local OUTPUT="${OUTPUT}/${_file}"
    fi    
    echo "${OUTPUT}"

}

function wget_url()
{

    local URL="$1"
    local OUTPUT="${2:-}"
    set -e
    echo_str "  -> Downloading from URL: ${URL} ..."    
    case $OUTPUT in 
        '' ) 
            $SUDO wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 3 "${URL}" &> /dev/null
            ;;
        * ) $SUDO wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 3 "${URL}" -O "$(_prepare_output_path "${2:-}")" &> /dev/null
            ;;
    esac
    echo_success
}

function curl_url()
{
    local URL="$1"
    local OUTPUT="${2:-}"
    set -e
    echo_str "  -> Downloading from URL: ${URL} ..."
    case $OUTPUT in 
        '' ) 
            $SUDO curl -L -O "${URL}" &> /dev/null
            ;;
        * )  
            $SUDO curl -L "${URL}" -o "$(_prepare_output_path "${2:-}")" &> /dev/null
            ;;
    esac
    echo_success
}

function get_url()
{
    local URL="$1"
    local OUTPUT="${2:-}"
    set +e
    local get_manager=$(which wget 2> /dev/null||which curl 2> /dev/null)
    # get_manager=$(which wget 2> /dev/null||which curl 2> /dev/null)   
    case $get_manager in
        *wget )
            wget_url $@;;
        *curl )
             curl_url $@;;
        * )
            die "ERROR: wget and/or curl command missing"            
            ;;
    esac    
    echo_success
}

function get_ftp()
{
    get_url $@
}

# helper function
function _ga_copy_files()
{
    local src="${1:-}"
    local dest="${2:-}"
    set -e
    echo_str "  -> Copying from $(basename ${src:-source}) to ${dest} ..."
    $SUDO cp "${src}" "${dest}"
    echo_success
}

function get_file_from()
{
    local src=$1
    local dest=$2
    local name=$3 || 'file'

    echo_str " - Getting $name"
    if [[ "${src}" =~ http:// || "${src}" =~ https:// ]]; then
        get_url "${src}" "${dest}"
    elif [[ "${src}" =~ ftp:// ]]; then
        get_ftp "${src}" "${dest}"
    else
       _ga_copy_files "${src}" "${dest}"
    fi
}
