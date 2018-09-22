#!/bin/env bash

DEVID=$(xinput list | grep Synaptics | grep -Eio '(touchpad|glidepoint)\s*id\=[0-9]{1,2}' | grep -Eo '[0-9]{1,2}')

# palm detection
xinput set-prop $DEVID "Synaptics Palm Detection" 1
xinput set-prop $DEVID "Synaptics Palm Dimensions" 5, 10
#natural scrolling
xinput set-prop $DEVID "Synaptics Scrolling Distance" -94 -94
# tap to click, two f fingers is right click
# if you want tap to click, make it 1 3 2
xinput set-prop $DEVID  "Synaptics Tap Action" 0 0 0 0 1 3 2
# Speed

xinput set-prop $DEVID "Synaptics Finger" 25, 30, 45

# Disable while typing - workaround to touchpad not working
syndaemon -i 0.4 -t -d -R # -K


#synclient PalmDetect=1
#synclient PalmMinWidth=5
#synclient PalmMinZ=10
