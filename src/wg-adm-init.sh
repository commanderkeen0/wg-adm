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