-- выполняется в БД, к которой подключается dbt (dbt_course или dbt_fligth)

DROP FOREIGN TABLE demo_src.bookings;

CREATE FOREIGN TABLE demo_src.bookings (
	book_ref varchar(8) OPTIONS(column_name 'book_ref') NOT NULL,
	book_date timestamptz OPTIONS(column_name 'book_date') NOT NULL,
	total_amount numeric(10, 2) OPTIONS(column_name 'total_amount') NOT NULL
)
SERVER demo_pg
OPTIONS (schema_name 'bookings', table_name 'bookings');

DROP FOREIGN TABLE demo_src.tickets;

CREATE FOREIGN TABLE demo_src.tickets (
	ticket_no bpchar(13) OPTIONS(column_name 'ticket_no') NOT NULL,
	book_ref varchar(8) OPTIONS(column_name 'book_ref') NOT NULL,
	passenger_id varchar(20) OPTIONS(column_name 'passenger_id') NOT NULL,
	passenger_name text OPTIONS(column_name 'passenger_name') NOT NULL,
	contact_data jsonb OPTIONS(column_name 'contact_data') NULL
)
SERVER demo_pg
OPTIONS (schema_name 'bookings', table_name 'tickets');
