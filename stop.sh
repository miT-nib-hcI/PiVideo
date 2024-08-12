#! /bin/bash

## A simple script which stops the playing of the Video and disables the SystemD service

# Definition of colors for the echo outputs
GREEN='\033[0;32m'
NOCOLOR='\033[0m'

# Servicename which this script affects
SERVICE_NAME="pivideo.service"


echo  -e "${GREEN}======== STOPING SERVICE =========${NOCOLOR}"
sudo systemctl stop $SERVICE_NAME


echo  -e "${GREEN}======== DISABELING SERVICE =========${NOCOLOR}"
sudo systemctl disable $SERVICE_NAME

exit 0