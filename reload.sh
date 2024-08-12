#! /bin/bash

## A simple whitch stops the current service and Starts it again
## used to run the current version of the script after modification

# Definition of colors for the echo outputs
GREEN='\033[0;32m'
NOCOLOR='\033[0m'

# Servicename which this script affects
SERVICE_NAME="pivideo.service"

echo  -e "${GREEN}======== Stoppe Dienst =========${NOCOLOR}"
sudo systemctl stop $SERVICE_NAME


echo  -e "${GREEN}======== Starte Dienst =========${NOCOLOR}"
sudo systemctl start $SERVICE_NAME

exit 0