#! /bin/bash

# Definition of colors for text output
GREEN='\033[0;32m'
CYAN_BACK='\x1b[46m'

NOCOLOR='\033[0m'

echo  -e "${GREEN}======== Starte Installation =========${NOCOLOR}"

echo -e "${CYAN_BACK} Would you like to enable the System D service for atomatic start of video planback?"
read USERSELECT -p "(Y/N)"
echo -e "${NOCOLOR}"



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

wget -L "https://raw.githubusercontent.com/miT-nib-hcI/PiVideo/main/start.sh"
wget -L "https://raw.githubusercontent.com/miT-nib-hcI/PiVideo/main/stop.sh"
wget -L "https://raw.githubusercontent.com/miT-nib-hcI/PiVideo/main/reload.sh"

chmod 755 *.sh

echo  -e "${GREEN}======== Holle Videos========${NOCOLOR}"

cd videos/
wget -L "https://raw.githubusercontent.com/miT-nib-hcI/PiVideo/main/videos/loop.mp4"
wget -L "https://raw.githubusercontent.com/miT-nib-hcI/PiVideo/main/videos/trigger.mp4"

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

# Erstelle der PiVideo Service-Datei
echo "$SERVICE_CONTENT" | sudo tee /etc/systemd/system/$SERVICE_NAME > /dev/null

# Lade die Systemd-Dienste neu
echo  -e "${GREEN}======== Lade Dienste neu ========${NOCOLOR}"
sudo systemctl daemon-reload

if ["$USRSELECT" == "Y" ] || ["$USERSELECT" == "y"]
then
    USERSELECT=""
    # Aktiviere den Service, damit er beim Booten gestartet wird
    echo  -e "${GREEN}======== Aktiviern des Dienstes ========${NOCOLOR}"

    echo "Aktivire den PiVideo-Service..."
    sudo systemctl enable $SERVICE_NAME

    # Starten des Services
    echo  -e "${GREEN}======== Starente des Dienstes ========${NOCOLOR}"
    sudo systemctl start $SERVICE_NAME
else
    USERSELECT= ""
    echo -e "${CYAN_BACK} Automatic start of Playback disabled ${NOCOLOR}"
    echo -e "${CYAN_BACK} Did not start Service, to start use \"sudo systemctl start pivideo.service\" ${NOCOLOR}"
fi


echo  -e "${GREEN}=========================================================${NOCOLOR}"
echo  -e "${GREEN}======== Das Script wurde Erfolgreich Ausgeführt ========${NOCOLOR}"
echo  -e "${GREEN}=========================================================${NOCOLOR}"

exit 0