#!/bin/bash
############################################################################
#
# Usage: csv_to_sql.sh
#
# Run a psql script with a given sql script
#
# Options (Required):
#  --db [ psql database name ] 
#  --sql [ path to sql file ] 
#  --prefix [ gym prefix ]: ex: 'gol'
#  --csv [ path to csv file ]
#  --user(default=michael) [ user to log in to psql ]
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
USER=michael
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
        ;;

	*)  echo "Did not recognize ${$1}"
        echo ""
        show_help
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
