#!/bin/bash
############################################################################
#
# Usage: run_sql.sh
#
# Run a psql script with a given sql script
#
# Options:
#  -d|--db [ psql database name ] 
#  -s|--sql [ path to sql file ] 
#  -p|--prefix [ gym prefix ]: ex: 'gol'
#  -c|--csv [ path to csv file ]
#  -u|--user(default=michael) [ user to log in to psql ]
#
# Limitations: 
#  Required options: --sql [ path to sql file ] 
#
############################################################################

# Functions
show_help () {
        echo "Usage:"
        echo "  ./run_sql.sh" 
        echo "      --db [ psql database name ]" 
        echo "      --csv [ path to csv file ]" 
        echo "      --sql [ path to sql file ]" 
        echo "      --prefix [ gym prefix ]: Example: 'gol'"
        echo "      --user(default=michael) [ user to log in to psql ]"
}

# Flags

# Default Values
USER=mike
DB=el_cap

# Argument Handling
while [ -n "$1" ]; do
	case "$1" in

    -d | --db) 
        DB=$2 
        shift
        ;;

	-s | --sql)
        SQL_PATH=$2 
        shift
        ;;

    -c | --csv)
        CSV_PATH=$2
        shift
        ;;
    
    -u | --user)
        USER=$2
        shift
        ;;

    -p | --prefix)
        PREFIX=$2
        shift
        ;;

    -h | --help)
        show_help

        exit 0
        ;;

	*)  echo "Did not recognize $1"
        echo ""
        show_help

        exit -1
        ;;

	esac
	shift
done

psql -d $DB -U $USER \
    -f $SQL_PATH \
    --set AUTOCOMMIT=off \
    --set ON_ERROR_STOP=on \
    --set CSV_PATH=${CSV_PATH} \
    --set PREFIX=$PREFIX

exit 0
