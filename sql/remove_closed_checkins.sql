/* set variables */
\set COUNTS _counts
\set CHECKINS _checkins
\set COUNTS_TABLE :PREFIX:COUNTS
\set CHECKS_TABLE :PREFIX:CHECKINS

BEGIN;

/* create new checkins table */
CREATE TABLE new_:CHECKS_TABLE (
                    id SERIAL PRIMARY KEY,
                    datetime TIMESTAMPTZ,
                    facility_name VARCHAR,
                    customer_key VARCHAR,
                    guid VARCHAR,
                    age_at_checkin INT,
                    checkin_type VARCHAR,
                    checkin_status VARCHAR,
                    home_gym VARCHAR
                    );

INSERT INTO new_:CHECKS_TABLE (
                        id,
                        datetime,
                        facility_name,
                        customer_key,
                        guid,
                        age_at_checkin,
                        checkin_type,
                        checkin_status,
                        home_gym)
                    SELECT
                        ch.id,
                        ch.datetime,
                        ch.facility_name,
                        ch.customer_key,
                        ch.guid,
                        ch.age_at_checkin,
                        ch.checkin_type,
                        ch.checkin_status,
                        ch.home_gym
                    FROM
                        :CHECKS_TABLE ch
                    INNER JOIN
                        :COUNTS_TABLE co
                    ON
                        ch.datetime = co.datetime
                    ORDER BY
                        datetime;

/* drop original table */
DROP TABLE :CHECKS_TABLE;

/* rename new table */
ALTER TABLE new_:CHECKS_TABLE 
RENAME TO :CHECKS_TABLE;

COMMIT;