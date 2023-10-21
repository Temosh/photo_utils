#!/bin/bash

usage() {
	echo "photo_prepare {src}"
	echo ""
	echo "src - directory in which subdirectories should be cleared"
}

clear_dirs() {
	if [ "$1" = "$src" ]; then
		local path="$1/*/"
	else
		local path="$1/*"
	fi

	for file in $path; do
		if [ -d ${file} ]; then
			local dir=${file%/}
			echo checking directory $dir...
			clear_dirs $dir
			echo removing directory $dir...
			rmdir  $dir
		else if [ -f ${file} ]; then
			echo moving $file...
			mv "$file" $src
		fi
		fi
	done
}

if [  $# -ne 1 ]
then 
	usage
	exit 1
fi 

src=$1

basedir=`pwd`
if [[ "$src" != /* ]]; then src="$basedir/$src"; fi
src=${src%/}

IFS_ORIGIN=$IFS
IFS=$(echo -en "\n\b")
clear_dirs $src
IFS=$IFS_ORIGIN
