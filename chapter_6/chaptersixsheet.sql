use TSQLV3;

-- E2
with T as
(
	select 1 as n

	union all

	select n + 1
	from T
	where n < 10
)
select n
from T
option(maxrecursion 10);

-- E3

select custid, empid from sales.orders where orderdate >= '20150101' and orderdate < '20150201'
except
select custid, empid from sales.orders where orderdate >= '20150201' and orderdate < '20150301'
order by custid;

-- E4

select custid, empid from sales.orders where orderdate >= '20150101' and orderdate < '20150201'
intersect
select custid, empid from sales.orders where orderdate >= '20150201' and orderdate < '20150301'
order by custid;

-- E5
select custid, empid from sales.orders where orderdate >= '20150101' and orderdate < '20150201'
intersect
select custid, empid from sales.orders where orderdate >= '20150201' and orderdate < '20150301'
except
select custid, empid from sales.orders where orderdate >= '20140101' and orderdate < '20150101'
order by custid;

-- E6

select u.country, u.region, u.city
from (select 1 as sortcol, country, region, city
		from hr.Employees
		union all 
		select 2, country, region, city
		from production.Suppliers) as u
order by u.sortcol, u.country;