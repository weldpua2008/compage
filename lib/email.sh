#!/usr/bin/env bash
#############################################################
# Sub functions to work with email
#############################################################
function send_log_by_mail()
{
    local LOCAL_LOG_PATH=${1:-$LOG_PATH}
    local LOCAL_LOG_STATUS_PATH=${2:-$LOG_STATUS_PATH}
    local SUBJECT_ERROR_MAIL="${3:-subject}"
    local ERROR_EMAIL_FROM="${4:-root@localhost}"
    local IP_PUBLIC="${5:-localhost}"

    if [ ${#LOCAL_LOG_PATH} -lt 1 ];then
        echo "LOCAL_LOG_PATH was wrong"
    else
            if [ ! -f "${LOCAL_LOG_PATH}" ];then
                 echo "LOG_PATH was empty" | ${SUDO} tee  ${LOCAL_LOG_PATH}
            fi
    fi
    if [ ${#LOCAL_LOG_STATUS_PATH} -lt 1 ];then
        echo "LOCAL_LOG_STATUS_PATH: ${LOCAL_LOG_STATUS_PATH} was wrong"
    else
        if [ ! -f "${LOCAL_LOG_STATUS_PATH}" ];then
            echo "LOG_STATUS_PATH was empty $LOG_STATUS_PATH" | ${SUDO} tee ${LOCAL_LOG_STATUS_PATH}
        fi
    fi

    #if [ $ATTACH_ERROR_LOG ]; then
    UUID=$( ${SUDO} cat /proc/sys/kernel/random/uuid 2> /dev/null|| cat /compat/linux/proc/sys/kernel/random/uuid ||  uuidgen 2> /dev/null)
    
    local boundary="ZZ_/${UUID}.94531q"
    body=`${SUDO} cat $LOCAL_LOG_STATUS_PATH`

    start_header="  Log of $(hostname) [$IP_PUBLIC]:"
    start_header+="    "
    start_header+=$body
    start_header+="send $LOCAL_LOG_PATH as $(basename $LOCAL_LOG_PATH)"
    #LOG_PATH_B64=`base64 $LOCAL_LOG_PATH`
      (printf "%s\n" \
    "To: $EMAIL_FOR_ERRORLOG" \
    "From: $ERROR_EMAIL_FROM" \
    "Subject: $SUBJECT_ERROR_MAIL" \
    "Mime-Version: 1.0" \
    "Content-Type: multipart/mixed; boundary=\"$boundary\""\
    "--${boundary}" \
    "Content-Type: text/plain; charset=\"US-ASCII\"" \
    "Content-Transfer-Encoding: 7bit" \
    "Content-Disposition: inline" \
    "" \
    "${start_header}" \
    "--${boundary}" \
        "Content-Type: application/text" \
    "Content-Disposition: attachment; filename=$(basename $LOCAL_LOG_PATH)" \
     "Content-Transfer-Encoding: base64" \
    "";
     base64 $LOCAL_LOG_PATH) | ${SUDO} sendmail "$EMAIL_FOR_ERRORLOG"

    echo "-------------------"
    ${SUDO} cat $LOCAL_LOG_PATH
    echo "===== LOCAL_LOG_STATUS_PATH === "
    ${SUDO} cat $LOCAL_LOG_STATUS_PATH
    #else
    #           mail -s "$SUBJECT_ERROR_MAIL" $EMAIL_FOR_ERRORLOG < $LOCAL_LOG_PATH;
    #fi
}

##########################
# clean postfix queque
##########################
function clean_queque()
{        
    local main_in_queque=${1:-$default_mail}
    local default_mail="${2:-weldpua2008@gmail.com}"
    # QUEUE_CLEAN_SCRIPT - https://gist.github.com/weldpua2008/f64bc9767136eb558dc533efb1fe693a
    set +e
    if [ "${RDE_UPDATER_DEBUG:-}" == "yes" ];then
        echo -n "remove mail queque with $(basename ${QUEUE_CLEAN_SCRIPT}) for ${main_in_queque}"
    fi
    if [ "$RDE_UPDATER_DEBUG" != "yes" ];then
        if [ -f "${QUEUE_CLEAN_SCRIPT}" ];then
            ${SUDO} ${QUEUE_CLEAN_SCRIPT} ${main_in_queque} &> /dev/null
            echo_on_status $?
        fi
    else
        if [ "${RDE_UPDATER_DEBUG:-}" == "yes" ];then
            echo -n " [OK]"
        fi
    fi
    if [ "${RDE_UPDATER_DEBUG:-}" == "yes" ];then
        echo ""
    fi
    #else
        ################################
        # clean mail queque:
        #  if we here, then all previous
        #  massage can be cleared
        ################################
        #postfix flush
        #postsuper -d ALL deferred
        #postsuper -d ALL

    set -e
}

