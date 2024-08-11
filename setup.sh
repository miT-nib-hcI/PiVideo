#! /bin/bash

GREEN='\033[0;32m'
NOCOLOR='\033[0m'

echo  -e "${GREEN}======== Starte Installation =========${NOCOLOR}"


CURRENT_USER=$(whoami)
SERVICE_NAME="pivideo.service"
AUTOLOGIN_SERVICE_NAME="autologin@tty1.service"

PYTHON_SCRIPT="/home/$CURRENT_USER/PiVideo/video.py"


echo  -e "${GREEN}======== Führe Update durch =========${NOCOLOR}"

sudo apt update && sudo apt upgrade -y

echo  -e "${GREEN}======== Installiere Abhängigkeiten =========${NOCOLOR}"
sudo apt install vlc python3-rpi.gpio git -y


echo  -e "${GREEN}======== Holle Datein ========${NOCOLOR}"

mkdir ~/PiVideo/ ~/PiVideo/videos/
cd ~/PiVideo/

wget -L "https://raw.githubusercontent.com/miT-nib-hcI/PiVideo/main/video.py"


echo  -e "${GREEN}======== Holle Videos========${NOCOLOR}"

cd videos/
wget -L "https://raw.githubusercontent.com/miT-nib-hcI/PiVideo/main/videos/loop.mp4"
wget -L "https://raw.githubusercontent.com/miT-nib-hcI/PiVideo/main/videos/trigger.mp4"

cd ..

echo  -e "${GREEN}======== Erestele Systemd Service ========${NOCOLOR}"

AUTOLOGIN_SERVICE_CONTENT="[Unit]
Description=Automatic Console Login
After=rc-local.service plymouth-quit-wait.service
After=systemd-user-sessions.service
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=-/sbin/agetty --autologin $CURRENT_USER --noclear %I \$TERM
Type=idle
Restart=always
RestartSec=0

[Install]
WantedBy=multi-user.target
"

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

# Erstelle die Autologin-Service-Datei
echo "Erstelle die Autologin-Service-Datei unter /etc/systemd/system/getty@tty1.service.d/override.conf..."
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d/

echo "$AUTOLOGIN_SERVICE_CONTENT" | sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf > /dev/null


# Erstelle der PiVideo Service-Datei
echo "$SERVICE_CONTENT" | sudo tee /etc/systemd/system/$SERVICE_NAME > /dev/null

# Lade die Systemd-Dienste neu
echo  -e "${GREEN}======== Lade Dienste neu ========${NOCOLOR}"
sudo systemctl daemon-reload

# Aktiviere den Service, damit er beim Booten gestartet wird
echo  -e "${GREEN}======== Aktiviern des Dienstes ========${NOCOLOR}"
echo "Aktiviere den Autologin-Service..."
sudo systemctl enable getty@tty1.service

echo "Aktivire den PiVideo-Service..."
sudo systemctl enable $SERVICE_NAME

# Starten des Services
echo  -e "${GREEN}======== Starente des Dienstes ========${NOCOLOR}"

sudo systemctl start getty@tty1.service
sudo systemctl start $SERVICE_NAME



echo  -e "${GREEN}=========================================================${NOCOLOR}"
echo  -e "${GREEN}======== Das Script wurde Erfolgreich Ausgeführt ========${NOCOLOR}"
echo  -e "${GREEN}=========================================================${NOCOLOR}"

exit 0