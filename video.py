import os
import time
import RPi.GPIO as GPIO
from subprocess import Popen, call
import sys

os.system('sudo chvt 1')

# Pfade zu den Dateien
THUMBNAIL_IMAGE = "/home/tim/PiVideo/videos/thumb.jpeg"
TRIGGER_VIDEO = "/home/tim/PiVideo/videos/trigger.mp4"
LOG_FILE = "/home/tim/PiVideo/log.txt"

# GPIO-Einstellungen
BUTTON_PIN = 17
GPIO.setmode(GPIO.BCM)
GPIO.setup(BUTTON_PIN, GPIO.IN, pull_up_down=GPIO.PUD_UP)

# Umleitung der Ausgaben in eine Log-Datei
sys.stdout = open(LOG_FILE, "a")
sys.stderr = open(LOG_FILE, "a")

def log_message(message):
    """Schreibt eine Nachricht in die Log-Datei."""
    timestamp = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
    print(f"{timestamp} - {message}")
    sys.stdout.flush()

def show_thumbnail(image_path):
    """Zeigt das Thumbnail an."""
    log_message(f"Displaying thumbnail: {image_path}")
    call(['sudo', 'fbi', '-T', '1', '-d', '/dev/fb0', '-a','-noverbose', image_path])

def close_thumbnail():
    """Beendet fbi, um das Thumbnail zu schließen."""
    log_message("Closing thumbnail.")
    call(['sudo', 'killall', 'fbi'])

def play_video(video_path):
    """Spielt das Trigger-Video ab."""
    log_message(f"Playing video: {video_path}")
    p = Popen(['cvlc', '--play-and-exit', '--fullscreen', '--no-video-title-show', video_path])
    p.wait()



def main():
    log_message("Starting main loop.")
    try:
        while True:
            # Thumbnail anzeigen
            show_thumbnail(THUMBNAIL_IMAGE)

            # Warten, bis der Button gedrückt wird
            while GPIO.input(BUTTON_PIN) == GPIO.HIGH:
                time.sleep(0.1)

            
            # Video abspielen, wenn Button gedrückt wurde
            log_message("Button pressed, playing trigger video.")
            play_video(TRIGGER_VIDEO)

            # fbi schließen, bevor das Video abgespielt wird
            close_thumbnail()
            # Nach dem Video wieder Thumbnail anzeigen
            log_message("Trigger video finished, displaying thumbnail again.")

    except KeyboardInterrupt:
        log_message("Script interrupted by user.")
    finally:
        GPIO.cleanup()
        log_message("GPIO cleanup completed. Exiting script.")

if __name__ == "__main__":
    log_message("Script started.")
    main()
