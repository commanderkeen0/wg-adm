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
JFILE="wg0.json"
# Basedir where the script resides
BASEDIR=$(pwd)
# Configuration Folder
CFG="CFG"
# Folder for Backup files (can be changed)
BCK="BCK"
# Full Path to the config folder
CDIR=$BASEDIR"/"$CFG
# applied DNS Servers via VPN
DNSSRV="8.8.8.8"

#
# load functions
#
. $BASEDIR/src/./wg-adm-generate.sh
. $BASEDIR/src/./wg-adm-update.sh
. $BASEDIR/src/./wg-adm-json-entry.sh

#
# Main Program
#

case $1 in
    generate)
	   echo ""
	   echo "##############################################################"
	   echo "##                                                          ##"
	   echo "##    Starting to generate server configuration files       ##"
	   echo "##                                                          ##"
	   echo "##############################################################"
	   echo ""
	   wggenerate
	   echo " ... DONE ..."
       ;;
    init)
	   echo ""
	   echo "##############################################################"
	   echo "##                                                          ##"
	   echo "##    Initialize an interface onm th remote server          ##"
	   echo "##                                                          ##"
	   echo "##############################################################"
	   echo ""
	   echo "UNDER DEVELOPMENT"
       ;;
    update)
	    echo ""
		echo "##############################################################"
		echo "##                                                          ##"
		echo "##    updateing configuration files of VPN Servers          ##"
		echo "##                                                          ##"
		echo "##############################################################"
		echo ""
	    wgupdate
		echo " ... DONE ..."
       ;;
    restart)
	    echo ""
		echo "##############################################################"
		echo "##                                                          ##"
		echo "##    restart wiregueard interfaces on all servers          ##"
		echo "##                                                          ##"
		echo "##############################################################"
		echo ""
	    wgrestart
	   echo " ... DONE ..."
       ;;
    client)
	    echo ""
		echo "##############################################################"
		echo "##                                                          ##"
		echo "##    Creating a client entry                               ##"
		echo "##                                                          ##"
		echo "##############################################################"
		echo ""
	   wgmakeclt
	   echo " ... DONE ..."
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
 