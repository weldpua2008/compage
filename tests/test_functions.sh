#!/usr/bin/env bats
#############################################################
# Valeriy Soloviov <weldpua2008@gmail.com>
#############################################################

setup() {
	# dependencies	
	. "${BUILD_SDK_LIB}"/functions || exit 127 
}

@test "Test functions: die_on_empty_var" {	
	_FIXTURES=(
		":msg1:126:msg1"
		":msg2:126:msg2"
		"x:msg:0:"
		"asdsad:msg:0:"
	)
	for fuxture_var in "${_FIXTURES[@]}";do
		local var=$(echo "$fuxture_var"|cut -d ':' -f1)
		local msg=$(echo "$fuxture_var"|cut -d ':' -f2)		
		local exit_code=$(echo "$fuxture_var"|cut -d ':' -f3)
		local msg_output=$(echo "$fuxture_var"|cut -d ':' -f4)
		
		run die_on_empty_var "$var" "$msg"		
	    [ "$output" = "$msg_output" ]    
	    [ "$status" = "$exit_code"  ]
	done
}