#!/usr/bin/env bash
#############################################################
# Sub functions to work with docker
#############################################################
function dockerct_ip() {
  $SUDO docker inspect --format '{{ .NetworkSettings.IPAddress }}' $@
  return $?
}
