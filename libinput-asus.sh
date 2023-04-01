#!/bin/env bash

DEVID=$(xinput list | grep Synaptics | grep -Eio '(touchpad|glidepoint)\s*id\=[0-9]{1,2}' | grep -Eo '[0-9]{1,2}')
DEVID=13
xinput set-prop $DEVID "libinput Tapping Enabled" 1
xinput set-prop $DEVID "libinput Natural Scrolling Enabled" 1
xinput set-prop $DEVID "libinput Disable While Typing Enabled" 0

#xinput set-prop $DEVID "libinput Accel Speed" 0.3
