#!/bin/bash

# PATH TO FUNCTIONS FILE
FUNCTIONS_PATH="./functions/"


# FUNCTIONS SOURCE
source $FUNCTIONS_PATH'functions.sh'

displayMenu

# change vagrant file (reg ex ne marche pas ...): sed -i.bak "s@# config.vm.network \"private_network\", ip: \"192.168.33.10\"@config.vm.network \"private_network\", ip: \"192.168.33.20\"@g" ./Vagrantfile;