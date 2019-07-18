#! /bin/bash

# get current script path, resolve $SOURCE until the file is no longer a symlink
SOURCE=${BASH_SOURCE[0]}
while [ -h "$SOURCE" ]; do
    DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
CURRENT_DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"

# ask for identity ID
if [ -z "$1" ]; then
    IDENTITYID=""
    while [ -z "$IDENTITYID" ]; do
        read -p "pppFox: insert identity ID to delete: " IDENTITYID
    done
else
    IDENTITYID=$1
fi 

# ask if sure to delete
DODELETE=""
while [ "$DODELETE" != "y" -a "$DODELETE" != "n" ]; do
    read -p "pppFox: continue to delete identity ${IDENTITYID}? [y/n]: " DODELETE
done
if [ "$DODELETE" = "n" ]; then
    exit 0
fi

# remove identity from index
sed -i "/^${IDENTITYID}.*$/d" "${CURRENT_DIR}/identities/identity_names.txt"

# remove identity folder
rm -r "${CURRENT_DIR}/identities/${IDENTITYID}/"

exit 0
