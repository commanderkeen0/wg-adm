#!/bin/bash
#
#
#


### Server
# "Servername" : "SERVERNAME that is used internaly for generating config files>,
# "ServerPhyInt" : "Physical interface that connects to the external world, needed for NAT configuration",
# "ServerVirInt" : "wireguard interface internally",
# "Address" : "INTERFACE IP of teh wireguard interface",
# "ListenPort" : "port which wireguard is running on",
# "ServerPrivateKey" : "Serer private key",
# "PostUp" : "NAT command when the wireguard interface comes up",
# "PostDown" : "NAT command when the wireguard interface comes down",
# "FQDN" : "FQDN / DYN DNS / IP - of the external interface, used to allow clients to connect",
# "SSHKey" : "SSH Key name used for accessing remote machines, they have to be in the $KEYS folder ending with .priv",
# "AdminIP" : "Maanagment IP or FQDN for administrative access",
# "SSHPort" : "SSH Port",
# "SSHUser" : "access user"


function wgaddclient {
echo ""
echo "##############################################################"
echo "##                                                          ##"
echo "##    Creating a client entry and adding to the json file   ##"
echo "##                                                          ##"
echo "##############################################################"
echo ""
#
# read entry
#
# check for json file available
check_json

## get existing cleints and IP
 
 echo "Listing of existing Clients"
 echo "Client Name - Last Octet - Username"
  
 C=0
 CLT=$(echo $JSON | jq '.Client' | jq length)
 CLT=$(( $CLT - 1 ))
 while [ $C -le $CLT ]	  
  do
    ClientName=$(echo $JSON | jq '.Client['$C'].ClientName' | sed -s "s/\"//g")
	User=$(echo $JSON | jq '.Client['$C'].User' | sed -s "s/\"//g")
	TunnelIP=$(echo $JSON | jq '.Client['$C'].TunnelIP' | sed -s "s/\"//g")  

    EXISTINGCLT+="$ClientName - $TunnelIP - $User
"
	C=$(( $C + 1 )) 
 done

echo "$EXISTINGCLT"

# Read Endpoint Name
x=0
while [ $x -le 1 ]
do
 read -p 'Endpoint Name (no spaces or special characters): ' ClientName
 [[ "$ClientName" =~ [^a-zA-Z0-9\-_] ]] && x=0 || x=2
done

# Read Username Name
x=0
while [ $x -le 1 ]
do
 read -p 'Enter Username (email): ' UserName
 [[ "$UserName" =~ [^a-zA-Z0-9\-_.@] ]] && x=0 || x=2
done

# Read last octet
x=0
while [ $x -le 1 ]
do
 read -p 'Client IP (last octet) : '  TunnelIP
 [[ $TunnelIP =~ ^[0-9]{1,3}$ ]] && [[ $TunnelIP -le 254 && $TunnelIP -gt 1  ]] && x=2 || echo "No Number between: 2-254"
done

# add the destination netwrok 
read -p 'Destination network for teh VPN ,if empty 0.0.0.0/0 will be added: ' AllowedIPs

if [ "$AllowedIPs" == "" ]; 
 then 
  echo ""
  echo "Everything will be routed through the VPN Tunnel"
  echo ""
  AllowedIPs="0.0.0.0/0, ::/0"
fi

# generate Keys
ClientPrivateKey=$(wg genkey)
PresharedKey=$(wg genpsk)

NewClient="
  {
    \"ClientName\" : \"$ClientName\",
    \"User\" : \"$UserName\",
    \"TunnelIP\" : \"$TunnelIP\",
    \"ClientPrivateKey\" : \"$ClientPrivateKey\",
    \"PresharedKey\" : \"$PresharedKey\",
    \"AllowedIPs\" : \"$AllowedIPs\"
  }"
	
echo "$NewClient"


###################################################################


S=0
JSONSRV=$(echo $JSON | jq '.Server' | head -n-1)
JSONCLT=$(echo $JSON | jq '.Client' | head -n-2)
NEWJSON="{
 \"Server\":$JSONSRV
 ],
 \"Client\":$JSONCLT
  },$NewClient
 ]
}"

###################################################################
read -p "Do you wish to update the JSON file? Yes/No :" yn
case $yn in
  [Yy]*) 
	# check if backup folders exists
	if [ -d "$BASEDIR/$BCK" ]; then
     echo "Backup Directory ready: $BASEDIR/$BCK"
	else
	 echo "Backup directory created: $BASEDIR/$BCK"
	 mkdir -p $BASEDIR/$BCK
    fi   
	# backup config
	mv $BASEDIR/$JFILE $BASEDIR/$BCK/$(date +%Y%m%d_%H%M%S)_$JFILE 
    echo "$NEWJSON" > $BASEDIR/$JFILE
	echo "File updated: $BASEDIR/$JFILE"
    echo ""
	
	read -p "Do you want to generate the configuration files? Yes/No :" yn1
	case $yn1 in
	  [Yy]*)
       
	   wggenerate
	   
	   ;;
	  *)
	    echo ""
		echo "No configuration files generated."
		echo " run ./wg-adm.sh generate manually later"
		echo ""
    esac	
	;;
  *) 
    echo "no Update done"
	exit
	;;
  esac
}