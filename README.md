# Wireguard CLI management tool
This tool a collection of different bash scripts to create configuration files for 
wireguard servers and clients. 
All configuration items ares tored within a json file that currently needs to be managed
manually.

## Requirements
What is needed to make it work:
1. a SSH privat key per Server (or the same on each remote VPN server (not recommended))
2. 


### Packets
To get the CLI managemnt tool to run the following packets have to be installed

```bash
apt-get install wireguard jq 
```

### SSH
For remonte deployment SSH based filetransfer and access is used.
Be aware taht currently the "root" user is utilised at themoment therefore root access needs to granted:

Add / change the following entry in the /etc/ssh/sshd_config

```bash
PermitRootLogin without-password
```

## Structure
The setup of the main script tool and strucutre of teh JSON feil for server and cleint managament.

### Script
wg-adm.sh is the main script that will call different functions from other supporting files that 
are hosted in ./src/ folder:

```json
CFG
keys
src
	wg-adm-generate.sh
	wg-adm-update.sh
README.md
wg-adm.sh
wg.json
```

* CFG - is the Folder that will hold the configuration files of teh servers and clients
* keys - holding the SSH keys to access the remote VPN servers
* src - holding the aditional function files
* README.md - this file
* wg-adm.sh - main script
* wg.jason - data input file 

### JSON File
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

### Server
* "Servername" : "<SERVERNAME that is used internaly for generating config files>",
* "ServerPhyInt" : "<Physical interface that connects to the external world, needed for NAT configuration>",
* "ServerVirInt" : "<wireguard interface internally>",
* "Address" : "<INTERFACE IP of teh wireguard interface>",
* "ListenPort" : "<port which wireguard is running on>",
* "ServerPrivateKey" : "<Serer private key>",
* "PostUp" : "<NAT command when the wireguard interface comes up>",
* "PostDown" : "<NAT command when the wireguard interface comes down>",
* "FQDN" : "<FQDN / DYN DNS / IP - of the external interface, used to allow clients to connect>",
* "SSHKey" : "<SSH Key name used for accessing remote machines, they have to be in the ./keys folder ending with .priv>",
* "AdminIP" : "<Maanagment IP or FQDN for administrative access>",
* "SSHPort" : "<SSH Port>",
* "SSHUser" : "<access user>"

### Client
* "ClientName" : "<client name>",
* "User" : "<email address / Username>",
* "TunnelIP" : "<Last octet for teh client IP>",
* "ClientPrivateKey" : "<Client Private Key>",
* "PresharedKey" : "<Pre shared key for additional secruity>",
* "AllowedIPs" : "<networks that shall be reached>"


## Usage 

start the wd-adm-sh with the following commands

## set json file
```bash
# JSON input file
JFILE="wg.json"
```
change the JSON file to your setup one.

### generate configuration files
```bash
wg-adm.sh generate
```
This will automatically generate server and client configuration files out of the json file.
This File is set int he wg-adm.sh file:

### transfer config files to the wireguard server
```bash
wg-adm.sh update
```
This will copy the config files to the servers and will load delta configs. 
Whereas the interface configs are change a restart es needed.

### transfer config files to the wireguard server
```bash
wg-adm.sh restart
```
Putting down the wierguard interface and putting it back up.







## Known issues
* Error handling needs to be improved
* no JSON creation tool 
* usage of root user for deployment
* only one wireguard interface supported
* only networks smaller /24 networks supported as ip generation is just taking the first three octets from the server internal IP
* no explicit IPv6 support
* PSK needed for client configuration
* config fils are not check if they contain updates, they are transfered and update is executed



# License
[MIT](https://choosealicense.com/licenses/mit/)