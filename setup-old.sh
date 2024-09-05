#! /bin/bash

# Definition of colors for text output
GREEN='\033[0;32m'
CYAN_BACK='\x1b[46m'

NOCOLOR='\033[0m'

echo  -e "${GREEN}======== Starte Installation =========${NOCOLOR}"

read  -p "Do you want to add a SystemD Service for Autostart [y|n]" INPUT
SYSD=1

case $INPUT in  
  y|Y) SYSD=0 ;; 
  n|N) SYSD=1 ;; 
  *) echo "SystemD Service will not be Added...."  ;; 
esac
INPUT=""

read  -p "Do you want to add GPIO Power Controle [y|n]" INPUT
GPPower=1

case $INPUT in  
  y|Y) GPPower=0 ;; 
  n|N) GPPower=1 ;; 
  *) echo "GPIO Power controll will not be Addaded.........."  ;; 
esac


CURRENT_USER=$(whoami)
SERVICE_NAME="pivideo.service"
AUTOLOGIN_SERVICE_NAME="autologin@tty1.service"

PYTHON_SCRIPT="/home/$CURRENT_USER/PiVideo/video.py"


echo  -e "${GREEN}======== Führe Update durch =========${NOCOLOR}"

sudo apt update && sudo apt upgrade -y

echo  -e "${GREEN}======== Installiere Abhängigkeiten =========${NOCOLOR}"
sudo apt install vlc python3-rpi.gpio git -y


echo  -e "${GREEN}======== Holle Datein ========${NOCOLOR}"

if ls ~/PiVideo/ 1> /dev/null 2>&1; # Checking if file exsists
then
  echo "Folders Already Exist Scipping"
else
  echo "Creating Folders"
  mkdir ~/PiVideo/ ~/PiVideo/videos/
  cd ~/PiVideo/
fi

GH_URL="https://raw.githubusercontent.com/miT-nib-hcI/PiVideo/main/"

if ls ~/PiVideo/video.py 1> /dev/null 2>&1; # Checking if file exsists
then
  echo "Script exists, updateing ..."
  rm ~/PiVideo/video.py # Removing Old File

  wget -L $GH_URL"video.py"

  rm ~/PiVideo/*.sh # Removing Old Files
  wget -L $GH_URL"start.sh"
  wget -L $GH_URL"stop.sh"
  wget -L $GH_URL"reload.sh"
else
  wget -L $GH_URL"video.py"
  wget -L $GH_URL"start.sh"
  wget -L $GH_URL"stop.sh"
  wget -L $GH_URL"reload.sh"
fi



chmod 755 *.sh

echo  -e "${GREEN}======== Holle Videos========${NOCOLOR}"

cd videos/

if ls ~/PiVideo/videos/loop* 1> /dev/null 2>&1; # Checking if file exsists
then
  echo "Video exists, updateing ..."
  rm ~/PiVideo/videos/loop* # Removing Old Files

  wget -L $GH_URL"videos/loop.mp4"
else
  wget -L $GH_URL"videos/loop.mp4"
fi



if ls ~/PiVideo/videos/trigger* 1> /dev/null 2>&1; # Checking if file exsists
then
  echo "Video exists, updateing ..."
  rm ~/PiVideo/videos/trigger* # Removing Old Files

  wget -L $GH_URL"videos/trigger.webm"
else
  wget -L $GH_URL"videos/trigger.webm"
fi
cd ..

echo  -e "${GREEN}======== Erestele Systemd Service ========${NOCOLOR}"

AUTOLOGIN_SERVICE_CONTENT="[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $CURRENT_USER --noclear tty1 linux
"

# Erstelle die Autologin-Service-Datei
echo "Erstelle die Autologin-Service-Datei unter /etc/systemd/system/getty@tty1.service.d/override.conf..."
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d/

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


echo "$AUTOLOGIN_SERVICE_CONTENT" | sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf > /dev/null

# Erstelle der PiVideo Service-Datei
echo "$SERVICE_CONTENT" | sudo tee /etc/systemd/system/$SERVICE_NAME > /dev/null

# Lade die Systemd-Dienste neu
echo  -e "${GREEN}======== Lade Dienste neu ========${NOCOLOR}"
sudo systemctl daemon-reload

if [ $SYSD -eq 0 ]
then
    # Aktiviere den Service, damit er beim Booten gestartet wird
    echo  -e "${GREEN}======== Aktiviern des Dienstes ========${NOCOLOR}"

    echo "Aktivire den PiVideo-Service..."
    sudo systemctl enable $SERVICE_NAME

    # Starten des Services
    echo  -e "${GREEN}======== Starente des Dienstes ========${NOCOLOR}"
    sudo systemctl start $SERVICE_NAME
else
    echo -e "${CYAN_BACK} Automatic start of Playback disabled ${NOCOLOR}"
    echo -e "${CYAN_BACK} Did not start Service, to start use \"sudo systemctl start pivideo.service\" ${NOCOLOR}"
fi

if [ $GPPower -eq 0 ]
then
  echo "dtoverlay=gpio-shutdown,gpio-pin=3" | sudo tee /boot/config.txt > /dev/null
fi

echo  -e "${GREEN}=========================================================${NOCOLOR}"
echo  -e "${GREEN}======== Das Script wurde Erfolgreich Ausgeführt ========${NOCOLOR}"
echo  -e "${GREEN}=========================================================${NOCOLOR}"

exit 0
