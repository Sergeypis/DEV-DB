--Задание. Использование подзапросов

--1.	Выведите информацию о заказах клиента, который был зарегистрирован в БД последним.
select 
	custid
	,orderid
	,orderdate
from "Sales"."Orders" as so
where custid = (select max(custid) 
					from "Sales"."Customers" as sc);

--2.	Выведите следующие данные по клиентам, которые сделали заказ в самую последнюю дату
select 
	companyname
	,contactname
	,contacttitle
	,address
	,city
	,region
	,postalcode
from "Sales"."Customers" as sc join "Sales"."Orders" as so on sc.custid = so.custid 
where so.orderdate =  (select max(orderdate)
					from "Sales"."Orders" as so);
					
select 
	companyname
	,contactname
	,contacttitle
	,address
	,city
	,region
	,postalcode
from "Sales"."Customers" as sc
where custid in (select custid
				from "Sales"."Orders" as so1
				where orderdate = (select max(orderdate)
									from "Sales"."Orders" as so2));
								
--3.	Выведите список клиентов, которые не делали заказов
select 
	custid
	,companyname
	,contactname
	,address
	,city
from "Sales"."Customers" as sc
where not exists (select 1 from "Sales"."Orders" as so
					where so.custid = sc.custid);
 
--4.	Выведите список заказов тех клиентов, которые проживают в Mexico
select 
	custid
	,orderid
	,orderdate
	,shipcountry
from "Sales"."Orders" as so
where custid in (select custid
					from "Sales"."Customers" as sc
					where country = 'Mexico');

--5.	Выведите самые дорогие продукты в каждой категории. Детали должны присутствовать!
	
select 
	productid
	,productname
	,supplierid
	,categoryid
	,unitprice
	,discontinued 
from "Production"."Products" as pp1
where (categoryid, unitprice::numeric) in (select categoryid, max(unitprice::numeric)
											from "Production"."Products" as pp2
											group by categoryid);

