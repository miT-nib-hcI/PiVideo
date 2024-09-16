#!/bin/bash

# Define colors for text output
GREEN='\033[0;32m'
CYAN_BACK='\x1b[46m'
RED='\033[0;31m'
NOCOLOR='\033[0m'

# Function for error handling
function check_error {
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: $1${NOCOLOR}"
        exit 1
    fi
}


# Check if the script is being run as root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}This script must be run as root (e.g., with sudo).${NOCOLOR}"
    exit 1
fi

echo -e "${GREEN}======== Starting Installation =========${NOCOLOR}"

# Prompt the user to add a systemd service for autostart
read -p "Do you want to add a systemd service for autostart? [y|n] " INPUT
SYSD=1

# Decide whether to set up systemd based on user input
case $INPUT in  
    y|Y) SYSD=0 ;; 
    n|N) SYSD=1 ;; 
    *) echo "Systemd service will not be added...." ;; 
esac

# Prompt the user to add GPIO power control
read -p "Do you want to add GPIO power control? [y|n] " INPUT
GPPower=1

# Decide whether to set up GPIO power control based on user input
case $INPUT in  
    y|Y) GPPower=0 ;; 
    n|N) GPPower=1 ;; 
    *) echo "GPIO power control will not be added.........." ;; 
esac

# Variables for paths and files
CURRENT_USER=$(logname)  # Get the username of the person who invoked the script
SERVICE_NAME="pivideo.service"
PYTHON_SCRIPT="/home/$CURRENT_USER/PiVideo/video.py"
GH_URL="https://raw.githubusercontent.com/miT-nib-hcI/PiVideo/main/"


# Update and install dependencies
echo -e "${GREEN}======== Performing system update =========${NOCOLOR}"
sudo apt update && sudo apt upgrade -y
check_error "Failed to update packages."


echo -e "${GREEN}======== Installing dependencies =========${NOCOLOR}"
sudo apt install -y vlc python3-rpi.gpio git fbi
check_error "Failed to install dependencies."


# Create directories and download files
echo -e "${GREEN}======== Downloading files ========${NOCOLOR}"


# Ensure directories exist and change to the correct directory
mkdir -p /home/$CURRENT_USER/PiVideo/videos/
cd /home/$CURRENT_USER/PiVideo/


# Function to download a file and check for errors
function download_file {
    local file=$1
    wget -q "$GH_URL$file"
    check_error "Failed to download $file"
}

# Download necessary scripts
download_file "video.py"
download_file "start.sh"
download_file "stop.sh"
download_file "reload.sh"

# Make the scripts executable
chmod 755 *.sh

echo -e "${GREEN}======== Downloading videos ========${NOCOLOR}"

cd videos/

# Download video files
download_file "videos/thumb.jpg"
download_file "videos/trigger.mp4"

cd ..

# Create the systemd service for autologin and video control
echo -e "${GREEN}======== Creating systemd service ========${NOCOLOR}"

# Video control service content
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
TTYPath=/dev/tty1
StandardInput=tty
RemainAfterExit=yes
Type=simple

[Install]
WantedBy=multi-user.target
"

# If the user opted for autostart, create the service files
if [ $SYSD -eq 0 ]; then
    # Disableing Login Promt for TTY1
    sudo systemctl disable getty@tty1.service

    # Creating Service file for Video Playback
    echo "$SERVICE_CONTENT" | sudo tee /etc/systemd/system/$SERVICE_NAME > /dev/null
    check_error "Failed to create PiVideo service."

    # Reload systemd and enable the service
    echo -e "${GREEN}======== Reloading services ========${NOCOLOR}"
    sudo systemctl daemon-reload
    check_error "Failed to reload systemd services."

    echo -e "${GREEN}======== Enabling the service ========${NOCOLOR}"
    sudo systemctl enable $SERVICE_NAME
    check_error "Failed to enable PiVideo service."

    echo -e "${GREEN}======== Starting the service ========${NOCOLOR}"
    sudo systemctl start $SERVICE_NAME
    check_error "Failed to start PiVideo service."
else
    # Creating Service file for Autologin of the Current User
    echo "$AUTOLOGIN_SERVICE_CONTENT" | sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf > /dev/null
    check_error "Failed to create autologin service."
    
    # Creating Service file for Video Playback
    echo "$SERVICE_CONTENT" | sudo tee /etc/systemd/system/$SERVICE_NAME > /dev/null
    check_error "Failed to create PiVideo service."

    echo -e "${CYAN_BACK}Automatic start of playback disabled${NOCOLOR}"
    echo -e "${CYAN_BACK}Did not start service, to start use \"sudo systemctl start $SERVICE_NAME\"${NOCOLOR}"
fi

# Configure GPIO power control if the user opted in
if [ $GPPower -eq 0 ]; then
    echo "dtoverlay=gpio-shutdown,gpio-pin=3" | sudo tee -a /boot/config.txt > /dev/null
    check_error "Failed to configure GPIO power control."
fi

echo -e "${GREEN}=========================================================${NOCOLOR}"
echo -e "${GREEN}======== The script was executed successfully ========${NOCOLOR}"
echo -e "${GREEN}=========================================================${NOCOLOR}"

exit 0

