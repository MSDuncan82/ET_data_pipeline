#!/bin/bash
############################################################################
#
# Usage: xlsx_to_csv.sh
#
# Convert xlsx files to csv files
#
# Options:
#  -f|--xlsx [ path to raw xlsx directory ] (Required)
#  -o|--out [ path to output directory ]
#
############################################################################

## Flags

## Functions
show_help () {
        echo "Usage:"
        echo "  ./xlsx_to_csv.sh" 
        echo "      -f|--xlsx [ path to raw csv directory ]"
        echo "      -o|--out [ path to output directory ]"
}

## Argument handling
while [ -n "$1" ]; do

	case "$1" in

    -f | --xlsx)
        XLSX_DIR=$2

        # Default OUT_DIR to XLSX_DIR
        if [ -z "$OUT_DIR" ]; then
            OUT_DIR=$XLSX_DIR
        fi

        shift
        ;;

    -o | --out)
        OUT_DIR=$2
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

# Get xlsx files
_xlsx_files=$XLSX_DIR/*.xlsx

# Convert xlsx files to csv

for _xlsx_file in $_xlsx_files; do
libreoffice --headless --convert-to csv "${_xlsx_file}" --outdir "${OUT_DIR}"
done

# restore $IFSs
IFS=$SAVEIFS