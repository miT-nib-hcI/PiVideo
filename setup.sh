#! /bin/bash

GREEN='\033[0;32m'
NOCOLOR='\033[0m'

echo  -e "${GREEN}======== Starte Installation =========${NOCOLOR}"

CURRENT_USER=$(whoami)
SERVICE_NAME="pivideo.service"

PYTHON_SCRIPT="/home/$CURRENT_USER/PiVideo/video.py"



echo $CURRENT_USER
echo $PYTHON_SCRIPT

echo  -e "${GREEN}======== Führe Update durch =========${NOCOLOR}"

sudo apt update && sudo apt upgrade -y

echo  -e "${GREEN}======== Installiere Abhängigkeiten =========${NOCOLOR}"
sduo apt install vlc python3-rpi.gpio git -y


echo  -e "${GREEN}======== Holle Datein ========${NOCOLOR}"

mkdir ~/PiVideo/ ~/PiVideo/videos/
cd ~/PiVideo/

wget -L "https://raw.githubusercontent.com/miT-nib-hcI/PiVideo/main/video.py"


echo  -e "${GREEN}======== Holle Videos========${NOCOLOR}"

cd videos/
wget -L "https://github.com/miT-nib-hcI/PiVideo/raw/main/loop.mp4"
wget -L "https://github.com/miT-nib-hcI/PiVideo/raw/main/trigger.mp4"

cd ..

echo  -e "${GREEN}======== Erestele Systemd Service ========${NOCOLOR}"

SERVICE_CONTENT="[Unit]
Description=Video Control Script
After=network.target

[Service]
ExecStart=/usr/bin/python3 $PYTHON_SCRIPT
WorkingDirectory=$(dirname $PYTHON_SCRIPT)
StandardOutput=inherit
StandardError=inherit
Restart=always
User=$CURRENT_USER

[Install]
WantedBy=multi-user.target
"

echo "$SERVICE_CONTENT" | sudo tee /etc/systemd/system/$SERVICE_NAME > /dev/null

# Lade die Systemd-Dienste neu
echo  -e "${GREEN}======== Lade Dienste neu ========${NOCOLOR}"
sudo systemctl daemon-reload

# Aktiviere den Service, damit er beim Booten gestartet wird
echo  -e "${GREEN}======== Aktiviern des Dienstes ========${NOCOLOR}"
sudo systemctl enable $SERVICE_NAME

# Starten des Services
echo  -e "${GREEN}======== Starente des Dienstes ========${NOCOLOR}"
sudo systemctl start $SERVICE_NAME



echo  -e "${GREEN}=========================================================${NOCOLOR}"
echo  -e "${GREEN}======== Das Script wurde Erfolgreich Ausgeführt ========${NOCOLOR}"
echo  -e "${GREEN}=========================================================${NOCOLOR}"

exit 0