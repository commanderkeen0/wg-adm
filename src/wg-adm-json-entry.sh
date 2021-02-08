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

wglistclients
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

TIP=$(( $TunnelIP + 1 ))
x=0
while [ $x -le 1 ]
do
 read -p "Client IP (last octet - suggestion: $TIP) : "  TunnelIP
 [[ $TunnelIP =~ ^[0-9]{1,3}$ ]] && [[ $TunnelIP -le 254 && $TunnelIP -gt 1  ]] && x=2 || echo "No Number between: 2-254"
done

# add the destination netwrok 
read -p 'VPN destination networks: if let empty 0.0.0.0/0 will be added: ' AllowedIPs

if [ "$AllowedIPs" == "" ]; 
 then 
  echo ""
  echo "Everything will be routed through the VPN Tunnel"
  echo ""
  read -p 'Do you want to exclude the RFC 1918 networks Yes/No:' RFC1918
  case $RFC1918 in
    [Yy]*)
       AllowedIPs="0.0.0.0/5, 8.0.0.0/7, 11.0.0.0/8, 12.0.0.0/6, 16.0.0.0/4, 32.0.0.0/3, 64.0.0.0/2, 128.0.0.0/3, 160.0.0.0/5, 168.0.0.0/6, 172.0.0.0/12, 172.32.0.0/11, 172.64.0.0/10, 172.128.0.0/9, 173.0.0.0/8, 174.0.0.0/7, 176.0.0.0/4, 192.0.0.0/9, 192.128.0.0/11, 192.160.0.0/13, 192.169.0.0/16, 192.170.0.0/15, 192.172.0.0/14, 192.176.0.0/12, 192.192.0.0/10, 193.0.0.0/8, 194.0.0.0/7, 196.0.0.0/6, 200.0.0.0/5, 208.0.0.0/4, 8.8.8.8/32"
	   ;;
	*)
       AllowedIPs="0.0.0.0/0, ::/0"
	   ;;  
  esac  
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

function wglistclients {

check_json
# get existing cleints and IP

 echo "Listing of existing Clients"
 echo "Last Octest - Client Name - Username"

 C=0
 CLT=$(echo $JSON | jq '.Client' | jq length)
 CLT=$(( $CLT - 1 ))
 while [ $C -le $CLT ]
  do
    ClientName=$(echo $JSON | jq '.Client['$C'].ClientName' | sed -s "s/\"//g")
    User=$(echo $JSON | jq '.Client['$C'].User' | sed -s "s/\"//g")
    TunnelIP=$(echo $JSON | jq '.Client['$C'].TunnelIP' | sed -s "s/\"//g")  

    EXISTINGCLT+="$TunnelIP - $ClientName - $User
"
	C=$(( $C + 1 )) 
 done

#echo "$EXISTINGCLT"

#return $TunnelIP $EXISTINGCLT
}