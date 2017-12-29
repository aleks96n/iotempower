#!/usr/bin/env bash
# Run a raspberry pi as ulnoiot gateway (wifi router and mqtt_broker)
#
# To enable this,
# make sure ulnoiot-run script is porperly setup (for example in /home/pi/bin)
# add the following to the end of /etc/rc.local with adjusted location of the
# run-script:
# export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
# /home/pi/bin/ulnoiot exec /home/pi/lib/system_boot/raspi-boot.sh"
#
# Also disable all network devices in /etc/network/interfaces apart lo and wlan1
# and make sure that wlan1 configuration looks like this (replace /home/pi/ulnoiot
# with the respective ULNOIOT_ROOT):
# allow-hotplug wlan1
# iface wlan1 inet manual
#    pre-up /home/pi/bin/ulnoiot exec /home/pi/lib/system_boot/raspi-pre-up.sh
#    wpa-conf /run/uiot_wpa_supplicant.conf

[ "$ULNOIOT_ACTIVE" = "yes" ] || { echo "ulnoiot not active, aborting." 1>&2;exit 1; }

# check if otg-mode was enabled
egrep '^\s*dtoverlay=dwc2\s*' /boot/config.txt && otg_on=1

# read boot/config.txt and evaluate uiot-part in there
eval "$(egrep '^\s*uiot_.*=' /boot/config.txt)"


if [[ "$uiot_ap_password" ]]; then # pw was given, so start an accesspoint
    if [[ ! "$uiot_ap_name" ]]; then # no ap name, so make one up
        add_id=1
        uiot_ap_name=iotempire
    fi

    # overwrite some configuration variables
    #ULNOIOT_AP_DEVICES="wlan1 wlan0"

    # Name of accesspoint to create
    export ULNOIOT_AP_NAME="$uiot_ap_name"

    if [[ "$add_id" = 1 ]]; then
        export ULNOIOT_AP_ADDID=yes
    else
        export ULNOIOT_AP_ADDID=no
    fi

    ULNOIOT_AP_PASSWORD="$uiot_ap_password"

    # channel, bridge, and mqtt data taken straight from ulnoiot.conf

    # start accesspoint and mqtt_broker
    echo testing: tmux new-session -n AP -s UIoTSvrs ulnoiot exec accesspoint \; new-window -n MQTT ulnoiot exec mqtt_broker
    env|grep ULNOIOT_AP

fi # accesspoint check
