# PiVideo

## Overview

This is a collection of scripts which run a video in a loop until a Button connected to GPIO is Pressed.
Then another video is played once.

## Installation
For installation download and run setup.sh. This will install the nesecary dependencys, create the needed folder structure and download the Script.
It will also create a SystemD service to automaticly start the program when the Pi is booted.

```bash
wget -L "https://raw.githubusercontent.com/miT-nib-hcI/PiVideo/main/setup.sh"
chmod 755 setup.sh
./setup.sh
```

## Configuration
Since it is a realativly simple Python script you can modify as needed.
The videos which are played are in the videos folder, as the nameing of the files suggests the loop.mp4 is played on loop and the trigger.mp4 is played once when the GPIO button has been pressed.
You can replace the files as needed with your own files. The files included right now are just for demonstration.

- PiVideo/
    |- videos/
    |   |- loop.mp4
    |   |- trigger.mp4
    |- video.py
    |- start.sh
    |- stop.sh
    |- reload.sh

The button to trigger the video switch is by default conected to GPIO 17 and GND, you can change this in the Scipt itself if needed.