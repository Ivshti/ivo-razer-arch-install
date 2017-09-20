#!/usr/bin/env bash

cat ~/.battery | tail -n 1000 | gnuplot -p battery.gnuplot
