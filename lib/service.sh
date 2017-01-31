#!/usr/bin/env bash
#############################################################
# Sub functions to work with services
#############################################################
# Valeriy Soloviov <weldpua2008@gmail.com>
#############################################################

######################
# start service
# $1 - name of service
######################
function start_service {
	local SERVICE=$1
	$SUDO service ${SERVICE} start &> /dev/null
	$SUDO initctl start ${SERVICE} &> /dev/null
	$SUDO rm -f /etc/init/${SERVICE}.override &> /dev/null
    $SUDO update-rc.d ${SERVICE} defaults 99 &> /dev/null
}

######################
# stop service
# $1 - name of service
######################
function stop_service {
	 local SERVICE=$1
	 $SUDO service ${SERVICE} stop &> /dev/null
     $SUDO initctl stop ${SERVICE} &> /dev/null
	 $SUDO update-rc.d -f ${SERVICE} remove &> /dev/null
     $SUDO  echo 'manual' > /etc/init/${SERVICE}.override 2> /dev/null
}
