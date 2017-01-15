#!/usr/bin/env bash
#############################################################
# Sub functions to work with archives
#############################################################
# Valeriy Soloviov <weldpua2008@gmail.com>
#############################################################
#   version 1.0.1 (30/8/16) <weldpua2008@gmail.com>
#   -  adding pack_path_at that allows include specific 
#	  files & folder at SRC path
#	- fixing debug
#   version 1.0.0 (23/8/16) <weldpua2008@gmail.com>
#   - adding extract_to and pack_to
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

if type lstrip_to_width 2> /dev/null| grep -i function &> /dev/null; then
	__dieexist=true
else
	function lstrip_to_width() {
	  local path="${1:-}"
	  local max_width=$(printf '%.d' ${2:-30} 2> /dev/null || echo 30)
	  if [ ${#path} -gt $max_width  ];then
	    local n=${#path}
	    local start_index=0
	    ((start_index=n-max_width))
	    echo "${path:$start_index:$max_width}"
	  else
	    echo "$path"
	  fi
	}
fi

function extract_to()
{
	set -e
	 local path_to_archive="${1:-}"
	 local DEST="${2:-}"
	 shift 2
	 local __filename=$(basename "${1:-}"||echo "")
	 echo_str "  -> Extracting $(lstrip_to_width ${__filename:-.} 10|| echo ${__filename}) to: $(lstrip_to_width ${DEST:-.} 10|| echo ${DEST}) ..."
	 local args
	  if [[ $path_to_archive =~ ".xz" ]];then
	      args="xfvJ"
	  elif [[ $path_to_archive =~ ".tar" ]];then
	      args="xf"
	  elif [[ $path_to_archive =~ ".gz" || $path_to_archive =~ ".tgz" ]];then
	      args="xfvz"
	  elif [[ $path_to_archive =~ ".bz" || $path_to_archive =~ ".bz2" ]];then
	      args="xfvj"
	  else	  	  
	      echo -n "ERROR: unknown format."
	      echo_failure
	  fi
	  $SUDO tar $args "$path_to_archive" $@  -C "${DEST}" 
	  echo_success
}

# archive any path without fullpath into archive
function pack_to()
{
	set -e
	local SRC="${1:-}"
	local path_to_archive="${2:-}"
	
	local __filename=$(basename "${2:-}"||echo "")
	echo_str "  -> Archiving $(lstrip_to_width ${SRC:-.} 10|| echo ${SRC}) to: $(lstrip_to_width ${__filename:-.} 10|| echo ${__filename}) ..."
	shift 2

	local args
	if [[ $path_to_archive =~ ".xz" ]];then
	  args="cfJ"	
	elif [[ $path_to_archive =~ ".gz" || $path_to_archive =~ ".tgz" || $path_to_archive =~ ".tar.gz" ]];then
	  args="cfz"
	elif [[ $path_to_archive =~ ".bz" || $path_to_archive =~ ".bz2" ]];then
	  args="cfj"
	elif [[ $path_to_archive =~ ".tar" ]];then
	  args="cf"
	else
	  echo -n "ERROR: unknown format."
      echo_failure
	fi
	 $SUDO tar $args $@  "$path_to_archive" -C "${SRC}" ./ >/dev/null	 
	 echo_success
}

function pack_path_at()
{
	set -e
	local SRC="${1:-}"
	local path_to_archive="${2:-}"
	local archive_path="${3:-./}"
	
	local __filename=$(basename "${2:-}"||echo "")
	echo_str "  -> Archiving $(lstrip_to_width ${archive_path:-.} 10|| echo $archive_path) at $(lstrip_to_width ${SRC:-.} 10|| echo ${SRC})  to: $(lstrip_to_width ${__filename:-.} 10|| echo ${__filename})  ..."
	shift 3

	local args
	if [[ $path_to_archive =~ ".xz" ]];then
	  args="cfJ"	
	elif [[ $path_to_archive =~ ".gz" || $path_to_archive =~ ".tgz" || $path_to_archive =~ ".tar.gz" ]];then
	  args="cfz"
	elif [[ $path_to_archive =~ ".bz" || $path_to_archive =~ ".bz2" ]];then
	  args="cfj"
	elif [[ $path_to_archive =~ ".tar" ]];then
	  args="cf"
	else
	   echo -n "ERROR: unknown format."
       echo_failure
	fi
	 $SUDO tar $args $@  "$path_to_archive" -C "${SRC}" ${archive_path} >/dev/null	 
	echo_success
}

function repake_to()
{
	local SRC="$1"
    local DEST="${2:-}"
    local _REPAKE_TO_TMP="${3:-}"
    shift 3
    [[ "x$SRC" = "x" ]] && exit 100
    [[ "x$DEST" = "x" ]] && exit 100
    [[ "x$_REPAKE_TO_TMP" = "x" ]] && exit 100
    $SUDO mkdir -p "$_REPAKE_TO_TMP"
    extract_to "$SRC" "$_REPAKE_TO_TMP"
    pack_to "$_REPAKE_TO_TMP" "$DEST"
}
