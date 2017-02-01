#!/usr/bin/env bash
#############################################################
# Sub functions to manage ElasticSearch
#############################################################

################################
# System properties
################################

# Specifies the maximum file descriptor number that can be opened by this process
# When using Systemd, this setting is ignored and the LimitNOFILE defined in
# /usr/lib/systemd/system/elasticsearch.service takes precedence
# MAX_OPEN_FILES=262144

# The maximum number of bytes of memory that may be locked into RAM
# Set to "unlimited" if you use the 'bootstrap.mlockall: true' option
# in elasticsearch.yml (ES_HEAP_SIZE  must also be set).
# When using Systemd, the LimitMEMLOCK property must be set
# in /usr/lib/systemd/system/elasticsearch.service
#MAX_LOCKED_MEMORY=unlimited

# Maximum number of VMA (Virtual Memory Areas) a process can own
# When using Systemd, this setting is ignored and the 'vm.max_map_count'
# property is set at boot time in /usr/lib/sysctl.d/elasticsearch.conf
#MAX_MAP_COUNT=262144

# Path to the GC log file
#ES_GC_LOG_FILE=/var/log/elasticsearch/gc.log
# # limits.conf
# elasticsearch - nofile 262144
# elasticsearch - memlock unlimited


# es_show_snapshot(){
# 	TS=`date '+%Y%m%d%H%M'`
	# local host=${1:-localhos}
	# local port=${2:-9200}
	# local snapshot_uri="${3:-snapshot-prod}"
# 	PREV=`curl -s -XGET "http://$host:$port/_snapshot/$snapshot_uri/_all" |python -m json.tool|grep '"state"'|tail -1 | sed -e 's/"/\\\\"/g'`
# 	RES=`curl -s -XPUT "http://$host:$port/_snapshot/$snapshot_uri/s${TS}?wait_for_completion=false"  | sed -e 's/"/\\\\"/g'`
# 	echo "Current Production snapshot '${PREV}' \nExecuting incremental Production ES Snapshot: '${RES}'\n"	
# }

