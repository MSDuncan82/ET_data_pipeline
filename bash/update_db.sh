#!/bin/bash
############################################################################
#
# Usage: update_db.sh
#
# Delete the current database and recreate it with data from DATA_PATH.
# Data is cleaned with PSQL scripts.
#
# Options (Required):
#  -d|--db [ database name ] 
#  -f|--data [ path to data directory ] 
#  -g|--gyms [ 'gym_1 gym_2 ... gym_n' ] gym names should be 3 letter lowercase strings ex: 'gol eng'
#  -u|--user [ user to log in to psql ] (default='michael')
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
        echo "      -d|--db [ psql database name ]" 
        echo "      -f|--data [ path to data directory ]" 
        echo "      -g|--gyms [ 'gym_1,gym_2,...,gym_n' ] gym names should be 3 letter lowercase strings. Examples: 'gol,eng'"
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
        toggle_leading_slash $2 't'
        DATA_PATH=$NEW_PATH
        shift
        ;;
    
    -g | --gyms)
        PARAMS=$2
        SAVEIFS=$IFS
        IFS=','
        GYMS=($PARAMS)
        IFS=$SAVEIFS
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
        echo "Did not recognize ${1}"
        echo ""
        show_help
        exit -1
        ;;

	esac

	shift

done

## Database Creation

# Create Database if it does not exist
echo "Creating database ${DB}..."
_check_db_query="SELECT EXISTS(SELECT datname FROM pg_catalog.pg_database WHERE datname = '${DB}');"
_db_exists=(`psql -h /var/run/postgresql/ -tW -U postgres -c "${_check_db_query}"`)

if [[ $_db_exists == 'f' ]]; then
    psql -h /var/run/postgresql/ -a -U postgres -c "CREATE DATABASE ${DB};"
fi

# Import cleaned check-ins into database
echo "Importing check-in data..."
CHECK_SQL_PATH='../sql/checkins_csv.sql'
for gym in ${GYMS[@]}; do
    echo "GYM: ${gym}"
    CHECK_CSV_PATH="'${DATA_PATH}/checkins/processed/${gym}_checkins.csv'"
    PREFIX="${gym}"
    ./run_sql.sh "--db" "${DB}" "--csv" "${CHECK_CSV_PATH}" "--sql" "${CHECK_SQL_PATH}" "--prefix" "${PREFIX} -U ${USER}"

done

# Aggregate check-ins to hourly counts
echo "Aggregating check-in data into count tables..."
COUNTS_SQL_PATH='../sql/counts.sql'
for gym in ${GYMS[@]}; do
    echo "GYM: ${gym}"
    ./run_sql.sh "--db" "${DB}" "--sql" "${COUNTS_SQL_PATH}" "--prefix" "${gym} -U ${USER}"

done

# Remove check-ins when the gym was closed using counts table. check-ins at close are possibly tests or employees.
echo "Cleaning up check-in tables..."
CLEAN_CHECKS_SQL_PATH='../sql/remove_closed_checkins.sql'
for gym in ${GYMS[@]}; do
    echo "GYM: ${gym}"
    ./run_sql.sh "--db" "${DB}" "--sql" "${CLEAN_CHECKS_SQL_PATH}" "--prefix" "${gym} -U ${USER}"

done

# Import customer tables into database
echo "Importing customer data..."
CUST_SQL_PATH='../sql/customers_csv.sql'
for gym in ${GYMS[@]}; do
    echo "GYM: ${gym}"
    CUST_CSV_PATH="'${DATA_PATH}/customers/processed/${gym}_customers.csv'"
    ./run_sql.sh "--csv" "${CUST_CSV_PATH}" "--db" "${DB}" "--sql" "${CUST_SQL_PATH}" "--prefix" "${gym} -U ${USER}"

done

# Import weather
echo "Importing weather data..."
PREFIX="nrl"
WEATHER_SQL_PATH='../sql/weather_csv.sql'
WEATHER_CSV_PATH="'${DATA_PATH}/weather/processed/${PREFIX}_weather.csv'"

./run_sql.sh "--csv" "${WEATHER_CSV_PATH}" "--db" "${DB}" "--sql" "${WEATHER_SQL_PATH}" "--prefix" "${PREFIX} -U ${USER}"
