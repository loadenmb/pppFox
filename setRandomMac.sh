#! /bin/sh

# set random mac address

# tested on: debian stretch
# set configuration & chmod +x this script ;) & run this script

##
## <configuration>
##
INTERFACE="eth0" # eth0, wlan0
##
## </configuration>
##


# generate random mac and try to set until mac change success
MAC_TMP=$(cat /dev/urandom | head -c 32 | md5sum | sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02:\1:\2:\3:\4:\5/')
MAC_DEFAULT=$(cat /sys/class/net/${INTERFACE}/address)
MAC_CURRENT=$(cat /sys/class/net/${INTERFACE}/address)
echo "pppFox: root permissions required for temporary mac address change (retry until success strg + c to abort)"
while [ $MAC_DEFAULT = $MAC_CURRENT ]; do
    su -c "bash <<EOF
        ip link set dev ${INTERFACE} down
        ip link set dev ${INTERFACE} address ${MAC_TMP}
        sleep 1;
        ip link set dev ${INTERFACE} up
EOF"
    MAC_CURRENT=$(cat /sys/class/net/${INTERFACE}/address)
done
echo "pppFox: exit root";
echo "pppFox: mac address: ${MAC_CURRENT}"


