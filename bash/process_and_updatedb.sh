#!/bin/bash
############################################################################
#
# Usage: process_and_updatedb.sh
#
# For Denver: ./process_and_updatedb.sh -d el_cap -f /home/michael/cavalier/projects/el_cap/data_climb -g 'gol eng'
#
# Runs process_raw_data.sh && update_db.sh to:
#   Process all raw .xlsx files to prepare data 
#   for update_db.sh. Then run update_db.sh with that data
#
# Options:
#  -d|--db [ database name ] (Required)
#  -f|--data [ path to data directory ] (Required)
#  -g|--gyms [ 'gym_1 gym_2 ... gym_n' ] gym names should be 3 letter lowercase strings ex: 'gol eng' (Required)
#  -u|--user [ user to log in to psql ] (default='michael')
#
############################################################################

## Flags

## Functions
show_help () {
        echo "Usage:"
        echo "  ./process_and_updatedb.sh" 
        echo "      -d|--db [ psql database name ]" 
        echo "      -f|--data [ path to data directory ]" 
        echo "      -g|--gyms [ 'gym_1 gym_2 ... gym_n' ] gym names should be 3 letter lowercase strings. Examples: 'gol eng'"
        echo "      -u|--user [ user to log in to psql ] (default='michael')"
}

# Default Values
USER=michael
DB=el_cap

## Argument handling
while [ -n "$1" ]; do

	case "$1" in

	-d | --db) 
        DB=$2 
        shift
        ;;

    -f | --data)
        DATA_PATH=$2
        shift
        ;;
    
    -g | --gyms)
        GYMS=$2
        shift
        ;;

    -u | --user)
        USER=$2
        shift
        ;;

    -h | --help)
        show_help
        exit 0
        ;;

	*)  
        echo "Did not recognize ${$1}"
        echo ""
        show_help
        exit -1
        ;;

	esac

	shift

done

./process_raw_data.sh -f $DATA_PATH &&
./update_db.sh -d $DB -f $DATA_PATH -g $GYMS -u $USER
