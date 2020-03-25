#!/bin/bash
############################################################################
#
# Usage: update_db.sh
#
# Delete the current database and recreate it with data from DATA_PATH.
# Data is cleaned with PSQL scripts.
#
# Options (Required):
#  --db [ database name ] 
#  --data [ path to data directory ] 
#  --gyms [ 'gym_1 gym_2 ... gym_n' ] gym names should be 3 letter lowercase strings ex: 'gol eng'
#
# Limitations: 
#  All options are required but can input in any order
#
############################################################################

## Flags

## Functions
toggle_leading_slash () {
    # Usage: 
    #   toggle_leading_slash [ 'path' ] [ 't' or 'f' ]

    # First argument: File or directory path
    local _path=$1
    local _path_firstchar=${_path:0:1}

    # Second argument: Do you want the leading slash? 't' or 'f'
    local _return_lead_slash=$2
    local _return_lead_slash_firstchar=${_return_lead_slash:0:1}

    local _outpath=$_path

    if [ $_return_lead_slash_firstchar == 't' ] && [ $_path_firstchar != '/' ]; then
        _outpath="/${_path}"
    fi

    if [ $_return_lead_slash_firstchar == 'f' ] && [ $_path_firstchar == '/' ]; then
        _outpath="${_path:1}"
    fi

    NEW_PATH=$_outpath
}

show_help () {
        echo "Usage:"
        echo "  ./update_db.sh" 
        echo "      --db [ psql database name ]" 
        echo "      --data [ path to data directory ]" 
        echo "      --gyms [ 'gym_1 gym_2 ... gym_n' ] gym names should be 3 letter lowercase strings. Examples: 'gol eng'"
        echo "      --user(default=michael) [ user to log in to psql ]"
}

## Argument handling
while [ -n "$1" ]; do

	case "$1" in

	-d | --db) 
        DB=$2 
        shift
        ;;

    -f | --data)
        toggle_leading_slash $2 't'
        DATA_PATH=$NEW_PATH
        shift
        ;;
    
    -g | --gyms)
        PARAMS=$2
        GYMS=()

        for param in $PARAMS; do
            if [ ${#param} == 3 ]; then
                GYMS+=($param)
            fi

            shift
        done
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

## Database Creation

# Create Database if it does not exist
_check_db_query="SELECT EXISTS(SELECT datname FROM pg_catalog.pg_database WHERE datname = '${DB}');"
_db_exists=(`psql -tW -U postgres -c "${_check_db_query}"`)

if [ $_db_exists == 'f' ]; then
    psql -a -U postgres -c "CREATE DATABASE ${DB};"
fi

# Import cleaned check-ins into database
CHECK_SQL_PATH='../sql/checkins_csv.sql'
for gym in ${GYMS[@]}; do

    CHECK_CSV_PATH="'${DATA_PATH}/checkins/processed/${gym}_checkins.csv'"
    PREFIX="${gym}"
    ./run_sql.sh "--db" "${DB}" "--csv" "${CHECK_CSV_PATH}" "--sql" "${CHECK_SQL_PATH}" "--prefix" "${PREFIX}"

done

# Aggregate check-ins to hourly counts
COUNTS_SQL_PATH='../sql/counts.sql'
for gym in ${GYMS[@]}; do

    ./run_sql.sh "--db" "${DB}" "--sql" "${COUNTS_SQL_PATH}" "--prefix" "${gym}"

done

# Remove check-ins when the gym was closed using counts table. check-ins at close are possibly tests or employees.
CLEAN_CHECKS_SQL_PATH='../sql/remove_closed_checkins.sql'
for gym in ${GYMS[@]}; do

    ./run_sql.sh "--db" "${DB}" "--sql" "${CLEAN_CHECKS_SQL_PATH}" "--prefix" "${gym}"

done

# Import customer tables into database
CUST_SQL_PATH='../sql/customers.sql'
for gym in ${GYMS[@]}; do

    CUST_CSV_PATH="'${DATA_PATH}/customers/processed/${gym}_customers.csv'"
    ./run_sql.sh "--csv" "${CUST_CSV_PATH}" "--db" "${DB}" "--sql" "${CUST_SQL_PATH}" "--prefix" "${gym}"

done

# Import weather
PREFIX="nrl"
WEATHER_SQL_PATH='../sql/weather_csv.sql'
WEATHER_CSV_PATH="'${DATA_PATH}/weather/processed/${PREFIX}_weather.csv'"

./run_sql.sh "--csv" "${WEATHER_CSV_PATH}" "--db" "${DB}" "--sql" "${WEATHER_SQL_PATH}" "--prefix" "${PREFIX}"
