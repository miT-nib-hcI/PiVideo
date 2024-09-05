#! /bin/bash

## A simple script which starts the playing of the Video and enables the SystemD service

# Definition of colors for the echo outputs
GREEN='\033[0;32m'
NOCOLOR='\033[0m'

# Servicename which this script affects
SERVICE_NAME="pivideo.service"

echo  -e "${GREEN}======== STARTING SERVICE =========${NOCOLOR}"
sudo systemctl start $SERVICE_NAME


echo  -e "${GREEN}======== ENABELING SERVICE =========${NOCOLOR}"
sudo systemctl enable $SERVICE_NAME

exit 0
