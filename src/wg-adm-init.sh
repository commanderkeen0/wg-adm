#!/bin/bash
#
# Initialise wireguard server based on input file
#
function wginit {
 echo ""
 echo "##############################################################"
 echo "##                                                          ##"
 echo "##    Initialize an interface on a remote server            ##"
 echo "##                                                          ##"
 echo "##############################################################"
 echo ""
 echo "UNDER DEVELOPMENT"

}

function wgadmsetup {
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
}


function wggenjson {

echo "
##############################################################
##                                                          ##
##    generate sample config                                ##
##                                                          ##
##                                                          ##
##############################################################
"

read -p "Filename / Interfacename (suffix .json will be added) ? :" NFILENAME
read -p "How many server shall be preconfigured ? :" NSRV
read -p "How many clients shall be configured ? :" NCLT
read -p "exclude RFC1918 ? Y/N :" RFC1918

JCONFIG='
{
 "Server":['

 S=1
 while [ $S -le $NSRV ]
  do

SPRIVKEY=$(wg genkey)

JCONFIG+="
   {    
    \"Servername\": \"srv$S\",
    \"ServerPhyInt\": \"enp0s3\",
    \"ServerVirInt\": \"wg0\",
    \"Address\": \"10.112.$S.1/24\",
    \"ListenPort\": \"51820\",
    \"ServerPrivateKey\": \"$SPRIVKEY\",
    \"PostUp\": \"PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o INT -j MASQUERADE\",
    \"PostDown\": \"PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o INT -j MASQUERADE\",
    \"DNSSRV\" : \"8.8.8.8\",
    \"FQDN\": \"srv$S\",
    \"SSHKey\": \"srv$S\",
    \"AdminIP\": \"srv$S\",
    \"SSHPort\": \"22\",
    \"SSHUser\": \"root\"
"
NSRVK=$(( $NSRV -1 ))
if [ $S -le $NSRVK ] 
 then 
  JCONFIG+="   },"
 else
 JCONFIG+="   }"
fi

S=$(( $S + 1 ))
done

JCONFIG+="
 ],
 \"Client\":["

# ###########################################
 
 S=1
 while [ $S -le $NCLT ]
  do

 PRIVKEY=$(wg genkey)
 PSK=$(wg genpsk)
  case $RFC1918 in
    [Yy]*)
       AllowedIPs="0.0.0.0/5, 8.0.0.0/7, 11.0.0.0/8, 12.0.0.0/6, 16.0.0.0/4, 32.0.0.0/3, 64.0.0.0/2, 128.0.0.0/3, 160.0.0.0/5, 168.0.0.0/6, 172.0.0.0/12, 172.32.0.0/11, 172.64.0.0/10, 172.128.0.0/9, 173.0.0.0/8, 174.0.0.0/7, 176.0.0.0/4, 192.0.0.0/9, 192.128.0.0/11, 192.160.0.0/13, 192.169.0.0/16, 192.170.0.0/15, 192.172.0.0/14, 192.176.0.0/12, 192.192.0.0/10, 193.0.0.0/8, 194.0.0.0/7, 196.0.0.0/6, 200.0.0.0/5, 208.0.0.0/4, 8.8.8.8/32"
	   ;;
	*)
       AllowedIPs="0.0.0.0/0, ::/0"
	   ;;  
  esac 
 IP=$(( $S + 10 ))
 JCONFIG+="
    {
    \"ClientName\": \"clt$S\",
    \"User\": \"clt3@mydomain.corp\",
    \"TunnelIP\": \"$IP\",
    \"ClientPrivateKey\": \"$PRIVKEY\",
    \"PresharedKey\": \"$PSK\",
    \"AllowedIPs\": \"$AllowedIPs\"
"

 NCLTK=$(( $NCLT -1 ))
 if [ $S -le $NCLTK ] 
  then 
   JCONFIG+="   },"
  else
  JCONFIG+="   }"
 fi

 S=$(( $S + 1 ))
 done

JCONFIG+="
  ]
}
"

 echo "$JCONFIG"
 echo "$JCONFIG" >> $NFILENAME.json

}