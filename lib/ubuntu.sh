
#!/usr/bin/env bash
#############################################################
# Sub functions to work with Ubuntu specific
#############################################################

########################################
# Disable update notification
########################################
disable_update_notification(){
	
	local RELEASE_UPGRADE_DST=/etc/update-manager/release-upgrades
	
    
    [ -e /etc/update-manager/release-upgrades ] && $SUDO rm -f /etc/update-manager/release-upgrades
    [ -e /var/lib/update-notifier/release-upgrade-available ] && $SUDO rm -f /var/lib/update-notifier/release-upgrade-available
    [ -e /etc/update-motd.d/90-updates-available ] && $SUDO chmod 400 /etc/update-motd.d/90-updates-available
    
    [ -e /etc/pam.d/sshd ] && $SUDO sed -i 's/pam_mail.so standard/pam_mail.so quiet/g'  /etc/pam.d/sshd
	
    if [ -e $RELEASE_UPGRADE_DST ];then
    	cat <<EOF | $SUDO tee $RELEASE_UPGRADE_DST
# Default behavior for the release upgrader.

[DEFAULT]
# Default prompting behavior, valid options:
#
#  never  - Never check for a new release.
#  normal - Check to see if a new release is available.  If more than one new
#           release is found, the release upgrader will attempt to upgrade to
#           the release that immediately succeeds the currently-running
#           release.
#  lts    - Check to see if a new LTS release is available.  The upgrader
#           will attempt to upgrade to the first LTS release available after
#           the currently-running one.  Note that this option should not be
#           used if the currently-running release is not itself an LTS
#           release, since in that case the upgrader won't be able to
#           determine if a newer release is available.
Prompt=never

EOF

    fi

}
