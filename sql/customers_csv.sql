/* set variables */
\set SUFFIX _customers
\set TABLE_NAME :PREFIX:SUFFIX

/* add in cust table info*/
BEGIN;
    
    DROP TABLE IF EXISTS public.:TABLE_NAME;

    CREATE TABLE :TABLE_NAME (id SERIAL,
                    customer_id VARCHAR,
                    firstname VARCHAR,
                    lastname VARCHAR,
                    middlename VARCHAR,
                    customer_type VARCHAR,
                    barcode VARCHAR,
                    responsible_party_id VARCHAR,
                    address1 VARCHAR,
                    address2 VARCHAR,
                    bank_account VARCHAR,
                    bank_name VARCHAR,
                    bank_route VARCHAR,
                    bank_accounttype VARCHAR,
                    cell_phone VARCHAR,
                    city VARCHAR,
                    credit_card VARCHAR,
                    credit_card_exp TIMESTAMP,
                    facility_waiver INT,
                    belay_certified VARCHAR,
                    email VARCHAR,
                    alt_online_acct_email VARCHAR,
                    emergency_contact VARCHAR,
                    emergency_phone VARCHAR,
                    membership_exp_date TIMESTAMP,
                    membership_start_date TIMESTAMP,
                    first_contact_date TIMESTAMP,
                    membership_form_of_payment VARCHAR,
                    home_phone VARCHAR,
                    last_billed_date TIMESTAMP,
                    last_record_edit TIMESTAMP,
                    state VARCHAR,
                    work_phone VARCHAR,
                    zip VARCHAR,
                    current_status VARCHAR,
                    eft_dues_amount FLOAT,
                    last_visit_date TIMESTAMP,
                    next_bill_date TIMESTAMP,
                    staff_password VARCHAR,
                    staff_access_level VARCHAR,
                    staff_is_inactive INT,
                    staff_aphelion_name VARCHAR,
                    staff_manager_reporting_facility_list VARCHAR,
                    bday TIMESTAMP,
                    is_billable INT,
                    early_in_member INT,
                    facility_waiver_date TIMESTAMP,
                    policy1_date TIMESTAMP,
                    policy2_date TIMESTAMP,
                    policy3_date TIMESTAMP,
                    policy4_date TIMESTAMP,
                    policy5_date TIMESTAMP,
                    policy6_date TIMESTAMP,
                    policy7_date TIMESTAMP,
                    punch_customer_id VARCHAR,
                    punch_card_type VARCHAR,
                    eft_contract_end_date TIMESTAMP,
                    exclude_from_billing INT,
                    extra_product_id_list VARCHAR,
                    extra_dues_amount_list VARCHAR,
                    country VARCHAR,
                    bouldering_only INT,
                    gear_included VARCHAR,
                    import_set VARCHAR,
                    membership_cannot_be_frozen INT,
                    member_nocheckin_justbill INT,
                    customer_custom_type VARCHAR,
                    facility_id VARCHAR,
                    facility_access_type VARCHAR,
                    xw_alias_xwebid VARCHAR,
                    xw_alias VARCHAR,
                    xw_masked_cc VARCHAR,
                    xw_cardtype VARCHAR,
                    manual_billing INT,
                    rental_gear_until TIMESTAMP,
                    guid VARCHAR,
                    archived INT,
                    gender VARCHAR,
                    dues_change_date TIMESTAMP,
                    dues_change_amount FLOAT,
                    dues_change_tempmonths INT,
                    do_not_mail INT,
                    custom_text1 VARCHAR,
                    custom_text2 VARCHAR,
                    spending_limit FLOAT,
                    wants_monthly_billing_email INT,
                    alt_freeze_fee INT,
                    facility_access_additional_gyms VARCHAR,
                    online_portal_user_id VARCHAR,
                    no_checkin_priorto_date TIMESTAMP,
                    home_location_tag VARCHAR);

    /* copy csv file into TABLE_NAME */
    COPY :TABLE_NAME(customer_id,
                    firstname, 
                    lastname,
                    middlename,
                    customer_type,
                    barcode,
                    responsible_party_id,
                    address1,
                    address2,
                    bank_account,
                    bank_name,
                    bank_route,
                    bank_accounttype,
                    cell_phone,
                    city,
                    credit_card,
                    credit_card_exp,
                    facility_waiver,
                    belay_certified,
                    email,
                    alt_online_acct_email,
                    emergency_contact,
                    emergency_phone,
                    membership_exp_date,
                    membership_start_date,
                    first_contact_date,
                    membership_form_of_payment,
                    home_phone,
                    last_billed_date,
                    last_record_edit,
                    state,
                    work_phone,
                    zip,
                    current_status,
                    eft_dues_amount,
                    last_visit_date,
                    next_bill_date,
                    staff_password,
                    staff_access_level,
                    staff_is_inactive,
                    staff_aphelion_name,
                    staff_manager_reporting_facility_list,
                    bday,
                    is_billable,
                    early_in_member,
                    facility_waiver_date,
                    policy1_date,
                    policy2_date,
                    policy3_date,
                    policy4_date,
                    policy5_date,
                    policy6_date,
                    policy7_date,
                    punch_customer_id,
                    punch_card_type,
                    eft_contract_end_date,
                    exclude_from_billing,
                    extra_product_id_list,
                    extra_dues_amount_list,
                    country,
                    bouldering_only,
                    gear_included,
                    import_set,
                    membership_cannot_be_frozen,
                    member_nocheckin_justbill,
                    customer_custom_type,
                    facility_id,
                    facility_access_type,
                    xw_alias_xwebid,
                    xw_alias,
                    xw_masked_cc,
                    xw_cardtype,
                    manual_billing,
                    rental_gear_until,
                    guid,
                    archived,
                    gender,
                    dues_change_date,
                    dues_change_amount,
                    dues_change_tempmonths,
                    do_not_mail,
                    custom_text1,
                    custom_text2,
                    spending_limit,
                    wants_monthly_billing_email,
                    alt_freeze_fee,
                    facility_access_additional_gyms,
                    online_portal_user_id,
                    no_checkin_priorto_date,
                    home_location_tag
                    )
    FROM :CSV_PATH DELIMITER ',' CSV HEADER ENCODING 'latin1';

    /* delete duplicates */
    /*
    DELETE
        FROM
            :TABLE_NAME a
        USING 
            :TABLE_NAME b
        WHERE
            a.id < b.id
            AND a.guid = b.guid; */

COMMIT;
