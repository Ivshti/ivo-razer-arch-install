#!/usr/bin/env node

var fs = require('fs')

var p = '/sys/class/power_supply/BAT0/'

function readInt(v) 
{
	return parseInt(fs.readFileSync(p+v).toString())
}

process.stdout.write( (readInt('energy_now') / readInt('energy_full')).toFixed(4) )
