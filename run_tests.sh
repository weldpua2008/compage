#!/usr/bin/env bash
#############################################################
# Valeriy Soloviov <weldpua2008@gmail.com>
#############################################################
_BATS_TAG="v0.4.0"
[[ $EUID -ne 0 ]] && SUDO=$(which sudo 2> /dev/null||echo "sudo") || SUDO=""
__RUN_DIR="$( dirname "${BASH_SOURCE[0]}" )"
TESTS_ALLTESTS_DIR=$(readlink -f "$__RUN_DIR/tests")
BUILD_SDK_LIB=$(readlink -f "$__RUN_DIR/lib")

_setup_bats(){
	_BATS_ROOT="$PWD/.batsbin"
	_BATS_BIN="${_BATS_ROOT}/bin/bats"	
	[[ ! -d "$_BATS_ROOT" ]] && git clone https://github.com/sstephenson/bats.git "$_BATS_ROOT"	
	cd "$_BATS_ROOT" && \
	git checkout ${_BATS_TAG:-master} > /dev/null
}
_tests_remove_instance()
{
	 exit_code=$?
     echo "remove instanse on exit code: ${exit_code}"
      exit $exit_code
}

step0_setup_deps()
{
	_setup_bats
}

step2_run_all_tests()
{

	find "${TESTS_ALLTESTS_DIR}" -name "test_*.sh" -type f -print0| while read -d $'\0' file_of_test
  	do
  		 BUILD_SDK_LIB="$BUILD_SDK_LIB" "$_BATS_BIN" "$file_of_test"
  	done
}

main(){
 
	 trap _tests_remove_instance HUP TERM INT EXIT
	 set -e
	 step0_setup_deps
	 step2_run_all_tests
}

############# main
main
