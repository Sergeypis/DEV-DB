create database "DevDB2024_SERPIS"
	with 
		owner = pguser
		connection limit = -1;
	
CREATE SCHEMA "Operations";
CREATE SCHEMA "Cars";
CREATE SCHEMA "Clients";

create table if not exists "Operations"."Route"
	(
	route_id serial not null primary key,
	depart varchar(30) not null check(depart != ''),
	arrive varchar(30) not null check(arrive != ''),
	distance int not null check(distance > 0),
	trip_time varchar(30) not null check(trip_time ~ '(?:\d\d?\s(?:days?)\s)?\b[0-2]?[0-9]:[0-5][0-9]\b'),
	active boolean not null default 'yes'::boolean,
	constraint AK_route unique (depart, arrive, distance)
	);

create table if not exists "Operations"."Driver"
	(
	driver_id serial not null primary key,
	lastname varchar(30) not null check(lastname != ''),
	firstname varchar(30) not null check(lastname != ''),
	patronymic varchar(30) null,
	passport char(12) not null check(passport ~ '(?:^\d{2}\s\d{2}\s)(?:\d{6})'),
	birthday date not null,
	date_of_employment date not null,
	drivers_license char(12) not null check(drivers_license ~ '(^\d{2}\s\d{2}\s)(\d{6})'),
	drivers_license_category varchar(30) not null check(drivers_license_category ~ '^(?:A|B|C|D|E|M|BE|CE|DE|C1|C1E|D1|D1E|Tm|Tb|A1|B1)(?:\s*,\s*(?:A|B|C|D|E|M|BE|CE|DE|C1|C1E|D1|D1E|Tm|Tb|A1|B1))*$'),
	date_of_issue_license date not null,
	constraint AK_driver unique (lastname, firstname, passport, birthday)
	);

create table if not exists "Cars"."Vehicle_type" 
(
type varchar(30) not null check(type != '') primary key,
max_allowed_speed int null check(max_allowed_speed >= 40 AND max_allowed_speed <= 130) default 70
);
insert into "Cars"."Vehicle_type" values ('not set');

create table if not exists "Cars"."Vehicle"
(
vin varchar(17),
model varchar(30),
number_plate varchar(12),
year_of_manufacture int,
number_of_seats int,
type varchar(30),
fuel_type varchar(30),
resource int,
mileage int,
decommissioned boolean
);
alter table "Cars"."Vehicle"
	--costrant null/not null
	alter column vin set not null, 
	alter column model set not null, 
	alter column number_plate set not null, 
	alter column year_of_manufacture set not null, 
	alter column number_of_seats set not null, 
	alter column resource set not null, 
	alter column mileage set not null,
	alter column type drop not null,
	alter column fuel_type drop not null,
	alter column decommissioned drop not null;
alter table "Cars"."Vehicle"
	--constraint for column "vin"
	add primary key (vin),	
	--constraint for column "number_plate"
	add constraint CH_num_plate check(number_plate ~ '(?:^[АВЕКМНОРСТУХ]\d{3}(?<!000)[АВЕКМНОРСТУХ]{2}\d{2,3}RUS$)|(?:^[АВЕКМНОРСТУХ]{2}\d{3}(?<!000)\d{2,3}RUS$)'),	
	--constraint for column "year_of_manufacture"
	add constraint CH_year_vehicle check(year_of_manufacture > 1900 and year_of_manufacture <= date_part('year', now())::int4),	
	--constraint for column "number_of_seats"
	add constraint CH_num_seats check(number_of_seats >= 0 AND number_of_seats <= 100),	
	--constraint for column "type"
	alter column type set default 'not set'::text,
	add constraint FK_type_vehicle foreign key (type)
		references "Cars"."Vehicle_type"(type)
		on update cascade
		on delete set default,	
	--constraint for column "resource"
	add constraint CH_car_resource check(resource >= 0 AND resource < 20),	
	--constraint for column "mileage"
	add constraint CH_mileage check(mileage >= 0),	
	--constraint for column "decommissioned"
	alter column decommissioned set default 'no'::boolean,	
	--constraint unique
	add constraint AK_vehicle unique (model, number_plate, year_of_manufacture);
alter table "Cars"."Vehicle"
add constraint ch_vin check(vin != '');

create table if not exists "Clients"."Passenger"
	(
	pass_id int generated always as identity (start with 1 increment by 1),
	lastname varchar(30) not null check(lastname != ''),
	firstname varchar(30) not null check(lastname != ''),
	patronymic varchar(30) null,
	passport char(12) not null check(passport ~ '(?:^\d{2}\s\d{2}\s)(?:\d{6})'),
	birthday date not null
	);
alter table "Clients"."Passenger" add primary key (pass_id)
alter table "Clients"."Passenger"
add constraint AK_pass unique (lastname, firstname, passport, birthday);
insert into "Clients"."Passenger"
overriding system value
values (0, 'no_name', 'no_name', null, '00 00 000000', '1234-12-21'::date);

create table if not exists 	"Operations"."Schedule"
	(
	chedule_id int generated always as identity (start with 1 increment by 1) primary key,
	route_id int not null,
	constraint FK_route foreign key (route_id)
		references "Operations"."Route"(route_id)
		on update cascade
		on delete no action,
	vin varchar(17) not null check(vin != ''),
	constraint FK_vehicle foreign key (vin)
		references "Cars"."Vehicle"(vin)
		on update cascade
		on delete no action,
	date_depart date not null,
	time_depart time not null,
	driver_id int null,
	constraint FK_driver foreign key (driver_id)
		references "Operations"."Driver"(driver_id)
		on update cascade
		on delete set null,
	tickets_avaliable int not null check(tickets_avaliable >= 0 AND tickets_avaliable <= 100),
	constraint AK_op_schedule unique (vin, date_depart, time_depart)
	);	
alter table "Operations"."Schedule"
rename column chedule_id to schedule_id;

create table if not exists 	"Clients"."Ticket"
	(
	ticked_id int generated always as identity (start with 1 increment by 1) primary key,
	schedule_id int not null,
	pass_id int not null,
	constraint FK_schedule foreign key (schedule_id)
		references "Operations"."Schedule"(schedule_id)
		on update cascade
		on delete no action,
	constraint FK_pass foreign key (pass_id)
		references "Clients"."Passenger"(pass_id)
		on update cascade
		on delete no action,
	cost money not null check (cost >= 0::money) default 0.00::money,
	place_number int null check (place_number > 0 AND place_number <= 100),
	constraint AK_cl_ticket unique (schedule_id, pass_id)
	);
	
create view "Operations"."Long_routs_view"
as select 
	depart,
	arrive,
	trip_time
from "Operations"."Route"
where active is true and trip_time::interval >= '1 day'::interval; 

create view "Operations"."Travel_info_view"
as select
	opr.depart as "Пункт отправления",
	opr.arrive as "Пункт назначения",
	cv.model as "Модель ТС",
	cv.number_plate as "Гос.номер",
	concat_ws(' ', od.lastname, od.firstname, od.patronymic) as "ФИО Водителя",
	concat_ws(' ', cp.lastname, cp.firstname, cp.patronymic) as "ФИО Пассажира",
	ct.place_number as "№ места"
from 
	"Clients"."Passenger" as cp inner join "Clients"."Ticket" as ct 
	on cp.pass_id = ct.pass_id inner join 
	"Operations"."Schedule" as os on ct.schedule_id = os.schedule_id inner join 
	"Operations"."Route" as opr on os.route_id = opr.route_id inner join 
	"Cars"."Vehicle" as cv on os.vin = cv.vin inner join 
	"Operations"."Driver" as od on os.driver_id = od.driver_id
where os.date_depart >= now();
	
	
	
	
