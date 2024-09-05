# Überblick
Diese Codebase wured 08/09 2024 von Tim Schilling entwickelt um ein alltes gerät im Lechfeldmuseum der Stadt Königsbrunn zu ersetzten. Das Script ist für die Verwendung auf einen Raspberry Pi gedacht.
Dieses Script verwendet für das Spielen von Videos VLC bzw die Commandline variante '''cvlc''', das Scipt weches für das Automatische Abspeielen der Videos sowie der wechsel zwischen den zwei Videos ist in Pyhton geschrieben.

## Abhängigkeiten
- vlc -> Video Lan Client, anwendung zum Abspielen von Videos
- python3-rpi.gpio -> Python Bibliothek welche für die Verwendung der GPIO gebraucht wird.

## Skripte
Zusätzlich wurden für die Leichte Installation des Systems sowie für die Kontrolle im betrieb einige Shellskipts angelegt welche folgende Aufgaben haben:

- setup.sh -> Setup Script welches mehrere aufgaben erfüllt, dies führt (in Reienfolge der Ausführtung)
    1. Fragt den Nutzer ob für diesen der Autostart dienst Verwendet werden soll.
    2. Fragt den Nutzer ob die GPIO Shutdown funktion des Raspberry Pi verwendet werden soll.
    3. Führt ein Systemupdate über den APT aus
    4. Installiert die Abhängigkeiten
    5. Herunterladen der Aktuellen Scripte aus dem GitHub Repo
    6. Herunterladen der Videos aus dem GitHub Repo (**ACHTUNG: Wenn sich die Datein im Repo Geänder haben müssen die Datein im Skript entsprechend Angepasst werden.**)
    7. Festlegen von SystemD dienst Datein Inhalt
    8. Erstellen der System D Service Datein und Einschalten dieser je nach vorheriger Nutzerauswahl
    9. Einfügen der zeile in /boot/config.txt für GPIO Shutdown

- video.py -> Script welches die Videos Abspielt
- start.sh -> Skript zum starten der Wiedergabe, schaltet gleichzeitig den Autostart der Anwendung über einen SystemD dienst **EIN**
- stop.sh -> Skript zum stoppen der Wiedergabe, schaltet gleichzeitig den Autostart der Anwendung über einen SystemD dienst **AUS**
- reload.sh -> Skript zum Neustarten der Wiedergabe, stop diese über System D und startet diese wieder

## Dateistrucktur
```
- PiVideo/
    |- videos/
    |   |- loop.mp4
    |   |- trigger.mp4
    |- video.py
    |- start.sh
    |- stop.sh
    |- reload.sh
```
