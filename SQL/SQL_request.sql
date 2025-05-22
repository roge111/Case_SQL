-- Задание 1

select pd.name_store, od.nomenclature, od.date, od.price * od.quantity_product as revenue 
from 
    orders_directory as od 
    join 
        product_directory as pd 
    on 
        pd.nomenclature = od.nomenclature
    where
        pd.name_store = 'Магазин 1'
order by od.date DESC;

-- Задание 2

select * from print_directory 
where print not in (
    select print from product_directory where print is not null
);

-- Задание 3

select prod_dir.nomenclature, pd.print, pd.name_print_1, pd.name_print_2 
from
    print_directory as pd 
join 
    product_directory as prod_dir 
on 
    pd.print = prod_dir.print 
where 
    pd.name_print_1 is not null and pd.name_print_2 is not null;

-- Задание 4
select pd.name_store, pd.nomenclature, sd.warehouse as name_house, sd.value_stocks 
from
    product_directory as pd 

join
    stocks_directory as sd
on
    sd.nomenclature = pd.nomenclature
where
    value_stocks > 0 and value_stocks is not null and sd.date = '2024-10-18' and sd.warehouse = 'Склад 1';

-- Задание 5

select pd.barcode, od.date, count(*) as order_count, sum(quantity_product * price) as revenue, sum(quantity_product * price) * 0.95 as revenue_nalog
from
    orders_directory as od
join
    product_directory as pd
on
    od.nomenclature = pd.nomenclature
where
    pd.barcode = 'Code 1'
group by
    pd.barcode,
    od.date
having 
    count(*) > 0
order by
    od.date

-- Задание 6
WITH print_sales AS (
    SELECT 
        pd.print AS print_article,
        p.name_print_1,
        SUM(od.quantity_product) AS total_sales
    FROM 
        orders_directory od
    JOIN 
        product_directory pd ON od.nomenclature = pd.nomenclature
    JOIN 
        print_directory p ON pd.print = p.print
    GROUP BY 
        pd.print, p.name_print_1
)
SELECT 
    print_article,
    name_print_1,
    total_sales
FROM 
    print_sales
ORDER BY 
    total_sales DESC
LIMIT 1;

-- Задание 7
CREATE OR REPLACE FUNCTION log_ddl_actions()
RETURNS event_trigger
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO ddl_log (event_type, object_type, object_name, user_name, ddl_time)
    VALUES (
        tg_event,
        tg_tag,
        (SELECT object_identity FROM pg_event_trigger_ddl_commands() LIMIT 1),
        current_user,
        current_timestamp
    );
END;

CREATE TABLE IF NOT EXISTS ddl_log (

    id SERIAL PRIMARY KEY,
    event_type TEXT,
    object_type TEXT,
    object_name TEXT,
    user_name TEXT,
    ddl_time TIMESTAMP

);

re

--  Задание 8

CREATE TABLE product_directory_audit IF NOT EXISTS (
    id SERIAL PRIMARY KEY,
    operation CHAR(1),
    user_name TEXT,
    change_time TIMESTAMP,
    old_data JSONB,
    new_data JSONB
);

CREATE OR REPLACE FUNCTION log_product_changes()

RETURNS TRIGGER
LANGUAGE plpgsql AS $$

BEGIN
    IF TG_OP = 'UPDATE' THEN

    INSERT INTO product_directory_audi  (
        operation,
        user_name,
        change_time,
        old_data,
        new_data
    )

    VALUES (
        'U',
        current_user,
        current_timestamp,
        to_jsonb(OLD),
        to_jsonb(NEW)
    );
    END IF;
    RETURN NEW;

END;

CREATE TRIGGER product_directory_audit_trigger
AFTER UPDATE ON product_directory
FOR EACH ROW EXECUTE FUNCTION log_product_changes();

-- Задание 9

CREATE DATABASE company_db;
\c company_db

CREATE SCHEMA business;

CREATE USER admin_user PASSWORD 'admin_password';
GRANT ALL ON SCHEMA business TO admin_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA business TO admin_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA business TO admin_user;

CREATE USER read_user WITH PASSWORD 'read_password';
GRANT USAGE ON SCHEMA business to read_user;
GRANT SELECT ON ALL TABLES IN SCHEMA business TO read_user;

SET ROLE admin_user;
CREATE TABLE business. test_table (id SERIAL);
DROP TABLE business. test_table;
RESET ROLE;

SET ROLE read_user;
SELECT * FROM business.any_table;
RESET ROLE;
