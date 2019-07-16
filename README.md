# pppFox: private, portable, proxy firefox

Portable firefox & profile manager shell scripts which create & load firefox profiles with predefined proxy settings, useragent & mac address

Fully portable to spoof identity (IP & MAC & useragent) where ever you go
- hide your identity (IP & MAC & useragent) from services used 
- hide connection meta data from local network operator

-> evade geo IP restrictions and avoid account suspension if multiple identities not allowed at a service

Buzzwords: Firefox portable, profile manager, spoof identity

## Usage

### Create identity / profile

Configure PROXY_IP, PROXY_PORT, USERAGENT, RANDOM_MAC (root required), INTERFACE in newIdentity.sh before launching
```
##
## <configuration>
##
PROXY_IP="127.0.0.1"
PROXY_PORT="8080"
USERAGENT="Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/60.0"

RANDOM_MAC=1; # 1 = mac change enabled (root required), 0 = mac change disabled
INTERFACE="eth0" # network interface for mac change: eth0, wlan0
##
## </configuration>
##
```
### Create private unique firefox profile

Create private unique firefox profile with predefined proxy settings and random mac address
```
./newIdentity.sh
```
See the new identity id (you need this id to load your profile again), enter optional profile name (useful if many profiles available),
see your proxy and useragent configuration
```
pppFox: new identity: c4f11767db0bf2ab5b11e2917a7073f1
pppFox: enter identity name (optional): facebook marketing
pppFox: useragent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/60.0
pppFox: proxy settings: 103.28.226.125:32862
pppFox: launching firefox...
```

### Load identity by identity / profile folder name

Load private unique firefox profile with predefined proxy settings and mac address
```
./loadIdentity.sh c4f11767db0bf2ab5b11e2917a7073f1
``` 

### Generate and set random mac address
```
./setRandomMac.sh
``` 
For desktop launch choose "execute in terminal" option for all scripts. (console input is expected)

## Setup
```
# clone from git
git clone *** pppFox

cd pppFox/

# get a firefox version of your choice: http://releases.mozilla.org/pub/firefox/releases/
wget http://releases.mozilla.org/pub/firefox/releases/67.0b9/linux-x86_64/en-US/firefox-67.0b9.tar.bz2

# extract it to ./firefox/ subfolder
tar -xjf firefox-67.0b9.tar.bz2

# chmod +x scripts in base folder
chmod +x ./*.sh
```

## Advanced usage

### Search for identities / profiles
```
# search all facebook related firefox profiles
grep *facebook*  "./identities/identity_names.txt"

# search profile with exact match
grep "johndoe mail"  "./identities/identity_names.txt"
```

### Delete identities / profiles
```
# delete single profile (if profile name is set it's not delete from profile index = ./identities/identity_names.txt, manual remove line in file if wanted)
rm -r ./identities/c4f11767db0bf2ab5b11e2917a7073f1

# delete all identities / profiles
rm -r ./identities/*
```

## Details
- scripts tested on:                                              Debian Stretch
- for configuration options see ## <configuration> block at:     ./newIdentity.sh, ./loadIdentity.sh, ./setRandomMac.sh
- hardened firefox settings are copied from:                     ./var/user.js
- identities / profiles stored at:                                ./identities/[0-9a-f]{32}/
- mac address is stored at:                                      ./identities/[0-9a-f]{32}/mac_address.txt
- firefox proxy and useragent settings are inserted at:          ./identities/[0-9a-f]{32}/user.js
- identity / profile names stored at:                            ./identities/identity_names.txt


## Roadmap / TODO (feel free to work on)
- add proxy + mac parameter, other script params?
- add proxychains option?


## Related
- [Proxy list](https://www.google.com/search?q=proxy+list)    
- [Firefox releases](http://releases.mozilla.org/pub/firefox/releases/)
