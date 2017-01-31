
#!/usr/bin/env bash
#############################################################
# Sub functions to work with mysql
#############################################################

is_inselect(){
	local search_string="${1:-}"
	$SUDO mysql -u ${DB_USER} -p${DB_PASSWORD} -h ${DB_HOST} -e "use ${DB_DBNAME};${DB_SQL};" |grep -q -w "${search_string}"	
	return $?
}
