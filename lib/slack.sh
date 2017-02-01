
#!/usr/bin/env bash
#############################################################
# Sub functions to manage slack
#############################################################
slack_sendmsg(){
	local HOOK_URL=${1:-} # https://hooks.slack.com/services/....
	local msg="$2"
	$SUDO curl -X POST -H 'Content-type: application/json' --data '{"text":"$msg\n"}' $HOOK_URL	
}
