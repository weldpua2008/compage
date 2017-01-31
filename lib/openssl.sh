#!/usr/bin/env bash
#############################################################
# Sub functions to work with openssl
#############################################################

generate_sslcert(){
	local domain=${1:-localhost}
	local src_ssl_dir=${2:-/tmp/ssl}
	local OU=${3:-Company}
	local ST=${4:-Kiev}
	local L=${5:-Ukraine}
	main_key_file=${src_ssl_dir}/${domain}.key
	main_crt_file=${src_ssl_dir}/${domain}.crt
	main_pem_file=${src_ssl_dir}/${domain}.pem
	if [ ! -e ${main_key_file}  ] || [ ! -e ${main_crt_file}  ] || [ e -f ${main_pem_file}  ];then
	    $SUDO openssl req \
	    -new \
	    -newkey rsa:4096 \
	    -days 3650 \
	    -nodes \
	    -x509 \
	    -subj "/C=US/OU=$OU/ST=$ST/L=$L/O=Dis/CN=${domain}" \
	    -keyout ${main_key_file} \
	    -out ${main_crt_file} || return 1

	    $SUDO cat  ${main_key_file} ${main_crt_file} | $SUDO tee ${main_pem_file}	    
	    [ $? -ne 0 ] && return 1
	    $SUDO chmod 600 ${main_key_file} || return 1
	    $SUDO chmod 600 ${main_crt_file} || return 1
	    $SUDO chmod 600 ${main_pem_file} || return 1
	fi
	return 0
}
