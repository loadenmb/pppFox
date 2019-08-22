#! /bin/bash

# load private unique firefox profile with predefined proxy settings and mac address

# tested on: debian stretch
# set configuration & chmod +x this script ;) & run this script

##
## <configuration>
##f
RANDOM_MAC=1; # 1 = mac change enabled (root required), 0 = mac change disabled (if disabled mac address will not change)
##
## </configuration>
##

echo "pppFox: private, portable, proxy firefox"

function usage {
    echo "usage:"
    echo './loadIdentity.sh --INTERFACE [INTERFACE] --RANDOM_MAC [0|1] [IDENTITY]'
    echo './loadIdentity.sh [IDENTITY] -m [0|1] -i [INTERFACE]'
    echo "parameter:"
    echo "-m | --RANDOM_MAC               overwrite load random mac on / off"
    echo "-i | --INTERFACE                overwrite network interface, default: eth0"
    echo "-h | --help                     display this"
    echo "examples":
    echo './loadIdentity.sh c4f11767db0bf2ab5b11e2917a7073f1            # load idenity like defined'
    echo './loadIdentity.sh 5                                           # load by line number from searchIdentity.sh'
    echo './loadIdentity.sh                                             # will ask for identity string'
    echo './loadIdentity.sh c4f11... --INTERFACE wlan0 --RANDOM_MAC 1   # change mac on interface'
    echo './loadIdentity.sh -m 0  9b41499a51a31ecbac215a8ce0b1fb63      # without mac change'
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
        POSITIONAL+=("$1") # save it in an array for later
        shift # past argument
        ;;
    esac
done

# check & get ff profile from args or read in profile id
if [ -z "${POSITIONAL[0]}" ]; then
    PROFILE=""
    while [ -z "$PROFILE" ]; do
        read -p "pppFox: enter identity id: " PROFILE
    done
else
    PROFILE=${POSITIONAL[0]}
fi

# get current script path, resolve $SOURCE until the file is no longer a symlink
SOURCE=${BASH_SOURCE[0]}
while [ -h "$SOURCE" ]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
PWD="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"

# load profile by line number if script argument is integer
if [[ $PROFILE =~ ^[0-9]+$ ]]; then
    PROFILE=$(sed "${PROFILE}!d" "${PWD}/identities/identity_names.txt" | cut -d " " -f1)
fi

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

# get network interface, required for mac change
INTERFACE=$(cat "${PROFILE_DIR}/interface.txt");

# change mac adress (RANDOM_MAC = 1) 
if [ $RANDOM_MAC = 1 ]; then

    # get mac address from file, try to set mac on interface
    function changeMac {
        MAC_TMP=$1;
        INTERFACE=$2;
        ip link set dev ${INTERFACE} down
        ip link set dev ${INTERFACE} address ${MAC_TMP}
        sleep 1;
        ip link set dev ${INTERFACE} up            
    }
    echo "pppFox: root permissions required for temporary mac address change (leave empty to abort)"
    MAC_TMP=$(cat "${PROFILE_DIR}/mac_address.txt")
    su -c "$(declare -f changeMac); changeMac ${MAC_TMP} ${INTERFACE}"
    MAC_CURRENT=$(cat /sys/class/net/${INTERFACE}/address)
    if  [ "$MAC_TMP" != "$MAC_CURRENT" ]; then
        echo "pppFox: can not change mac address. maybe wrong root password or set RANDOM_MAC=0"
        exit 1
    fi
    echo "pppFox: exit root";
    
    
# mac address change disabled (RANDOM_MAC = 0)
else
    # get mac address to store in profile later
    MAC_CURRENT=$(cat /sys/class/net/${INTERFACE}/address)
fi 
echo "pppFox: mac address: ${MAC_CURRENT} @ ${INTERFACE}"

# show user agent
USERAGENT=$(grep -oP '(?<=user_pref\("useragent\.override", ").*(?=")' "${PROFILE_DIR}/user.js");
echo "pppFox: useragent: ${USERAGENT}"

# show proxy settings
PROXY_IP=$(grep -oP '(?<=user_pref\("network\.proxy\.http", ").*(?=")' "${PROFILE_DIR}/user.js");
if [ ! -z "$PROXY_IP" ]; then
    PROXY_PORT=$(grep -oP '(?<=user_pref\("network\.proxy\.http_port", ).*(?=\))' "${PROFILE_DIR}/user.js");
    echo "pppFox: proxy settings: ${PROXY_IP}:${PROXY_PORT}"
else
    echo "pppFox: proxy settings: none" 
fi

# start firefox with pre-prepared profile
echo "pppFox: launching firefox..."
"${PWD}/firefox/firefox" -no-remote -profile "${PROFILE_DIR}"
