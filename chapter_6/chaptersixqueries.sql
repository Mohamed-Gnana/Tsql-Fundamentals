use TSQLV3;

-- Set operators -- union with all flavor
select country, region, city from hr.Employees
union all
select country, region, city from sales.Customers
order by country;

-- union with implicit distinct flavor

select country, region, city from hr.employees
union
select country, region, city from sales.customers
order by country;

-- intersect with implicity distinct flavor

select country, region, city from hr.employees
intersect
select country, region, city from sales.customers
order by country;

-- intersect all using rownumber() window function

select country, region, city, ROW_NUMBER() over(partition by country, region, city
												order by (select 0)) as rownum
from hr.Employees
intersect
select country, region, city, ROW_NUMBER() over(partition by country, region, city
												order by (select 0)) as rownum
from sales.customers;

-- To throw away row number, we use table expressions: CTES

with intersect_all as 
(
	select country, region, city, ROW_NUMBER() over(partition by country, region, city
												order by (select 0)) as rownum
	from hr.Employees
	intersect
	select country, region, city, ROW_NUMBER() over(partition by country, region, city
													order by (select 0)) as rownum
	from sales.customers
)
select country, region, city
from intersect_all;

-- exept operator

select country, region, city from hr.Employees
except
select country, region, city from sales.customers;

-- except operator

select country, region, city from sales.Customers
except
select country, region, city from hr.Employees;

-- countries that have customers but no employees

select country from sales.customers
except
select country from hr.Employees;

-- Except all
with exceptall as
(
	select country, region, city, row_number() over(partition by country, region, city
													order by (select 0)) as rownum
	from hr.Employees
	except
	select country, region, city, row_number() over(partition by country, region, city
													order by (select 0)) as rownum
	from sales.Customers
)
select country, region, city
from exceptall;