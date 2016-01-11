#!/bin/bash

usage() {
	echo "photo_sort {src} {dest}"
	echo ""
	echo "src  - sorted folder with JPEG photos"
	echo "dest - folder to sort"
	echo ""
	echo "Note: photos in folder 'Trash' will be deleted"
}

sort_dirs() {
	for dir in $src/$1/*/; do
		if [ -d ${dir} ]; then
			dirname=`basename "$dir"`

			echo creating $1/$dirname...
			mkdir "$dest/$1/$dirname"
			
			sort_dirs $1/$dirname
		fi
	done
	
	sort_files $1
}

sort_files() {
	for fileJpeg in $src/$1/*; do
		filename=$(basename "$fileJpeg")
		extension="${filename##*.}"
		file="${filename%.*}"

		fileRaw=$dest/$file.cr2

		if [ -e $fileRaw ]; then
			echo moving $fileRaw to $1
			mv $fileRaw $dest/$1/$file.cr2
		fi
	done
}

if [  $# -ne 2 ] 
then 
	usage
	exit 1
fi 

src=$1
dest=$2

basedir=`pwd`
if [[ "$src" != /* ]]; then src="$basedir/$src"; fi
if [[ "$dest" != /* ]]; then dest="$basedir/$dest"; fi
src=${src%/}
dest=${dest%/}

IFS_ORIGIN=$IFS
IFS=$(echo -en "\n\b")

for dir in $src/*/; do
	dirname=`basename "$dir"`

	echo creating $dirname...
	mkdir $dest/$dirname

	sort_dirs $dirname
done

IFS=$IFS_ORIGIN
