#!/bin/bash
#
# wireguard administration tool
# author: Philipp G.
#
#


#
# Variables
#
# JSON input file
JFILE="wg.json"
# Basedir where the script resides
BASEDIR=$(pwd)
# Configuration Folder
CFG="CFG"
# Full Path to the config folder
CDIR=$BASEDIR"/"$CFG
# applied DNS Servers via VPN
DNSSRV="8.8.8.8"

#
# load functions
#
. $BASEDIR/src/./wg-adm-generate.sh
. $BASEDIR/src/./wg-adm-update.sh


#
# Main Program
#

case $1 in
    generate)
	   echo ""
	   wggenerate
	   echo " ... DONE ..."
       ;;
    init)
	   echo "Initialize server"
	   wginit
       ;;
    update)
	   echo "Initialize server"
	   wgupdate
       ;;
    restart)
	   echo "Initialize server"
	   wgrestart
       ;;
    *)
	   echo "Help:"
	   echo "Available commands: generate / init / update"
       ;;
esac

echo ""
echo ""



#ToDo
# PSK check if not existing
# IPv6 implementation
# 

# Sources:
# wg addconf wg0 <(wg-quick strip wg0)
# cat wg.json | jq  2>&1 | awk '{ print $1 " " $2 }'
# https://www.reddit.com/r/WireGuard/comments/fodgpi/adding_peer_without_having_to_restart_service/
# https://www.antary.de/2020/04/09/raspberry-pi-installation-und-betrieb-von-wireguard/
# https://www.wireguardconfig.com/
 