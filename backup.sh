#!/bin/bash

function hx {
	echo "obase=16; 34" | bc
}
function dt {
	year=$(date +%Y)
	month=$(date +%m)
	day=$(date +%d)
	printf "%03x%01x%02x" $year $month $day
}

src=~/p/crypt.sh
bak=/mnt/safe/backup/crypt.sh_$(dt)/

if [ ! -e /mnt/safe ]; then
	echo -e "Cannot backup; Safe not open"
	exit 1
fi

cp -r $src $bak
