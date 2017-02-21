#!/usr/bin/env bash
#############################################################
# Sub functions to work with apt
#############################################################

# Show package that provide the file
# yum provides \*/libgtk-x11-2.0.so.0
function yum_pkg_prodide(){
  yum provides \*/$1 
  return $?
}
