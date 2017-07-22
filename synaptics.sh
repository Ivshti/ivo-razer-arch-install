#!/bin/env bash

DEVID=$(xinput list | grep Synaptics | awk '{print $5}' | cut -d'=' -f2)

# palm detection
xinput set-prop $DEVID "Synaptics Palm Detection" 1
#natural scrolling
xinput set-prop $DEVID "Synaptics Scrolling Distance" -94 -94
# tap to click, two f fingers is right click
xinput set-prop $DEVID  "Synaptics Tap Action" 0 0 0 0 1 3 2
