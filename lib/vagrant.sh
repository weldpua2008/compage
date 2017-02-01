#!/usr/bin/env bash
#############################################################
# Sub functions to work with Vagrant
#############################################################
function vagrant_destroy_all()
{
    ${SUDO} vagrant global-status |awk '{print $5 "  " $1}'|grep "^/tmp"|awk '{print $2}' |xargs -I vmid ${SUDO} vagrant destroy  vmid -f
    ${SUDO} vboxmanage list vms| awk '{print $1}'|${SUDO} xargs -I vmid ${SUDO} vboxmanage controlvm vmid poweroff
    ${SUDO} vboxmanage list vms| awk '{print $1}'|${SUDO} xargs -I vmid ${SUDO} vboxmanage unregistervm vmid --delete
}
function destroy_all_vagrant_boxes()
{
    set +e
    ${SUDO} vagrant box list|grep -e "^/tmp"| xargs -I vagrant_boxid ${SUDO} vagrant box remove vagrant_boxid -f
#    for box_to_remove in `${SUDO} vagrant box list|grep -e "^/tmp"`;do
#        ${SUDO} vagrant box remove ${box_to_remove} -f
#    done

}

# function vagrant_clean_all_files()
# {
#     local except_box="${1:-bento}"
#	  local clean path="{$2:-/var/lib/jenkins/.vagrant.d/boxes}" 		
#     echo "cleaning Virtulbox creted previous boxes"
#     ${SUDO} find "$clean_path" -mindepth 1 -maxdepth 1  ! -name "*${except_box}*"  -type d rm -rf {} \;
#     #${SUDO} find /root/VirtualBox\ VMs/ -mindepth 1 -maxdepth 1 -name "test_*" -type d rm -rf {} \;
# }

function create_vagrant_box()
{
	local VAGRANTFILE_PATH="${1:-}"
	local OUTPUT_BOX_PATH="${2:-}"
    cd "${VAGRANTFILE_PATH}"
    
    ${SUDO} vagrant destroy -f || true
    
    ${SUDO} vagrant up || return 1
    ${SUDO} vagrant halt || return 2
    ${SUDO} vagrant package --output ${OUTPUT_BOX_PATH} || return 3
    # prevent fail on box adding
    ${SUDO} vagrant box add ${OUTPUT_BOX_PATH} --name ${OUTPUT_BOX_PATH} || return 4
    return 0
}
