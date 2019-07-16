#! /bin/bash

# load private unique firefox profile with predefined proxy settings and mac address

# tested on: debian stretch
# set configuration & chmod +x this script ;) & run this script

##
## <configuration>
##
RANDOM_MAC=1; # 1 = mac change enabled (root required), 0 = mac change disabled (if disabled mac address will not change)
INTERFACE="eth0" # eth0, wlan0
##
## </configuration>
##


echo "pppFox: private, portable, proxy firefox"

# check & get ff profile from args or read in profile id
if [ -z "$1" ]; then
    PROFILE=""
    while [ -z "$PROFILE" ]; do
        read -p "pppFox: enter identity id: " PROFILE
    done
else
    PROFILE=$1;
fi

# get current script path, resolve $SOURCE until the file is no longer a symlink
SOURCE=${BASH_SOURCE[0]}
while [ -h "$SOURCE" ]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
PWD="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"

# check if profile available
PROFILE_DIR="${PWD}/identities/${PROFILE}"
if [ ! -d "$PROFILE_DIR" ]; then
    echo "pppFox: error: identity \"${PROFILE}\" not found. exit..."
    exit 1
fi
echo "pppFox: load identity: ${PROFILE}"

# show idenity name from file if available
NAME=$(grep -oP "(?<=${PROFILE} ).*(?=$)" "${PWD}/identities/identity_names.txt");
if [ ! -z "$NAME" ]; then
    echo "pppFox: identity name: ${NAME}"
fi

# change mac adress (RANDOM_MAC = 1) 
if [ $RANDOM_MAC = 1 ]; then

    # get mac address from file, try to set until mac change success
    function changeMac {
        MAC_TMP=$1;
        INTERFACE=$2;
        MAC_CURRENT=$(cat /sys/class/net/${INTERFACE}/address)
        while [ $MAC_TMP = $MAC_CURRENT ]; do
            ip link set dev ${INTERFACE} down
            ip link set dev ${INTERFACE} address ${MAC_TMP}
            sleep 5;
            ip link set dev ${INTERFACE} up            
            MAC_CURRENT=$(cat /sys/class/net/${INTERFACE}/address)
        done
    }
    echo "pppFox: root permissions required for temporary mac address change (leave empty to abort)"
    MAC_TMP=$(cat "${PROFILE_DIR}/mac_address.txt");
    su -c "$(declare -f changeMac); changeMac ${MAC_TMP} ${INTERFACE}"
    MAC_CURRENT=$(cat /sys/class/net/${INTERFACE}/address)
    if  [ $MAC_TMP = $MAC_CURRENT ]; then
        echo "pppFox: can not change mac address. maybe wrong root password or set RANDOM_MAC=0"
        exit 1
    fi
    echo "pppFox: exit root";
    
    
# mac address change disabled (RANDOM_MAC = 0)
else
    # get mac address to store in profile later
    MAC_CURRENT=$(cat /sys/class/net/${INTERFACE}/address)
fi 
echo "pppFox: mac address: ${MAC_CURRENT}"

# show user agent
USERAGENT=$(grep -oP '(?<=user_pref\("useragent\.override", ").*(?=")' "${PROFILE_DIR}/user.js");
echo "pppFox: useragent: ${USERAGENT}"

# show proxy settings
PROXY_IP=$(grep -oP '(?<=user_pref\("network\.proxy\.http", ").*(?=")' "${PROFILE_DIR}/user.js");
PROXY_PORT=$(grep -oP '(?<=user_pref\("network\.proxy\.http_port", ).*(?=\))' "${PROFILE_DIR}/user.js");
echo "pppFox: proxy settings: ${PROXY_IP}:${PROXY_PORT}"

# start firefox with pre-prepared profile
echo "pppFox: launching firefox..."
"${PWD}/firefox/firefox" -no-remote -profile "${PROFILE_DIR}"
