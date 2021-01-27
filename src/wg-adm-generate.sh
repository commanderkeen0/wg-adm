#!/bin/bash
#
# Generate wireguard configs
#
function wggenerate {
  # get the JSON file into avariable
  JSON=$(cat $JFILE)
  S=0
  # check if the JSON file is OK
  CHK_JSON=$(echo $JSON | python3 -c "import sys,json;json.loads(sys.stdin.read());print('OK')")
 
  if [ "$CHK_JSON" = "OK" ];
   then
  	echo ""
	echo "##############################################################"
	echo "##                                                          ##"
	echo "##    Starting to generate server configuration files       ##"
	echo "##                                                          ##"
	echo "##############################################################"
	echo ""
		
	# create config folders
	if [ -d "$CDIR" ]; then
      echo "Configuration directory cleared: ${CDIR}"
	  rm -rf $CDIR/*
    else
	  echo "Configuration directory created: ${CDIR}"
	  mkdir -p $CDIR
    fi
	
	echo ""
		
	# create server config files
	SRV=$(echo $JSON | jq '.Server' | jq length)
	SRV=$(( $SRV - 1 ))
	while [ $S -le $SRV ]
	 do
	  
	  # Extract all information of the JSON File
	  Servername=$(echo $JSON | jq '.Server['$S'].Servername' | sed -s "s/\"//g")
	  ServerPhyInt=$(echo $JSON | jq '.Server['$S'].ServerPhyInt' | sed -s "s/\"//g")
	  ServerVirInt=$(echo $JSON | jq '.Server['$S'].ServerVirInt' | sed -s "s/\"//g")
	  Address=$(echo $JSON | jq '.Server['$S'].Address' | sed -s "s/\"//g")
	  ListenPort=$(echo $JSON | jq '.Server['$S'].ListenPort' | sed -s "s/\"//g")
	  ServerPrivateKey=$(echo $JSON | jq '.Server['$S'].ServerPrivateKey' |sed -s "s/\"//g")
	  ServerPublicKey=$(echo $ServerPrivateKey | wg pubkey)
	  PostUp=$(echo $JSON | jq '.Server['$S'].PostUp' | sed -s "s/\"//g" | sed -s "s/INT/$ServerPhyInt/g")
	  PostDown=$(echo $JSON | jq '.Server['$S'].PostDown' | sed -s "s/\"//g" | sed -s "s/INT/$ServerPhyInt/g")
	  FQDN=$(echo $JSON | jq '.Server['$S'].FQDN' |sed -s "s/\"//g")
	  
	  echo "##############################################################"
	  echo "Start generating Configs for:" $Servername
	  mkdir -p $CDIR/$Servername
	  
	  CFILE=$CDIR/$Servername/$ServerVirInt".conf"
	  echo "Create server config: $CFILE"
	  touch $CFILE
	  
	  echo "# wg-admin generated configuration file" > $CFILE
	  echo "# configuration for server: $FQDN" >> $CFILE
	  echo "[Interface]" >> $CFILE
      echo "PrivateKey = $ServerPrivateKey" >> $CFILE
      echo "Address = $Address" >> $CFILE
	  echo $PostUp >> $CFILE
      echo $PostDown >> $CFILE
	  echo "ListenPort = $ListenPort" >> $CFILE
      echo "..."
	  #
      # Client Configuration
	  # 
	  C=0
	  CLT=$(echo $JSON | jq '.Client' | jq length)
	  CLT=$(( $CLT - 1 ))
	  while [ $C -le $CLT ]	  
	   do
		#
		# exrtacting configarion items from the JSON File
		#
		ClientName=$(echo $JSON | jq '.Client['$C'].ClientName' | sed -s "s/\"//g")
		User=$(echo $JSON | jq '.Client['$C'].User' | sed -s "s/\"//g")
		TunnelIP=$(echo $JSON | jq '.Client['$C'].TunnelIP' | sed -s "s/\"//g")
		ClientPrivateKey=$(echo $JSON | jq '.Client['$C'].ClientPrivateKey' | sed -s "s/\"//g")
		ClientPublicKey=$(echo $ClientPrivateKey | wg pubkey)
		PresharedKey=$(echo $JSON | jq '.Client['$C'].PresharedKey' | sed -s "s/\"//g")
		NetworksOverVPN=$(echo $JSON | jq '.Client['$C'].AllowedIPs' | sed -s "s/\"//g")
		#
		# all client specific configurtion items will be places in the server configuration
		#		
		echo "Creating entry for Client: "$ClientName
		echo "" >> $CFILE
		echo "[Peer]" >> $CFILE
        echo "#Login assigend to User: $User" >> $CFILE
		echo "PublicKey = $ClientPublicKey" >> $CFILE
		echo "PresharedKey = $PresharedKey" >> $CFILE
		echo "AllowedIPs = "$(echo $Address | awk -F "." '{ print $1"."$2"."$3}')".$TunnelIP/32"  >> $CFILE
	    #echo "Client IP: "$(echo $Address | awk -F "." '{ print $1"."$2"."$3}')".$TunnelIP/32"
        #
		# generate client configuration file
		#
		CLTFILE=$CDIR/$Servername/$Servername-$ClientName".conf"
		touch $CLTFILE
        echo "Creating CLIENT configuration file: "$CLTFILE

		echo "# wg-admin generated configuration file" > $CLTFILE
		echo "# Client configurationfile for: $User" >> $CLTFILE
		echo "[Interface]" >> $CLTFILE
		echo "Address = "$(echo $Address | awk -F "." '{ print $1"."$2"."$3}')".$TunnelIP/32" >> $CLTFILE
		echo "PrivateKey = $ClientPrivateKey" >> $CLTFILE
		echo "DNS = $DNSSRV" >> $CLTFILE
		echo ""  >> $CLTFILE
		echo "[Peer]" >> $CLTFILE
		echo "PublicKey = $ServerPublicKey" >> $CLTFILE
		echo "PresharedKey = $PresharedKey" >> $CLTFILE
		echo "Endpoint = $FQDN:$ListenPort" >> $CLTFILE
		echo "AllowedIPs = $NetworksOverVPN" >> $CLTFILE
		
		echo "..."		
		C=$(( $C + 1 ))  
	   done
	  	  
	  #echo "..."
	  S=$(( $S + 1 ))
	 done
	


	
   else
   	echo "JSON input file has errors"
  fi

echo "##############################################################"
}