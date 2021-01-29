#!/bin/bash
#
# Initialise wireguard server based on input file
#
function wgupdate {
 # 1.
  # get the JSON file into avariable
  if [[ ! -f "$BASEDIR/$JFILE" ]]; 
   then
    echo "JSON File missing"
    exit
  fi
  JSON=$(cat $BASEDIR/$JFILE)
  S=0
  # check if the JSON file is OK
  CHK_JSON=$(echo $JSON | python3 -c "import sys,json;json.loads(sys.stdin.read());print('OK')")
 
  if [ "$CHK_JSON" = "OK" ];
   then
		
	# star getting data of teh server
	SRV=$(echo $JSON | jq '.Server' | jq length)
	SRV=$(( $SRV - 1 ))
	while [ $S -le $SRV ]
	 do
	  Servername=$(echo $JSON | jq '.Server['$S'].Servername' | sed -s "s/\"//g")
	  SSHKey=$(echo $JSON | jq '.Server['$S'].SSHKey' | sed -s "s/\"//g")
	  SSHUser=$(echo $JSON | jq '.Server['$S'].SSHUser' | sed -s "s/\"//g")
	  SSHPort=$(echo $JSON | jq '.Server['$S'].SSHPort' | sed -s "s/\"//g")
	  ServerVirInt=$(echo $JSON | jq '.Server['$S'].ServerVirInt' | sed -s "s/\"//g")
	  FQDN=$(echo $JSON | jq '.Server['$S'].FQDN' |sed -s "s/\"//g")
      AdminIP=$(echo $JSON | jq '.Server['$S'].AdminIP' |sed -s "s/\"//g")
	    
      #
	  # check if a config is available
	  #
	  
	  echo "##############################################################"
	  echo "Server: $Servername"
	  echo "excpected config file: $CDIR/$Servername/$ServerVirInt.conf"
	  echo "excpected config file: $BASEDIR/$KEYS/$SSHKey.priv"
	  if [[ -f "$CDIR/$Servername/$ServerVirInt.conf" && -f "$BASEDIR/$KEYS/$SSHKey.priv" ]]; then
	     # create backup file of the 
		 echo "Backup config file"
		 ssh -i $BASEDIR/$KEYS/$SSHKey.priv -p $SSHPort $SSHUser@$AdminIP "mv /etc/wireguard/$ServerVirInt.conf /etc/wireguard/$ServerVirInt.conf.bak"
		 # copy config to server
		 echo "transfer the new config file to the server"
		 scp -i $BASEDIR/$KEYS/$SSHKey.priv -P $SSHPort $CDIR/$Servername/$ServerVirInt.conf $SSHUser@$AdminIP:/etc/wireguard/
		 # add the new deltas of the wireguard config
		 echo "reconfigure wireguard without restart of the service"
		 ssh -i $BASEDIR/$KEYS/$SSHKey.priv -p $SSHPort $SSHUser@$AdminIP "wg addconf wg0 <(wg-quick strip wg0)"
		 echo "##############################################################"
		 echo ""
      else
	     echo "Either no server configuration file or $SSHKey.priv missing"
	  fi
	  S=$(( $S + 1 ))
	 done
   else
   	echo "JSON input file has errors"
  fi
echo ""
}

# restart wg service on the remote servers
function wgrestart {
	
  # get the JSON file into avariable
  if [[ ! -f "$BASEDIR/$JFILE" ]]; 
   then
    echo "JSON File missing"
    exit
  fi
  JSON=$(cat $BASEDIR/$JFILE)
  S=0
  # check if the JSON file is OK
  CHK_JSON=$(echo $JSON | python3 -c "import sys,json;json.loads(sys.stdin.read());print('OK')")

  if [ "$CHK_JSON" = "OK" ];
   then	
	# star getting data of teh server
	SRV=$(echo $JSON | jq '.Server' | jq length)
	SRV=$(( $SRV - 1 ))
	while [ $S -le $SRV ]
	 do
	  Servername=$(echo $JSON | jq '.Server['$S'].Servername' | sed -s "s/\"//g")
	  ServerVirInt=$(echo $JSON | jq '.Server['$S'].ServerVirInt' | sed -s "s/\"//g")
	  SSHKey=$(echo $JSON | jq '.Server['$S'].SSHKey' | sed -s "s/\"//g")
	  SSHUser=$(echo $JSON | jq '.Server['$S'].SSHUser' | sed -s "s/\"//g")
	  SSHPort=$(echo $JSON | jq '.Server['$S'].SSHPort' | sed -s "s/\"//g")
	  ServerVirInt=$(echo $JSON | jq '.Server['$S'].ServerVirInt' | sed -s "s/\"//g")
	  FQDN=$(echo $JSON | jq '.Server['$S'].FQDN' |sed -s "s/\"//g")
      AdminIP=$(echo $JSON | jq '.Server['$S'].AdminIP' |sed -s "s/\"//g")
      #
	  # take wireguard interface down and bring it back up
	  #
	  echo "##############################################################"
	  echo "Server: $Servername"
	     # create backup file of the 
		 echo "Backup config file"
		 ssh -i $CDIR/$KEYS/$SSHKey.priv -p $SSHPort $SSHUser@$AdminIP "wg-quick down $ServerVirInt  && sleep 2 && wg-quick up $ServerVirInt"
		 echo "##############################################################"
		 echo ""
	  S=$(( $S + 1 ))
	 done
   else
   	echo "JSON input file has errors"
  fi
echo ""