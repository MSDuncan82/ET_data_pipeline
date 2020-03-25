/* set variables */
\set CHECKINS _checkins
\set TABLE_NAME :PREFIX:CHECKINS

/* add in cust table info*/
BEGIN;

    CREATE TABLE :TABLE_NAME (
                    id INT,
                    customer_id VARCHAR,
                    responsible_party_id VARCHAR,
                    customer_type VARCHAR,
                    address_1 VARCHAR,
                    address_2 VARCHAR,
                    city VARCHAR,
                    state VARCHAR,
                    zip VARCHAR,
                    belay VARCHAR,
                    first_contact_date VARCHAR,
                    pay_form VARCHAR,
                    status VARCHAR,
                    eft_dues FLOAT,
                    birthday TIMESTAMPTZ,
                    facility_access VARCHAR,
                    guid VARCHAR
                    );

    /* copy csv file into TABLE_NAME */
    COPY :TABLE_NAME(id,
                    customer_id,
                    responsible_party_id,
                    customer_type,
                    address_1,
                    address_2,
                    city,
                    state,
                    zip,
                    belay,
                    first_contact_date,
                    pay_form,
                    status,
                    eft_dues,
                    birthday,
                    facility_access,
                    guid)
    FROM :CSV_PATH DELIMITER ',' CSV HEADER;

    /* delete duplicates */
    DELETE
        FROM
            :TABLE_NAME a
        USING 
            :TABLE_NAME b
        WHERE
            a.id < b.id
            AND a.guid = b.guid;

COMMIT;