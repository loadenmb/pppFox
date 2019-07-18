#! /bin/bash

# get current script path, resolve $SOURCE until the file is no longer a symlink
SOURCE=${BASH_SOURCE[0]}
while [ -h "$SOURCE" ]; do
    DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
CURRENT_DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"

# ask for keyword / regex if no argument supplied
if [ -z "$1" ]; then
    SEARCHGREPEX=""
    while [ -z "$SEARCHGREPEX" ]; do
        read -p "pppFox: search keyword or regular expression: " SEARCHGREPEX
    done
else
    SEARCHGREPEX=$1
fi

# search with grep
grep ${SEARCHGREPEX} "${CURRENT_DIR}/identities/identity_names.txt" 

exit 0
