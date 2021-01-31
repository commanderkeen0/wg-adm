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
#DNSSRV="8.8.8.8"

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
. $BASEDIR/src/./wg-adm-init.sh

##############################################################################################

#
# generell functions
#

function check_json {
  if [[ ! -f "$BASEDIR/$JFILE" ]]; 
   then
    echo "$BASEDIR/$JFILE - File is missing !"
    exit 0
  else
    JSON=$(cat $BASEDIR/$JFILE)
    # check if the JSON file is OK
    CHK_JSON=$(echo $JSON | python3 -c "import sys,json;json.loads(sys.stdin.read());print('OK')")
    if [ "$CHK_JSON" = "OK" ];
     then
	   echo "JSON File Syntax okay"
	   echo ""
	else
	 echo ""
	 echo ""
	 echo "JSON File syntax not okay"
	 echo ""
	 echo ""
	 exit 0
	fi
  fi
}

##############################################################################################

#
# Main Program
#

case $1 in
    generate)
       wggenerate
       echo " ... DONE ..."
       ;;
    init)
       wginit
	   echo " ... DONE ..."
       ;;
    update)
        wgupdate
        echo " ... DONE ..."
       ;;
    restart)
        wgrestart
       echo " ... DONE ..."
       ;;
    addclient)
       wgaddclient
       echo " ... DONE ..."
       ;;
    setup)
       wgadmsetup    
       echo " ... DONE ..."
       ;;
    *)
echo "

Your command $1 is not recognized

The folloing commands are valid:

Server management
  ./wg-adm.sh generate - generate your config files
  ./wg-adm.sh update - add additional client to your server
  ./wg-adm.sh restart - bring your virtual interface down and up on your servers
Client management
  ./wg-adm.sh addclient - add aditional clients to the existing json file
Tool
  ./wg-adm.sh setup - check your environment and create needed folders"
     ;;
esac

echo ""
