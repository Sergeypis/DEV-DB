--Лабораторная работа №2

--Задание 1. Написание запросов с фильтрацией
--1.	Выведите заказчиков с кодом (id) 30
select 
	companyname,
	contactname,
	contacttitle,
	address,
	city,
	region,
	postalcode,
	country,
	phone,
	fax,
	tag,
	custid
from "Sales"."Customers"
where custid = 30::int4;

--2.	Выведите все заказы, сделанные (оформленные) после 10 апреля 2008 года
select 
	orderid,
	custid,
	empid,
	orderdate,
	requireddate,
	shipperid,
	freight,
	shipname,
	shipaddress,
	shipcity,
	shipregion,
	shippostalcode,
	shipcountry,
	shippeddate
from "Sales"."Orders" o 
where orderdate > '2008-04-10'::date;

--3.	Выведите название и стоимость продуктов, при условии, что стоимость находится в диапазоне от 100 до 250.
select 
	productname,
	unitprice
from "Production"."Products"
where unitprice between 100::money and 250::money;

--4.	Выведите всех заказчиков, проживающих в Париже, Берлине или Мадриде.
select 
	companyname,
	contactname,
	contacttitle,
	address,
	city,
	region,
	postalcode,
	country,
	phone,
	fax,
	tag,
	custid
from "Sales"."Customers"
where city in ('Paris','Berlin','Madrid');

--5.	Выведите всех сотрудников, для которых не определен регион проживания
select 
	empid,
	lastname,
	firstname,
	title,
	titleofcourtesy,
	birthdate,
	hiredate,
	address,
	city,
	region,
	postalcode,
	country,
	phone,
	mgrid
from "HR"."Employees"
where region is Null;

--6.	Выведите заказчиков с именами кроме “Linda”, “Robert”, “Ann”
select 
	companyname,
	contactname,
	contacttitle,
	address,
	city,
	region,
	postalcode,
	country,
	phone,
	fax,
	tag,
	custid
from "Sales"."Customers"
where contactname not similar to '%,\s*(Linda|Robert|Ann)\s*';
--(Неверно!) where trim(split_part(contactname, ',', 2)) not in ('Linda', 'Robert', 'Ann');

--7.	Выведите заказчиков, чья фамилия начинается либо на букву “B” либо “R” либо “N”. 
--Фильтрация должна производится на исходных данных столбца (не на вычисляемом выражении)
select 
	companyname,
	contactname,
	contacttitle,
	address,
	city,
	region,
	postalcode,
	country,
	phone,
	fax,
	tag,
	custid
from "Sales"."Customers"
where 
	contactname like 'B%,%' or 
	contactname like 'R%,%' or 
	contactname like 'N%,%'
--(Тоже рабочий вариант)where contactname similar to '\s*(B|R|N)%\s*,%';

--8.	Выведите информацию о заказчиках, сформировав два вычисляемых столбца: Фамилия заказчика и Имя заказчика. В результирующую выборку должны попасть только те заказчики, чье имя начинается либо на букву "P" либо на букву "M", а фамилия при этом начинается либо на  “S”  либо на  “K”.
--Фильтрация должна производится на исходных данных столбца (не на вычисляемом выражении)
select trim((string_to_array(contactname, ','))[1]) as "Фамилия заказчика",
trim((split_part(contactname, ',', 2))) as "Имя заказчика"
from "Sales"."Customers"
where contactname ~ '^\s*[SK].+,\s*[PM].+';

 
--Задание 2. Написание запросов к нескольким таблицам
--1.	Сформируйте выборку следующего вида:    ФИО сотрудника, Номер Заказа, Дата Заказа.
--Отсортируйте выборку по дате (от самых ранних к самым поздним заказам)
select 
	concat_ws(' ', e.lastname, e.firstname) as "ФИО сотрудника", 
	o.orderid as "Номер заказа",
	o.orderdate as "Дата заказа"
from "HR"."Employees" as e inner join "Sales"."Orders" as o
on e.empid = o.empid
order by o.orderdate;

--2.	Напишите запрос, который выбирает информацию о заказах и их деталях:[orderid], [custid],[empid],[orderdate] ,[productid],[unitprice],[qty],[discount].
--Сформируйте в этом запросе вычисляемый столбец (LineTotal), который рассчитывает стоимость каждой позиции в заказе с учетом скидки
select 
	o.orderid,
	o.custid,
	o.empid,
	o.orderdate,
	od.productid,
	od.unitprice,
	od.qty,
	od.discount,
	od.unitprice * od.qty * (1 - od.discount) as "LineTotal"
from "Sales"."Orders" as o inner join "Sales"."OrderDetails" as od
on o.orderid = od.orderid;

--3.	Напишите запрос, возвращающий выборку следующего вида:   Номер заказа, Название заказчика, Фамилия сотрудника (компании заказчика), Дата заказа, Название транспортной компании.
--В запрос должны войти только те записи, которые соответствуют условию:  Заказчики и Сотрудники (Emploees) проживают в одном городе
select 
	o.orderid as "Номер заказа",
	c.companyname as "Название заказчика",
	trim(split_part(c.contactname, ',', 1))  as "Фамилия сотрудника",
	o.orderdate as "Дата заказа",
	s.companyname as "Название транспортной компании"
from 
	"Sales"."Orders" as o inner join "Sales"."Customers" as c on o.custid = c.custid inner join 
	"Sales"."Shippers" as s on o.shipperid = s.shipperid inner join 
	"HR"."Employees" as e on o.empid = e.empid
where c.city = e.city;

 
--Задание 3. Использование операторов наборов записей (UNION, EXCEPT, INTERSECT)
--1.	Напишите запрос, возвращающий набор уникальных записей из таблиц Employees и Customers. Результирующая таблица должна содержать 3 столбца: country, region, city. 
select country, region, city from "HR"."Employees"
union
select country, region, city from "Sales"."Customers";

--2.	Напишите запрос, возвращающий набор уникальных записей из таблиц Employees (адреса сотрудников - country, region, city), исключив из этого списка записи из таблицы Customers (адреса Клиентов - country, region, city). Результирующая таблица должна содержать 3 столбца: country, region, city. 
select country, region, city from "HR"."Employees"
except
select country, region, city from "Sales"."Customers";


--Задание 4. Запросы с группировкой
--1.	Выведите таблицу из трех столбцов: максимальная, минимальная и средняя стоимость продуктов. 
select
	max(unitprice) as "max_price",
	min(unitprice) as "min_price",
	avg(unitprice::numeric) as "avg_price"
from "Production"."Products";

--2.	Выведите таблицу из 2-х столбцов: номер категории и количество продуктов в каждой категории.
select
	categoryid as "Category", count(*) as "Quantity" 
from "Production"."Products"
group by categoryid
order by categoryid;

--3.	Выведите данные о количестве заказов, оформленных каждым сотрудником
select
	count(coalesce(o.empid, 0)) as "Orders",
	concat_ws(' ', e.firstname, e.lastname) as "Employees"
from "Sales"."Orders" as o full join "HR"."Employees" as e on o.empid = e.empid 
group by 
	o.empid,
	concat_ws(' ', e.firstname, e.lastname);

--4.	Выберите 5 самых выгодных заказчиков, с точки зрения суммарной стоимости их заказов
select 
	od.orderid as "Order",
	--o.custid,
	trim(replace(c.contactname, ',', ' ')) as "Customer",
	sum(unitprice * qty * (1-discount)) as "Total_order_price"
from 
	"Sales"."OrderDetails" as od inner join 
	"Sales"."Orders" as o on od.orderid = o.orderid inner join
	"Sales"."Customers" as c on o.custid = c.custid
group by od.orderid, o.custid, c.contactname
order by "Total_order_price" desc 
limit 5;

--5.	Выведите год, количество сделанных заказов в этом году и количество уникальных заказчиков, которые делали эти заказы.
select
	extract(year from orderdate) as "Year", count(*) as "Count_orders",
	count(distinct custid) as "Count_customers"
from 
	"Sales"."Orders"
group by extract(year from orderdate);

--6.	Выведите список только тех заказов, общая стоимость которых превышает 1000
select 
	od.orderid as "Order",
	sum(unitprice * qty * (1-discount)) as "Total_order_price"
from 
	"Sales"."OrderDetails" as od inner join 
	"Sales"."Orders" as o on od.orderid = o.orderid
group by od.orderid
having sum(unitprice * qty * (1-discount)) > 1000::money
order by "Total_order_price" desc;

--ВНИМАНИЕ: Вычисляемые столбцы должны иметь соответствующие наименования.


