#!/bin/env bash

DEVID=$(xinput list | grep Synaptics | grep -Eio '(touchpad|glidepoint)\s*id\=[0-9]{1,2}' | grep -Eo '[0-9]{1,2}')
DEVID=15
xinput set-prop $DEVID "libinput Tapping Enabled" 1
xinput set-prop $DEVID "libinput Natural Scrolling Enabled" 1
#xinput set-prop $DEVID "libinput Accel Speed" 0.3
