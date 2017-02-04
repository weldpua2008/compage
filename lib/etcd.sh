#!/usr/bin/env bash
#############################################################
# Sub functions to work with ETCD
#############################################################
URL_PREFIX="http://${IP}:${PORT}/v2"

etcd_isauth(){
	local IP=${1:-127.0.0.1}
	local PORT=${2:-2378}
	local URL_PREFIX="http://${IP}:${PORT}/v2/auth/enable"
	curl -L   --silent  $URL_PREFIX --stderr - | grep -i true &> /dev/null
	return $?
}

etcd_delete_role()
{
	# ROOT_AUTH ='-u root:pass'
	local IP=${1:-127.0.0.1}
	local PORT=${2:-2378}
	local URL_PREFIX="http://${IP}:${PORT}/v2"
    local role_name="${3:-}"
    if [ "x${role_name}" = "x" ];then
        echo "Please provide role name "
        exit 126
    fi
    local remove_role_url="${URL_PREFIX}/auth/roles/${role_name}"

    curl ${ROOT_AUTH} -H "Content-Type: application/json" -L --silent  ${remove_role_url}  --stderr - | grep -i "does not exist"
    if [ $? -ne 0 ];then
        curl ${ROOT_AUTH} -H "Content-Type: application/json" -XDELETE ${remove_role_url}
    fi
}

etcd_add_role(){
	local IP=${1:-127.0.0.1}
	local PORT=${2:-2378}
	local URL_PREFIX="http://${IP}:${PORT}/v2"
    local role_name="${3:-}"
    # ROOT_AUTH ='-u root:pass'
    if [ "x${role_name}" = "x" ];then
        echo "Please provide role name"
        exit 126
    fi
    local add_role_url="${URL_PREFIX}/auth/roles/${role_name}"
    read -r -d '' PUT_DATA <<- EOM
    {
          "role" : "${role_name}"
    }
EOM

    curl ${ROOT_AUTH} -H "Content-Type: application/json" -XPUT -d "${PUT_DATA}" ${add_role_url}

}

# Exmaple:
# etcd_grant "guest" "write" "\"/somepint/*\""
etcd_grant(){

	local IP=${1:-127.0.0.1}
	local PORT=${2:-2378}
	local URL_PREFIX="http://${IP}:${PORT}/v2"

    local role_name=${3:-}
    local perm_type=${4:-}
    local role_path=${5:-}
    if [ "x${role_name}" = "x" ];then
        echo  "Please provide role name to add_role()"
        exit 126
    fi
    local grant_perm_url="${URL_PREFIX}/auth/roles/${role_name}"
    if [ "x${role_path}" = "x" ];then
        echo "Please provide \$role_path in grant_perm"
        exit 126
    else
        read -r -d '' PUT_DATA <<- EOM
        {
          "role" : "${role_name}",
          "grant" : {
            "kv": {
              "${perm_type}": [ ${role_path} ]
            }
          }
        }
EOM
        curl ${ROOT_AUTH} -H "Content-Type: application/json" -XPUT -d "${PUT_DATA}" ${grant_perm_url}
    fi
}

etcd_delete_user()
{
	local IP=${1:-127.0.0.1}
	local PORT=${2:-2378}
	local URL_PREFIX="http://${IP}:${PORT}/v2"
    local role_name="${3:-}"
    if [ "x${role_name}" = "x" ];then
        echo "Please provide role name to add_role()"
        exit 126
    fi
    local remove_user_url="${URL_PREFIX}/auth/users/${role_name}"

    curl ${ROOT_AUTH} -H "Content-Type: application/json" -L --silent  ${remove_user_url}  --stderr - | grep -i "does not exist"
    if [ $? -ne 0 ];then
        curl ${ROOT_AUTH} -H "Content-Type: application/json" -XDELETE ${remove_user_url}
    fi
}
etcd_create_user(){
	local IP=${1:-127.0.0.1}
	local PORT=${2:-2378}
	local URL_PREFIX="http://${IP}:${PORT}/v2"

    local user_name=${3:-}
    local user_password=${4:-}
    if [ "x${user_name}" = "x" ];then
        echo "Please provide user name to create_user()"
        exit 126
    fi
    local create_user_url="${URL_PREFIX}/auth/users/${user_name}"
    read -r -d '' PUT_DATA <<- EOM
        {"user" : "${user_name}", "password" : "${user_password}"}
EOM
    curl ${ROOT_AUTH} -H "Content-Type: application/json" -XPUT -d "${PUT_DATA}" ${create_user_url}

}

# revoke one permition
etcd_revoke_role(){
	local IP=${1:-127.0.0.1}
	local PORT=${2:-2378}
	local URL_PREFIX="http://${IP}:${PORT}/v2"

    local role_name=${3:-}
    local perm_type=${4:-}
    local perm_path=${5:-}
    local roles_to_user_url="${URL_PREFIX}/auth/roles/${role_name}"
    if [ "x${role_name}" = "x" ];then
        echo "Please provide role name to revoke_role()"
        exit 126
    fi

    read -r -d '' PUT_DATA <<- EOM
        {"role" : "${role_name}",
            "revoke" : {
                "kv" : {
                  "${perm_type}": [
                    ${perm_path}
                  ]
                }
            }
        }
EOM
    curl ${ROOT_AUTH} -H "Content-Type: application/json" -XPUT -d "${PUT_DATA}" ${roles_to_user_url} || curl -H "Content-Type: application/json" -XPUT -d "${PUT_DATA}" ${roles_to_user_url}
}

# revoke read/write permition
# Example: etcd_revoke_role_read_write "guest" "\"*\"" "\"*\""
etcd_revoke_role_read_write(){
	local IP=${1:-127.0.0.1}
	local PORT=${2:-2378}
	local URL_PREFIX="http://${IP}:${PORT}/v2"

    local role_name=${3:-}
    local read_path=${4:-}
    local write_path=${5:-}
    local roles_to_user_url="${URL_PREFIX}/auth/roles/${role_name}"
    if [ "x${role_name}" = "x" ];then
        echo "Please provide role name to revoke_role()"
        exit 126
    fi

    read -r -d '' PUT_DATA <<- EOM
        {"role" : "${role_name}",
            "revoke" : {
                "kv" : {
                  "read": [
                    ${read_path}
                  ],
                  "write": [
                    ${write_path}
                  ]
                }
            }
        }
EOM
    curl ${ROOT_AUTH} -H "Content-Type: application/json" -XPUT -d "${PUT_DATA}" ${roles_to_user_url} || curl -H "Content-Type: application/json" -XPUT -d "${PUT_DATA}" ${roles_to_user_url}
}
etcd_enable_auth(){
local IP=${1:-127.0.0.1}
	local PORT=${2:-2378}
	local URL_PREFIX="http://${IP}:${PORT}/v2"

    local enable_auth_url="${URL_PREFIX}/auth/enable"
    curl ${ROOT_AUTH} -H "Content-Type: application/json" -XPUT ${enable_auth_url} || curl -H "Content-Type: application/json" -XPUT ${enable_auth_url}
    ROOT_AUTH=" -u root:${ROOT_PASSWORD} "
}

etcd_disable_auth(){
	local IP=${1:-127.0.0.1}
	local PORT=${2:-2378}
	local URL_PREFIX="http://${IP}:${PORT}/v2"    
	local enable_auth_url="${URL_PREFIX}/auth/enable"
    curl ${ROOT_AUTH} -H "Content-Type: application/json" -XDELETE ${enable_auth_url} || curl -H "Content-Type: application/json" -XDELETE ${enable_auth_url}
    ROOT_AUTH=""
}

etcd_rmdir()
{
#    update_rootauth
    local dir_path="${1:-}"
    if [ "x${dir_path}" = "x" ];then
        echo "Provide dir_path for delete_dir()"
        exit 126
    fi
    curl ${ROOT_AUTH} "${URL_PREFIX}/keys/${dir_path}?dir=true" -XDELETE
    curl ${ROOT_AUTH} "${URL_PREFIX}/keys/${dir_path}?recursive=true" -XDELETE
    curl ${ROOT_AUTH} -L "${URL_PREFIX}/keys/${dir_path}" -XPUT -d dir=true

}
etcd_mkdir()
{
#    update_rootauth

    local dir_path="${1:-}"
    if [ "x${dir_path}" = "x" ];then
        echo "Provide dir_path for create_dir()"
        exit 126
    fi
    curl ${ROOT_AUTH} "${URL_PREFIX}/keys/${dir_path}" -XPUT -d dir=true

}

etcd_health(){
	local IP=${1:-127.0.0.1}
	local PORT=${2:-2378}
	local URL_PREFIX="http://${IP}:${PORT}/"    
	curl -L --connect-timeout 5 ${URL_PREFIX}/health  --silent   --stderr - | grep -i true -q
	return $?
}
