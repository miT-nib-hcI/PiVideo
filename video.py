#! /usr/bin/python3

import RPi.GPIO as GPIO
import subprocess
import time

# GPIO-Setup
BUTTON_PIN = 17  # Ersetze dies durch den tatsächlichen GPIO-Pin, den du verwendest
GPIO.setmode(GPIO.BCM)
GPIO.setup(BUTTON_PIN, GPIO.IN, pull_up_down=GPIO.PUD_UP)

loop_video = 'videos/loop.mp4'
trigger_video = 'videos/trigger.mp4'

# Funktion zum Abspielen eines Videos
def play_video(video_file):
    subprocess.run(['cvlc', '--play-and-exit', '--fullscreen', '--no-video-title-show', video_file])

# Endlosschleife Video 1 starten
loop_video = subprocess.Popen(['cvlc', '--loop', '--fullscreen', '--no-video-title-show', loop_video])

try:
    while True:
        # Überprüfen, ob der Button gedrückt wurde
        button_state = GPIO.input(BUTTON_PIN)
        if button_state == GPIO.LOW:  # Button gedrückt
            # Stoppe das loop_video
            loop_video.terminate()

            # Video 2 abspielen
            play_video(trigger_video)

            # Nach dem Abspielen von Video 2 wieder Video 1 in Schleife starten
            loop_video = subprocess.Popen(['cvlc', '--loop', '--fullscreen', '--no-video-title-show', loop_video])

        time.sleep(0.1)  # Entprellen des Buttons

except KeyboardInterrupt:
    # Bei einem Tastaturabbruch das laufende Video stoppen und GPIO reinigen
    loop_video.terminate()
    GPIO.cleanup()