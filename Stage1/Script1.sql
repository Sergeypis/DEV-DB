select lastname
,firstname
,regexp_replace(lower(concat(firstname, '.', lastname, '@monitor.ru')), '[^\w\.-@]', '_', 'g') as "e-mail"
from "HR"."Employees";

