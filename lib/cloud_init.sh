#!/usr/bin/env bash
#############################################################
# Sub functions to work with cloud-init
#############################################################
# Valeriy Soloviov <weldpua2008@gmail.com>
#############################################################
disable_cloudinit(){
	$SUDO mkdir -p /etc/cloud/cloud.cfg.d/ || true
	echo "datasource_list: [ NoCloud, None ]" | $SUDO tee /etc/cloud/cloud.cfg.d/90_dpkg.cfg
	return $?
}
