# pppFox: private, portable, proxy firefox

Portable firefox & profile manager shell scripts which create & load firefox profiles with predefined proxy settings, useragent & mac address

Fully portable to spoof identity (IP & MAC & useragent) where ever you go
- hide your identity (IP & MAC & useragent) from services used 
- hide connection meta data from local network operator

-> evade geo IP restrictions and avoid account suspension if multiple identities not allowed at a service

Buzzwords: Firefox portable, profile manager, spoof identity

[https://github.com/loadenmb/pppFox](https://github.com/loadenmb/pppFox)

## Usage

### Create unique firefox identity / profile
Create new unique firefox profile with defined user agent, proxy settings and mac address
```
./newIdentity.sh -h
pppFox: private, portable, proxy firefox
usage:
./newIdentity.sh --PROXY_IP [IP] --PROXY_PORT [PORT] --USERAGENT "[AGENT STRING]" --RANDOM_MAC [0|1]
./newIdentity.sh -s [IP] -p [PORT] -a "[AGENT STRING]" -m [0|1]
parameter:
-s | --PROXY_IP                 proxy server ip
-p | --PROXY_PORT               proxy server port, default: 8080
-a | --USERAGENT                useragent
-m | --RANDOM_MAC               generate random mac
-i | --INTERFACE                overwrite network interface, default: eth0
-h | --help                     display this
configure default PROXY_IP, PROXY_PORT, USERAGENT, RANDOM_MAC (root required), INTERFACE in newIdentity.sh before launching
examples:
./newIdentity.sh --PROXY_IP 127.0.0.1 --PROXY_PORT 2658 --USERAGENT "Mozilla/5.0 (inux x86_64;) Gecko/201101"
./newIdentity.sh -s 127.0.0.1 -p 2658 -m 0
./newIdentity.sh -s 127.0.0.1 -p 8080 -a "Mozilla/5.0 (X11; Linux x86_64;) Gecko/201101 Firefox/60.0"
```
Important output is the new identity ID. (you need this id to load your profile again)
```
pppFox: new identity: c4f11767db0bf2ab5b11e2917a7073f1
```

### Load identity by identity / profile folder name
Load private unique firefox profile with predefined proxy settings and mac address
```
./loadIdentity.sh -h
pppFox: private, portable, proxy firefox
usage:
./loadIdentity.sh --INTERFACE [INTERFACE] --RANDOM_MAC [0|1]
./loadIdentity.sh -m [0|1] -i [INTERFACE]
parameter:
-m | --RANDOM_MAC               overwrite load random mac on / off
-i | --INTERFACE                overwrite network interface, default: eth0
-h | --help                     display this
examples:
./loadIdentity.sh c4f11767db0bf2ab5b11e2917a7073f1            # load idenity like defined
./loadIdentity.sh                                             # will ask for identity string
./loadIdentity.sh c4f11... --INTERFACE wlan0 --RANDOM_MAC 1   # change mac on interface
./loadIdentity.sh -m 0  9b41499a51a31ecbac215a8ce0b1fb63      # without mac change
```

### Generate and set random mac address
```shell
./setRandomMac.sh
``` 
For desktop launch choose "execute in terminal" option for all scripts. (console input is expected)

## Setup
```
# clone from git
git clone https://github.com/loadenmb/pppFox.git

cd pppFox/

# get a firefox version of your choice: http://releases.mozilla.org/pub/firefox/releases/
wget http://releases.mozilla.org/pub/firefox/releases/67.0b9/linux-x86_64/en-US/firefox-67.0b9.tar.bz2

# extract it to ./firefox/ subfolder
tar -xjf firefox-67.0b9.tar.bz2

# chmod +x scripts in base folder
chmod +x ./*.sh
```

## Advanced usage

### Search / list for identities / profiles
```shell
# search all facebook related firefox profiles
./searchIdentity.sh *facebook*

# search profile with exact match
./searchIdentity.sh "johndoe mail"

# list / search with assistant ;)
./searchIdentity.sh 
pppFox: search keyword or regular expression (leave empty for list of identities):
0a7d329f77835f94f01f408756c4ca4e johndoe mail
cd43d18e9555b2f2a20a04b5f8e65032 facebook marketing
```

### Delete identities / profiles
```shell
# delete single profile
./deleteIdentity.sh 09ba510ca304850fd659aae4f1f4a8a0
pppFox: continue to delete identity 09ba510ca304850fd659aae4f1f4a8a0? [y/n]:y

# delete all identities / profiles
rm -r ./identities/*
```

### Default configuration

Configure default PROXY_IP, PROXY_PORT, USERAGENT, RANDOM_MAC (root required), INTERFACE in newIdentity.sh.
```shell
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

## Details
| What                                                       |  Value         | 
| ---------------------------------------------------------- | -------------- |
| scripts tested on:                                         | Debian Stretch |
| for configuration options see ## <configuration> block at: | ./newIdentity.sh, ./loadIdentity.sh, ./setRandomMac.sh |
| hardened firefox settings are copied from:                 | ./var/user.js |
| identities / profiles stored at:                           | ./identities/[0-9a-f]{32}/ |
| mac address is stored at:                                  | ./identities/[0-9a-f]{32}/mac_address.txt |
| network interface is stored at:                            | ./identities/[0-9a-f]{32}/interface.txt |
| firefox proxy and useragent settings are inserted at:      | ./identities/[0-9a-f]{32}/user.js |
| identity / profile names stored at:                        | ./identities/identity_names.txt |


## Roadmap / TODO (feel free to work on)
- add socks option (http/s proxy only at the moment)
- maybe add proxychains option?

## Contribute

Discuss features, report issues, questions -> [here](https://github.com/loadenmb/pppFox/issues).

Developer -> fork & pull ;)

## Related
- [Proxy list](https://www.google.com/search?q=proxy+list)    
- [Firefox releases](http://releases.mozilla.org/pub/firefox/releases/)
- User agent lists:
    - [myip.ms](https://myip.ms/browse/comp_browseragents/Computer_Browser_Agents.html)
    - [whatismybrowser.com](https://developers.whatismybrowser.com/useragents/explore/)
