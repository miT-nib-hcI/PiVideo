#! /bin/bash

GREEN='\033[0;32m'
NOCOLOR='\033[0m'
SERVICE_NAME="pivideo.service"

echo  -e "${GREEN}======== Starte Dienst =========${NOCOLOR}"
sudo systemctl start $SERVICE_NAME


echo  -e "${GREEN}======== Starte Autostart des Diensts =========${NOCOLOR}"
sudo systemctl enable $SERVICE_NAME

exit 0