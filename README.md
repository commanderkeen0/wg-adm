 # Wireguard CLI management tool
This tool a collection of different bash scripts to create configuration files for 
wireguard servers and clients. 
All configuration items are stored within a json file that currently needs to be managed
manually.

Currently tested distriubutions are: Debian / Ubuntu

# Requirements
What is needed to make it work:

You need a fair knowledge of SSH and Linux. 
Further this tool shall not run on any of the VPN servers as keys and configuration files are created and stored unencrypted.
Recommendation is to run that management script on a dedicated secured pc. 

1. Servers with wireguard and jq installed, 
2. An environement where configs are sotred in /etc/wireguard
3. A SSH privat key per Server (USE DIFFERENT keys for teh sake of security)

## Packets
To get the CLI managemnt tool to run the following packets have to be installed

```bash
apt-get install wireguard jq 
```

## SSH
For remonte deployment SSH based access and filetransfer is used.

# Structure
The setup of the main script tool and strucutre of teh JSON feil for server and cleint managament.

## Script
wg-adm.sh is the main script that will call different functions from other supporting files that 
are hosted in ./src/ folder:

```json
BCK
CFG
keys
src
    wg-adm-generate.sh
    wg-adm-init.sh
    wg-adm-json-entry.sh
    wg-adm-update.sh
README.md
wg-adm.sh
wg0.json

```

* BCK - Backupfolder for the json creation script
* CFG - is the Folder that will hold the configuration files of teh servers and clients
* keys - holding the SSH keys to access the remote VPN servers
* src - holding the aditional function files
* README.md - this file
* wg-adm.sh - main script
* wg0.jason - default data input file (can be modified)

## JSON File
The structure of the JSON file is needed as following:

```json
{
  "Server":[
    {
	 "Servername" : "wgs1",
	 "ServerPhyInt" : "enp0s3",
	 "ServerVirInt" : "wg0",
	 "Address" : "10.11.1.1/24",
     "ListenPort" : "51820",
     "ServerPrivateKey" : "KIl1BGc+cWXXFVnj5waufVzKWJ3Q123u5niI/TzV6lg=",
	 "PostUp" : "PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o INT -j MASQUERADE",
     "PostDown" : "PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o INT -j MASQUERADE",
	 "FQDN" : "172.23.20.179",
	 "SSHKey" : "wgs1",
	 "AdminIP" : "172.23.20.180",
	 "SSHPort" : "22",
	 "SSHUser" : "root"
	},
    { 
	 "Servername" : "wgs2",
	 "ServerPhyInt" : "enp0s3",
	 "ServerVirInt" : "wg0",
	 "Address" : "10.2.3.1/24",
     "ListenPort" : "51820",
     "ServerPrivateKey" : "GEjYMlkcGK6LsUBq3w6HDqtHzmDYiiUNP0tWB7LdqlM=",
	 "PostUp" : "PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o INT -j MASQUERADE",
     "PostDown" : "PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o INT -j MASQUERADE",
	 "FQDN" : "172.23.20.180",
	 "SSHKey" : "wgs2",
	 "AdminIP" : "172.23.20.179",
	 "SSHPort" : "22",
	 "SSHUser" : "root"
	}
  ],
  "Client": [
    {
      "ClientName" : "clt1",
	  "User" : "clt1@mydomain.corp",
	  "TunnelIP" : "11",
	  "ClientPrivateKey" : "UIbq4Z6hl5ZE+UemaE6q16WehcL8C7X0B8ZoAyTnx3Y=",
	  "PresharedKey" : "+9hiljPxWZjonvIqdco3q73875L91c4pqP+DM7vBUfU=",
	  "AllowedIPs" : "0.0.0.0/0, ::/0"
	},
    {
      "ClientName" : "clt2",
	  "User" : "clt2@mydomain.corp",
	  "TunnelIP" : "12",
	  "ClientPrivateKey" : "OMTEOu6PzXraGoEgxZLo55QUMJ2uoVVGRLzeJfuw+HQ=",
	  "PresharedKey" : "P6r8veq4JUUkKdQkw20k2GvwoUCNLNLwb0oDvGYJcK8=",
	  "AllowedIPs" : "0.0.0.0/0, ::/0"
	},
    {
      "ClientName" : "clt3",
	  "User" : "clt3@mydomain.corp",
	  "TunnelIP" : "13",
	  "ClientPrivateKey" : "APjFfGvS2+b5woCbp0gnHpRSZrDDXZAQ1o9wBtvAkW4=",
	  "PresharedKey" : "cTmFlWyFwM99bB9vmZ4CBSke3XHTAq4sICNW5kuPYGU=",
	  "AllowedIPs" : "0.0.0.0/0, ::/0"
	}

  ]

}
```

## Server
* "Servername" : "SERVERNAME that is used internaly for generating config files>,
* "ServerPhyInt" : "Physical interface that connects to the external world, needed for NAT configuration",
* "ServerVirInt" : "wireguard interface internally",
* "Address" : "INTERFACE IP of teh wireguard interface",
* "ListenPort" : "port which wireguard is running on",
* "ServerPrivateKey" : "Serer private key",
* "PostUp" : "NAT command when the wireguard interface comes up",
* "PostDown" : "NAT command when the wireguard interface comes down",
* "FQDN" : "FQDN / DYN DNS / IP - of the external interface, used to allow clients to connect",
* "SSHKey" : "SSH Key name used for accessing remote machines, they have to be in the $KEYS folder ending with .priv",
* "AdminIP" : "Maanagment IP or FQDN for administrative access",
* "SSHPort" : "SSH Port",
* "SSHUser" : "access user"

## Client
* "ClientName" : "client name",
* "User" : "email address / Username",
* "TunnelIP" : "Last octet for teh client IP",
* "ClientPrivateKey" : "Client Private Key",
* "PresharedKey" : "Pre shared key for additional secruity",
* "AllowedIPs" : "networks that shall be reached"


# Installation
How to get this tool working? 

## set json file
```bash
# JSON input file
JFILE="wg0.json"
```
This file contains the configuration of a single wireguard interface. 
Multiple filed can support different interfaces.

 ** MULTI INTERFACE is under development **

## configure your folders in wg-adm.sh
* JSON input file
JFILE="wg0.json"
* Basedir where the script resides
BASEDIR=$(pwd)
* Configuration Folder
CFG="CFG"
* Folder for Backup files (can be changed)
BCK="BCK"
* filder that hosts the SSH keys to the other servers
KEYS="keys"
* Full Path to the config folder
CDIR=$BASEDIR"/"$CFG
* applied DNS Servers via VPN
DNSSRV="8.8.8.8"


## prepare the environment 
```bash
wg-adm.sh setup
```
This will generate the configured environment folders.

## SSH access to remote servers
Be aware that currently the "root" user is utilised at themoment therefore root access needs to granted:
Add / change the following entry in the /etc/ssh/sshd_config
```bash
PermitRootLogin without-password
```
Further copy the public key of the management user to the remote VPN server to gain access.
The different SSH keys must terminated with ".priv" and be stored in the $KEYS folder. The name is configured in the json file under: "SSHKey"

It is addvised to use different keys for each server you have. 
 

## setup wireguard initially on your server

1. install wireguard
2. enable ip forwarding
3. create your json file and add your server manually including the first client(further clients can be added via command)
4. copy manually the generated server config to the server
4. modify your firewall (if any)
5. start the wireguard interface
6. enable autostart of the service

[Wireguard quickstart](https://www.wireguard.com/quickstart/)
[Wireguard HowTo - UPCLOUD](https://upcloud.com/community/tutorials/get-started-wireguard-vpn/)


# Usage 
Start the wd-adm-sh with the following commands

## generate configuration files
```bash
wg-adm.sh generate
```
This will automatically generate server and client configuration files out of the json file.

## transfer config files to the wireguard server
```bash
wg-adm.sh update
```
This will copy the config files to the servers and will load delta configs. 
Whereas the interface configs are change a restart es needed.

## transfer config files to the wireguard server
```bash
wg-adm.sh restart
```
Putting down the wierguard interface and putting it back up on the remote servers.

## transfer config files to the wireguard server
```bash
wg-adm.sh addclient
```
Add additional client to the json file.

## add additional clients to the json file
```bash
wg-adm.sh addclient
```
Add additional client to the json file.




# Known issues
* SPELL and GRAMMAR CHECK
* Error handling needs to be improved
* no JSON management tool tool 
* usage of root user for deployment
* only one wireguard interface supported
* only networks smaller /24 networks supported as ip generation is just taking the first three octets from the server internal IP
* no explicit IPv6 support
* PSK needed for client configuration
* config fils are not check if they contain updates, they are transfered and update is executed
* no checking of client names / server names - only no space names are supported
* no round robin in the backup folder

# Solved
* Client config creation tool added


# License
[MIT](https://choosealicense.com/licenses/mit/)