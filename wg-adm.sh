#!/bin/bash
#
# wireguard administration tool
#
# author: Philipp G.
# email: gmastap@gmail.com
#


#
# Variables to be configured
#


#########################  Modify variables below  ###########################################
# JSON input file
JFILE="wg0.json"
# Basedir where the script resides
BASEDIR=$(pwd)
# Configuration Folder
CFG="CFG"
# Folder for Backup files (can be changed)
BCK="BCK"
# filder that hosts the SSH keys to the other servers
KEYS="keys"
# Full Path to the config folder
CDIR=$BASEDIR"/"$CFG
# applied DNS Servers via VPN
DNSSRV="8.8.8.8"

##############################################################################################
##
## Modify below that needs a propper understanding of the working mechanims of that script :)
## Feel free to cleanup and enhance. I would be happy if you would send me your improvements back
## Happy coding
##
##############################################################################################

#
# load functions
#
. $BASEDIR/src/./wg-adm-generate.sh
. $BASEDIR/src/./wg-adm-update.sh
. $BASEDIR/src/./wg-adm-json-entry.sh


#
# generall functions
#

function check_json {
  if [[ ! -f "$BASEDIR/$JFILE" ]]; 
   then
    echo "$BASEDIR/$JFILE - File is missing !"
    exit
  fi
}

check_json

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
       echo "##    Initialize an interface on a remote server            ##"
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
    addclient)
        echo ""
        echo "##############################################################"
        echo "##                                                          ##"
        echo "##    Creating a client entry and adding to the json file   ##"
        echo "##                                                          ##"
        echo "##############################################################"
        echo ""
       wgmakeclt
       echo " ... DONE ..."
       ;;
    setup)
        echo ""
        echo "##############################################################"
        echo "##                                                          ##"
        echo "##    Create the initial environment                        ##"
        echo "##                                                          ##"
        echo "##############################################################"
        echo ""
       
           # create config folders
        if [ -d "$CDIR" ]; then
          echo "Configuration directory cleared: $CDIR"
          rm -rf $CDIR/*
        else
          echo "Configuration directory created: $CDIR"
          mkdir -p $CDIR
        fi 
      
        # create config folders
        if [ -d "$BASEDIR/$BCK" ]; then
          echo "Backup directory cleared: $BASEDIR/$BCK"
          rm -rf $BASEDIR/$BCK/*
        else
          echo "Configuration directory created: $BASEDIR/$BCK"
          mkdir -p $BASEDIR/$BCK
        fi
      
        # create config folders
        if [ -d "$BASEDIR/$KEYS" ]; then
          echo "Backup directory cleared: $BASEDIR/$KEYS"
          rm -rf $BASEDIR/$KEYS/*
        else
          echo "Configuration directory created: $BASEDIR/$KEYS"
          mkdir -p $BASEDIR/$KEYS
        fi
       
       # check wireguard
       if [[ -f "$(which wg)" ]]; 
        then
         echo "wireguard: installed"
        else
         echo ""
         echo "##############################################################"
         echo "##                                                          ##"
         echo "##    Wireguad package is not found                         ##"
         echo "##    Please install the coresponding package               ##"
         echo "##                                                          ##"
         echo "##############################################################"
         echo ""
        fi
       
       # check jq
       if [[ -f "$(which jq)" ]]; 
        then
         echo "jq - JSON QUERY for bash is installed"
        else
         echo ""
         echo "##############################################################"
         echo "##                                                          ##"
         echo "##    jq package is not found                               ##"
         echo "##    Please install the coresponding package               ##"
         echo "##                                                          ##"
         echo "##############################################################"
         echo ""
        fi
       
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
 