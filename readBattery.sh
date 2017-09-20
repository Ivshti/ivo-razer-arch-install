#!/usr/bin/env bash

echo `date '+%Y-%m-%d %H:%M:%S'`,`/home/ivo/readBat.js` >> /home/ivo/.battery
tail -n 2000 /home/ivo/.battery > /home/ivo/.batteryTmp
mv /home/ivo/.batteryTmp /home/ivo/.battery
