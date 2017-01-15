#!/usr/bin/env bash
#############################################################
# Sub functions to work with filesystems, files, folders
#############################################################
# Valeriy Soloviov <weldpua2008@gmail.com>
#############################################################
#   version 1.0.0 (31/8/16) <weldpua2008@gmail.com>
#   - initial
#############################################################

function mkdir_path()
{
	set -e
	local path="${1:-}"
	local show_path=$(lstrip_to_width "$path" 44||echo "$path")
	[[ "x${path}" = "x" || "$path" = '/' ]] &&  \
		die "Fail to create folder $path. \nYou should provide valid path."

	echo_str " -> Creating path ${show_path} ..." 
	$SUDO mkdir -p "${path}" && \
	echo_success || echo_failure
}

# remove one file
function rm_file()
{
	set -e
	local path="${1:-}"
	local show_path=$(lstrip_to_width "$path" 44||echo "$path")
	[[ "x${path}" = "x" || "$path" = '/' || -d "$path" ]] && \
			die "Fail to remove file $path.\n You should provide valid path."
	
	if [[ -f "${path}" || -L "${path}" ]];then
		echo_str "	->Removing ${show_path} ..." && \
		$SUDO rm -f "${path}" && \
		echo_success || echo_failure
	fi
}

# remove one path
function rm_path_r()
{
	set -e
	local path="${1:-}"
	local show_path=$(lstrip_to_width "$path" 44||echo "$path")
	[[ "x${path}" = "x" || "$path" = '/' ]] && \
			die "Fail to remove $path.\n You should provide valid path."
	
	echo_str " ->Removing ${show_path} ..." && \
	$SUDO rm -rf "${path}" && \
	echo_success || echo_failure
}

# copy one file
function copy_file()
{
	set -e
	local src_path="${1:-}"
	local dest_path="${2:-}"
	local copy_params=${3:--a}
	local show_src_path=$(lstrip_to_width "$src_path" 21||echo "$src_path")
	local show_dest_path=$(lstrip_to_width "$dest_path" 21||echo "$dest_path")

	[[ "x${src_path}" = "x" || "$src_path" = '/' || -d "$src_path" ]] && \
			die "Fail to copy file $src_path.\n You should provide a valid path."
	[[ "x${dest_path}" = "x" ]] && \
		die "Fail to copy file $src_path.\n You should provide a valid dest path."

	if [[ -f "${src_path}" || -L "${src_path}" ]];then		
		echo_str " ->Copying ${show_src_path} to ${show_dest_path}..." && \
		$SUDO cp $copy_params "${src_path}" "${dest_path}" && \
		echo_success || echo_failure
	elif [[ ! -f "${src_path}" || ! -L "${src_path}" ]]; then
		echo_str " ->Can't copy ${show_src_path} to ${show_dest_path}..." && \
		echo -n "${show_src_path} is not exist" && \
		echo_failure		
	else
		echo_str " ->Can't copy ${show_src_path} to ${show_dest_path}..." && \
		echo -n " Unexpected error" && \
		echo_failure		
	fi
}


# copy one file
function copy_path()
{
	set -e
	local src_path="${1:-}"
	local dest_path="${2:-}"
	local copy_params=${3:--a}
	local show_src_path=$(lstrip_to_width "$src_path" 21||echo "$src_path")
	local show_dest_path=$(lstrip_to_width "$dest_path" 21|| echo "$dest_path")

	[[ "x${src_path}" = "x" || "$src_path" = '/' ]] && \
			die "Fail to copy $src_path.\n You should provide a valid path."
	[[ "x${dest_path}" = "x" ]] && \
		die "Fail to copy $src_path.\n You should provide a valid destination path."

	echo_str " ->Copying ${show_src_path} to ${show_dest_path}..." && \
	$SUDO cp $copy_params "${src_path}" "${dest_path}" && \
	echo_success || echo_failure
}
