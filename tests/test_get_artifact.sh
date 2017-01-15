#!/usr/bin/env bats
#############################################################
# Valeriy Soloviov <weldpua2008@gmail.com>
#############################################################

setup() {
	# dependencies	
	. "${BUILD_SDK_LIB}"/get_artifact.sh || exit 127 
}

@test "Test function get_file_from: check copy of a file from a filesystem" {
    SUDO=sudo
    local step=0
    local non_exist_file="/tmp/non-exist-file"
    local output="/tmp/z"
    local name=""

    while [[ -f "${OUTPUT}" ]]; do        
        step=$((step+1))
        non_exist_file="${non_exist_file}${step}"
    done   

    BATS_COPYFILES=""
    _ga_copy_files(){
		if [ "$1" != "${non_exist_file}" ];then
			echo "$1 != ${non_exist_file}"
			exit 1
		fi
		if [ "$2" != "${output}" ];then
			echo "$2 != ${output}"
			exit 2
		fi
		exit 0
	}
	get_url(){
	 	exit 127
	 }

    run get_file_from "${non_exist_file}" "$output"    
    [ "$output" = " - Getting $name" ]    
    [ "$status" -eq 0 ]
    local name="zzzz"	
	run get_file_from "${non_exist_file}" "$output" "$name"   
    [ "$output" = " - Getting $name" ]    
    [ "$status" -eq 0 ]
    
}


@test "Test function get_file_from: check copy of file from a remote source" {
    SUDO=sudo
    local step=0
    
    local output="/tmp/z"
    local name=""

    while [[ -f "${OUTPUT}" ]]; do        
        step=$((step+1))
        non_exist_file="${non_exist_file}${step}"
    done   

    BATS_COPYFILES=""
    _ga_copy_files(){
    	exit 127
	}

	
	for i in "http://" "https://" "ftp://";do 
		local non_exist_file="${i}tmp/non-exist-file"
		get_url(){
			if [ "$1" != "${non_exist_file}" ];then
				echo "$1 != ${non_exist_file}"
				exit 1
			fi
			if [ "$2" != "${output}" ];then
				echo "$2 != ${output}"
				exit 2
			fi
			exit 0		 	
		 }
		 function get_ftp()
			{
			    get_url $@
			}
		local name=""	
	    run get_file_from "${non_exist_file}" "$output"    
	    [ "$output" = " - Getting $name" ]    
	    [ "$status" -eq 0 ]
	    local name="zzzz"	
		run get_file_from "${non_exist_file}" "$output" "$name"   
	    [ "$output" = " - Getting $name" ]    
	    [ "$status" -eq 0 ]
    done
}

