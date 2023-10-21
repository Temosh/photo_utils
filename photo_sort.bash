#!/usr/bin/env bash

readonly DEFAULT_JPEG_FOLDER_NAME="Jpeg Native"

readonly BLACK='\033[0;30m'
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[0;37m'
readonly NC='\033[0m' # No Color

usage() {
	echo "photo_sort <path> [jpeg_folder_name]"
	echo ""
	echo "path  - folder with sorted RAW photos and unsorted JPEG"
	echo "jpeg_folder_name - name of folder with JPEG photos. Default value: 'Jpeg Native'"
	echo ""
	echo "Note: photos in folder 'Trash' to be deleted manually"
}

find_and_sort_dirs() {
	local dir="$1"

	for subdir in $dir/*/; do
		if [ -d ${subdir} ]; then
			local subdir_name
			subdir_name="$(basename "${subdir}")"
			find_and_sort_dirs "${dir}/${subdir_name}"
		fi
	done

	if [[ -d "${dir}/${jpeg_folder}" ]]; then
		sort_dir "${dir}"
	fi
}

sort_dir() {
	local dir="$1"
	
	echo "Sorting directory ${dir}..."

	local jpeg_dir
	jpeg_dir="${dir}/${jpeg_folder}"
	sort_files "${dir}" "${jpeg_dir}"

	echo -e "${GREEN}Sorted directory ${dir}${NC}"
}

sort_files() {
	local dir="$1"
	local jpeg_dir="$2"

	for subdir in $dir/*/; do
		if [ -d ${subdir} ]; then
			local subdir_name
			subdir_name="$(basename "${subdir}")"

			if [[ "${subdir_name}" = "${jpeg_folder}" ]]; then
				continue
			fi

			if [[ -d "${dir}/${subdir_name}/${jpeg_folder}" ]]; then
				continue
			fi

			sort_files "${dir}/${subdir_name}" "${jpeg_dir}"
		fi
	done

	local jpeg_parent_dir
	jpeg_parent_dir="${jpeg_dir%/${jpeg_folder}}"
	local dest_dir_path
	dest_dir_path="${jpeg_dir}${dir#${jpeg_parent_dir}}"

	for file_raw_path in $dir/*; do
		local file_raw
		local extension
		
		file_raw=$(basename "$file_raw_path")
		extension="${file_raw##*.}"

		if [[ ! "${extension,,}" =~ (cr2|cr3) ]]; then
			continue
		fi

		local file_name
		local file_jpeg_path
		file_name="${file_raw%.*}"
		file_jpeg_path="${jpeg_dir}/${file_name}.jpg"

		if [ -f ${file_jpeg_path} ]; then
			if [ ! -d "${dest_dir_path}" ]; then
				echo "Creating ${dest_dir_path}..."
				mkdir -p "${dest_dir_path}"
			fi

			local file_jpeg_new_path="${dest_dir_path}/${file_name}.jpg"

			if [[ "${file_jpeg_path}" = "${file_jpeg_new_path}" ]]; then
				echo -e "${BLACK}Skip ${file_jpeg_path}${NC}"
			else
				echo -e "${BLACK}Moving ${file_jpeg_path} to ${dest_dir_path}${NC}"
				mv "${file_jpeg_path}" "${file_jpeg_new_path}"
			fi
		else
			echo -e "${RED}JPEG file not found: ${file_jpeg_path}${NC}"
		fi
	done
}

if [[ $# < 1 || $# > 2 ]] 
then 
	usage
	exit 1
fi 

dir="$(realpath $1)"
dir="${dir%/}"
jpeg_folder="${2:-${DEFAULT_JPEG_FOLDER_NAME}}"

if [[ ! -d "${dir}" ]]; then echo "Directory ${dir} does not exist"; exit 2; fi
if [[ -z "${jpeg_folder}" ]]; then echo "Invalid JPEG folder name"; exit 3; fi

# Setting Internal Field Separator to split on new lines
IFS_ORIGIN=$IFS
IFS=$(echo -en "\n\b")

find_and_sort_dirs "${dir}"

# Restoring Internal Field Separator
IFS=$IFS_ORIGIN
