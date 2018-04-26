#!/bin/env bash

DEVID=$(xinput list | grep Synaptics | grep -Eio '(touchpad|glidepoint)\s*id\=[0-9]{1,2}' | grep -Eo '[0-9]{1,2}')

# palm detection
xinput set-prop $DEVID "Synaptics Palm Detection" 1
xinput set-prop $DEVID "Synaptics Palm Dimensions" 5, 80
#natural scrolling
xinput set-prop $DEVID "Synaptics Scrolling Distance" -94 -94
# tap to click, two f fingers is right click
xinput set-prop $DEVID  "Synaptics Tap Action" 0 0 0 0 1 3 2
