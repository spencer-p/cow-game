#!/bin/bash

if [[ $# -lt 1 ]]
then
	echo "Error - no version"
	exit 1
fi

IFS=' '

base="$HOME/public/cow-game"

files=('main.lua' 'pie.lua' 'cow.lua' 'powerup.lua' 'cooldown.lua' 'timer.lua' 'flux.lua' 'camera.lua' 'classic.lua' 'disneymathmagic.lua' 'cow.png' 'cow-invert.png' 'lose.wav' 'point.wav' 'powerup.wav' 'start.wav' 'unce.wav')
version=$1

fulldir=${base}/version-${version}
manifest=${base}/meta/manifest-${version}.lua

if [[ -d $fulldir ]]
then
	echo "Error - version already exists"
	exit 2
fi

if [[ ! -d $base ]]
then
	mkdir $base
fi

if [[ ! -d $base/meta ]]
then
	mkdir $base/meta
fi

# Write the manifest & copy files
mkdir $fulldir
echo -n 'files = { ' >> ${manifest}
for f in ${files[*]}
do
	# Manifest editing
	echo -n "\"$f\"" >> $manifest
	if [[ $f = ${files[${#files[@]}-1]} ]]
	then
		echo " }" >> $manifest
	else
		echo -n ", " >> $manifest
	fi

	# Copy the file
	cp $f $fulldir
done
