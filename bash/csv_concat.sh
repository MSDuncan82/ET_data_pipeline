#!/bin/bash
############################################################################
#
# Usage: csv_concat.sh
#
# Concatenate csv files with the same 3 letter prefix
#
# Options (Required):
#  -f|--csv [ path to raw csv directory ]
#  -o|--out [ path to output directory ]
#  -s|--suffix [ suffix ]: string to attach to ouput files
#                          Example: out file nrl_[ suffix ].csv
#
############################################################################

## Flags

## Functions
show_help () {
        echo "Usage:"
        echo "  ./csv_concat.sh" 
        echo "      -f|--csv [ path to raw csv directory ]"
        echo "      -o|--out [ path to output directory ]"
        echo "      -s|--suffix [ suffix ]: string to attach to ouput files" 
        echo "                              Example: out file nrl_[ suffix ].csv"
}

## Argument handling
while [ -n "$1" ]; do

	case "$1" in

    -f | --csv)
        CSV_DIR=$2
        shift
        ;;

    -o | --out)
        OUT_DIR=$2
        shift
        ;;

    -s | --suffix)
        SUFFIX=$2
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

# Reset IFS to iterate through files
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

# Get csv files
_csv_files=$CSV_DIR/*.csv

# Iterate through files and concat files with same prefix (3 letters)
for _csv_file in $_csv_files; do

    IFS='/'
    _filepath_array=($_csv_file)
    unset IFS

    _prefix=`echo ${_filepath_array[-1]} | cut -c1-3`
    _out_filename=${_prefix,,}_${SUFFIX}.csv

    if [ ! -d $OUT_DIR ]; then
        mkdir $OUT_DIR
    fi

    if [ ! -f "${OUT_DIR}/${_out_filename}" ]; then
        head -n 1 "${_csv_file}" | cat >> $OUT_DIR/$_out_filename
    fi

    tail -n +2 "${_csv_file}" | cat >> $OUT_DIR/$_out_filename
done

# restore $IFSs
IFS=$SAVEIFS