#! /bin/bash

# create private unique firefox profile with predefined proxy settings and random mac address

# tested on: debian stretch
# set configuration & chmod +x this script ;) & run this script

##
## <configuration>
##
PROXY_IP=""
PROXY_PORT="8080"
RANDOM_MAC=1 # 1 = mac change enabled (root required), 0 = mac change disabled

USERAGENT="Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/60.0"
INTERFACE="eth0" # network interface for mac change: eth0, wlan0
##
## </configuration>
##

echo "pppFox: private, portable, proxy firefox"

function usage {
    echo "usage:"
    echo './newIdentity.sh --PROXY_IP [IP] --PROXY_PORT [PORT] --USERAGENT "[AGENT STRING]" --RANDOM_MAC [0|1]'
    echo './newIdentity.sh -s [IP] -p [PORT] -a "[AGENT STRING]" -m [0|1]'
    echo "parameter:"
    echo "-s | --PROXY_IP                 proxy server ip"
    echo "-p | --PROXY_PORT               proxy server port, default: 8080"
    echo "-a | --USERAGENT                useragent"
    echo "-m | --RANDOM_MAC               generate random mac"
    echo "-i | --INTERFACE                overwrite network interface, default: eth0"
    echo "-h | --help                     display this"
    echo "configure default PROXY_IP, PROXY_PORT, USERAGENT, RANDOM_MAC (root required), INTERFACE in newIdentity.sh before launching"
    echo "examples":
    echo './newIdentity.sh --PROXY_IP 127.0.0.1 --PROXY_PORT 2658 --USERAGENT "Mozilla/5.0 (inux x86_64;) Gecko/201101"'
    echo "./newIdentity.sh -s 127.0.0.1 -p 2658 -m 0"
    echo './newIdentity.sh -s 127.0.0.1 -p 8080 -a "Mozilla/5.0 (X11; Linux x86_64;) Gecko/201101 Firefox/60.0"'
}

# parse parameter, overwrite configuration
POSITIONAL=()
while [ $# -gt 0 ] 
do
    key="$1"
    case $key in    
        -h|--help)
        usage;
        exit 0;
        shift # past argument
        ;;
        -s|--PROXY_IP)
        PROXY_IP="$2"
        shift # past argument
        shift # past value
        ;;
        -p|--PROXY_PORT)
        PROXY_PATH="$2"
        shift 
        shift
        ;;
        -a|--USERAGENT)
        USERAGENT="$2"
        shift
        shift
        ;;
        -i|--INTERFACE)
        INTERFACE="$2"
        shift
        shift
        ;;
        -m|--RANDOM_MAC)
        RANDOM_MAC="$2"
        shift
        shift
        ;;
        *)    # unknown option
        shift # past argument
        ;;
    esac
done

# get current script path, resolve $SOURCE until the file is no longer a symlink
SOURCE=${BASH_SOURCE[0]}
while [ -h "$SOURCE" ]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
PWD="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"

# change mac adress (RANDOM_MAC = 1)
if [ $RANDOM_MAC = 1 ]; then

    # generate random mac, try to set mac on interface
    function changeMac {
        INTERFACE=$1;
        MAC_TMP=$(cat /dev/urandom | head -c 32 | md5sum | sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02:\1:\2:\3:\4:\5/')
        ip link set dev ${INTERFACE} down
        ip link set dev ${INTERFACE} address ${MAC_TMP}
        sleep 1;
        ip link set dev ${INTERFACE} up            
    }
    echo "pppFox: root permissions required for temporary mac address change (leave empty to abort)"
    MAC_DEFAULT=$(cat /sys/class/net/${INTERFACE}/address)
    su -c "$(declare -f changeMac); changeMac ${INTERFACE}"
    MAC_CURRENT=$(cat /sys/class/net/${INTERFACE}/address)
    if  [ $MAC_DEFAULT = $MAC_CURRENT ]; then
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

# create unique random profile
PROFILE=$(cat /dev/urandom | tr -cd 'a-f0-9' | head -c 32)
PROFILE_DIR="${PWD}/identities/${PROFILE}";
while [ -d "$PROFILE_DIR" ]; do
    PROFILE=$(cat /dev/urandom | tr -cd 'a-f0-9' | head -c 32)
    PROFILE_DIR="${PWD}/identities/${PROFILE}"
done
mkdir -p "${PROFILE_DIR}"
echo "pppFox: new identity: ${PROFILE}"

# read optional idenity name and save to file
read -p "pppFox: enter identity name (optional): " NAME
if [ ! -z "$NAME" ]; then
    echo "${PROFILE} ${NAME}" >> "${PWD}/identities/identity_names.txt"
fi

# copy hardened security / anonymity settings
cp "${PWD}/var/user.js" "${PROFILE_DIR}"

# get / save mac address to firefox profile folder
echo "${MAC_CURRENT}" >> "${PROFILE_DIR}/mac_address.txt"

# save network interface, required for mac change
echo "${INTERFACE}" >> "${PROFILE_DIR}/interface.txt"

# set useragent string
echo "user_pref(\"useragent.override\", \"${USERAGENT}\");" >> "${PROFILE_DIR}/user.js"
echo "pppFox: useragent: ${USERAGENT}"

# set proxy settings if proxy IP available
if [ ! -z "$PROXY_IP" ]; then
    echo "user_pref(\"network.proxy.share_proxy_settings\", true);" >> "${PROFILE_DIR}/user.js"
    echo "user_pref(\"network.proxy.type\", 1);" >> "${PROFILE_DIR}/user.js"
    echo "user_pref(\"network.proxy.http\", \"${PROXY_IP}\");" >> "${PROFILE_DIR}/user.js"
    echo "user_pref(\"network.proxy.http_port\", ${PROXY_PORT});" >> "${PROFILE_DIR}/user.js"
    echo "pppFox: proxy settings: ${PROXY_IP}:${PROXY_PORT}"
fi
    
# start firefox with pre-prepared profile
echo "pppFox: launching firefox..."
"${PWD}/firefox/firefox" -no-remote -profile "${PROFILE_DIR}"
