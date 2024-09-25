create database "DevDB2024_SERPIS"
	with owner pguser;
	
CREATE SCHEMA "Operations";
CREATE SCHEMA "Cars";
CREATE SCHEMA "Clients";

create table "Operations"."Route"
	(
	route_id serial not null primary key,
	depart varchar(30) not null,
	arrive varchar(30) not null,
	distance int not null,
	trip_time varchar(30) not null check(trip_time ~ '(\d\d?\s(days?)\s)?\b[0-2]?[0-9]:[0-5][0-9]\b'),
	active boolean not null,
	constraint AK_route unique (depart, arrive, distance)
	);

create table "Operations"."Driver"
	(
	driver_id serial not null primary key,
	lastname varchar(30) not null check(lastname != ’’),
	firstname varchar(30) not null check(lastname != ’’),
	patronymic null,
	passport char(12) not null check(passport ~ '(^\d{2}\s\d{2}\s)(\d{6})'),
	birthday,
	date_of_employment,
	drivers_license,
	drivers_license_category,
	date_of_issue_license,
	constraint AK_driver unique (lastname, firstname, passport, birthday)
	);
	
