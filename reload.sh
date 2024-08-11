#! /bin/bash

GREEN='\033[0;32m'
NOCOLOR='\033[0m'
SERVICE_NAME="pivideo.service"

echo  -e "${GREEN}======== Stoppe Dienst =========${NOCOLOR}"
sudo systemctl stop $SERVICE_NAME


echo  -e "${GREEN}======== Starte Dienst =========${NOCOLOR}"
sudo systemctl start $SERVICE_NAME

exit 0