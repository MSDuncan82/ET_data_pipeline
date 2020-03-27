#!/bin/bash
############################################################################
#
# Usage: process_raw_data.sh
#
# Process xlsx files to concatenated csv files to be run through 
# update_db.sh.
#
# Options (Required):
#  -f|--data [ 'path to data folder']
#
############################################################################

## Flags

## Functions
show_help () {
        echo "Usage:"
        echo "  ./process_raw_data.sh" 
        echo "      -f|--data [ 'path to data folder']" 
}

## Argument handling
while [ -n "$1" ]; do

	case "$1" in

    -f | --data)
        DATA_PATH=$2
        shift
        ;;

    -h | --help)
        show_help
        exit 0
        ;;

	*)  
        echo "Did not recognize $1"
        echo ""
        show_help
        exit -1
        ;;

	esac

	shift

done

# Find raw data folders and run xlsx_to_csv.sh and csv_concat.sh
_data_directories=$DATA_PATH/*/

for _data_directory in $_data_directories; do

    echo "Processing: $_data_directory"
    
    if [[ ! -d "${_data_directory}/raw" ]]; then
        continue
    fi

    _raw_data_directory="${_data_directory}raw"
    
    # Check if there are xlsx files in raw data folder and convert them to csv files
    _xlsx_files_in_directory=($_raw_data_directory/*.xlsx)
    if [[ ! "$_xlsx_files_in_directory" == *"*"* ]]; then

        echo "Converting .xlsx -> .csv"
        ./xlsx_to_csv.sh -f $_raw_data_directory >/dev/null 2>&1
    fi

    # Check if there are csv files in raw data folder and concatenate them to a processed directory
    _csv_files_in_directory=($_raw_data_directory/*.csv)
    if [[ ! "$_csv_files_in_directory" == *"*"* ]]; then

        echo "Concatenating csv files -> ${_data_directory}processed"

        rm -rf ${_data_directory}processed

        _suffix=$(basename ${_data_directory})
        ./csv_concat.sh -f $_raw_data_directory -o "${_data_directory}processed" -s $_suffix

    else
        echo "Skipping. No .xlsx or .csv files in this directory"
    fi

done


