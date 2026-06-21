CREATE SCHEMA IF NOT EXISTS staging;

DROP TABLE IF EXISTS staging.airports;
CREATE TABLE staging.airports (
	airport_code bpchar(3) NOT NULL,
	airport_name text NOT NULL,
	city text NOT NULL,
	coordinates point NOT NULL,
	timezone text NOT NULL
);

DROP TABLE IF EXISTS staging.aircrafts;
CREATE TABLE staging.aircrafts (
	aircraft_code bpchar(3) NOT NULL,
	model text NOT NULL
);

DROP TABLE IF EXISTS staging.seats;
CREATE TABLE staging.seats (
	aircraft_code bpchar(3) NOT NULL,
	seat_no varchar(4) NOT NULL,
	fare_conditions varchar(10) NOT NULL
);

DROP TABLE IF EXISTS staging.flights;
CREATE TABLE staging.flights (
	flight_id serial4 NOT NULL,
	flight_no bpchar(6) NOT NULL,
	scheduled_departure timestamptz NOT NULL,
	scheduled_arrival timestamptz NOT NULL,
	departure_airport bpchar(3) NOT NULL,
	arrival_airport bpchar(3) NOT NULL,
	status varchar(20) NOT NULL,
	aircraft_code bpchar(3) NOT NULL,
	actual_departure timestamptz null,
	actual_arrival  timestamptz null
);

DROP TABLE IF EXISTS staging.ticket_flights;
CREATE TABLE staging.ticket_flights (
	ticket_no bpchar(13) NOT NULL,
	flight_id int4 NOT NULL,
	fare_conditions varchar(10) NOT NULL,
	amount numeric(10, 2)
);

DROP TABLE IF EXISTS staging.boarding_passes;
CREATE TABLE staging.boarding_passes (
	ticket_no bpchar(13) NOT NULL,
	flight_id int4 NOT NULL,
	boarding_no int4 NOT NULL,
	seat_no varchar(4) NOT NULL
);

drop table if exists staging.last_update;
create table staging.last_update (
	table_name varchar(50) not null,
	update_dt timestamp not null
);

create or replace procedure staging.set_table_load_time(table_name varchar, current_update_dt timestamp default now())
as $$
	begin
		INSERT INTO staging.last_update
		(
			table_name, 
			update_dt
		)
		VALUES(
			table_name, 
			current_update_dt
		);
	end;
$$ language plpgsql;

create or replace procedure staging.airports_load(current_update_dt timestamp)
 as $$
 	begin
		delete from staging.airports;
	
		insert into staging.airports
		(
			airport_code,
			airport_name,
			city,
			coordinates,
			timezone
		)
		select
			airport_code,
			airport_name,
			city,
			coordinates,
			timezone
		from
			demo_src.airports;
		
		call staging.set_table_load_time('staging.airports', current_update_dt);
	end;
$$ language plpgsql;

create or replace procedure staging.aircrafts_load(current_update_dt timestamp)
 as $$
 	begin
		delete from staging.aircrafts;
	
		insert into staging.aircrafts
		(
			aircraft_code, 
			model
		)
		select
			aircraft_code, 
			model
		from
			demo_src.aircrafts;
		
		call staging.set_table_load_time('staging.aircrafts', current_update_dt);
	end;
$$ language plpgsql;

create or replace procedure staging.seats_load(current_update_dt timestamp)
 as $$
 	begin
		delete from staging.seats;
	
		insert into staging.seats
		(
			aircraft_code, 
			seat_no, 
			fare_conditions
		)
		SELECT 
			aircraft_code, 
			seat_no, 
			fare_conditions
		FROM 
			demo_src.seats;
		
		call staging.set_table_load_time('staging.seats', current_update_dt);
	end;
$$ language plpgsql;

create or replace procedure staging.flights_load(current_update_dt timestamp)
 as $$
 	begin
		delete from staging.flights;
	
		insert into staging.flights
		(
			flight_id,
			flight_no,
			scheduled_departure,
			scheduled_arrival,
			departure_airport,
			arrival_airport,
			status,
			aircraft_code,
			actual_departure,
			actual_arrival
		)
		select
			flight_id,
			flight_no,
			scheduled_departure,
			scheduled_arrival,
			departure_airport,
			arrival_airport,
			status,
			aircraft_code,
			actual_departure,
			actual_arrival
		from
			demo_src.flights;
		
		call staging.set_table_load_time('staging.flights', current_update_dt);
	end;
$$ language plpgsql;

create or replace procedure staging.ticket_flights_load(current_update_dt timestamp)
 as $$
 	begin
		delete from staging.ticket_flights;
	
		insert into staging.ticket_flights
		(
			ticket_no, 
			flight_id, 
			fare_conditions
		)
		select
			ticket_no, 
			flight_id, 
			fare_conditions
		from
			demo_src.ticket_flights;
		
		call staging.set_table_load_time('staging.ticket_flights', current_update_dt);
	end;
$$ language plpgsql;

create or replace procedure staging.boarding_passes_load(current_update_dt timestamp)
 as $$
 	begin
		delete from staging.boarding_passes;
	
		insert into staging.boarding_passes
		(
			ticket_no, 
			flight_id, 
			boarding_no, 
			seat_no
		)
		select
			ticket_no, 
			flight_id, 
			boarding_no, 
			seat_no
		from
			demo_src.boarding_passes;
		
		call staging.set_table_load_time('staging.boarding_passes', current_update_dt);
	end;
$$ language plpgsql;

-- полная загрузка данных

create or replace procedure full_load()
as $$
	declare
		current_update_dt timestamp = now();
	begin
		call staging.airports_load(current_update_dt);
		call staging.aircrafts_load(current_update_dt);
		call staging.seats_load(current_update_dt);
		call staging.flights_load(current_update_dt);
		call staging.ticket_flights_load(current_update_dt);
		call staging.boarding_passes_load(current_update_dt);
	end;
$$ language plpgsql;

call full_load();