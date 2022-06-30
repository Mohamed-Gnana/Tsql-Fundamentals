use TSQLV3;

-- E1
---- because of the logical query processing --> where clause are executed prior to the select clause. That means by the time the where phase turn show up
---- endofyear 'the alias name' did not get the chance to be defined.
-- Solution --> use subqueries -- table expressions -- derived table -- CTEs
-- derived table
select orderid, orderdate, custid, empid, endofyear
from (select orderid, orderdate, custid, empid, DATEFROMPARTS(year(orderdate), 12, 31) as endofyear
		from sales.orders) as T
where orderdate <> endofyear;

-- CTES
with T as
(
	select orderid, orderdate, custid, empid, DATEFROMPARTS(year(orderdate), 12, 31) as endofyear
	from sales.orders
)
select orderid, orderdate, custid, empid, endofyear
from T
where orderdate <> endofyear;

-- E2-1
with T as
(
	select empid, max(orderdate) as maxorderdate
	from sales.orders
	group by empid
)
select empid, maxorderdate
from T; 

--E2-2
with T as
(
	select empid, max(orderdate) as maxorderdate
	from sales.orders
	group by empid
)
select a.empid, a.maxorderdate, b.orderdate, b.custid
from T as a
inner join sales.orders as b
on a.empid = b.empid
and a.maxorderdate = b.orderdate;

-- E3-1
select orderid, orderdate, empid, custid, ROW_NUMBER() over(
															order by orderdate, orderid) as rownum
from sales.orders
order by orderdate, orderid;

-- E3-2
select orderid, orderdate, empid, custid, rownum
from (select orderid, orderdate, empid, custid, ROW_NUMBER() over(order by orderdate, orderid) as rownum
		from sales.orders) as T
where rownum between 11 and 20
order by orderdate, orderid;

-- E4
with T as
(
	select empid, mgrid, firstname, lastname
	from hr.Employees
	where empid = 9

	union all

	select a.empid, a.mgrid, a.firstname, a.lastname
	from T as b
	inner join hr.Employees as a
	on b.mgrid = a.empid
)
select empid, mgrid, firstname, lastname
from T;

-- E5
drop view if exists Sales.empqtyyear;
go
create view Sales.empqtyyear as
(
	select o.empid, year(o.orderdate) as orderyear, sum(od.qty) as qty
	from sales.orders as o
	inner join sales.OrderDetails as od
	on (o.orderid = od.orderid)
	group by year(o.orderdate), o.empid
);
go
select * from sales.empqtyyear order by empid, orderyear;

-- E5-2
with T as 
(
	select empid, orderyear, qty
	from sales.empqtyyear
)
select b.empid, b.orderyear, b.qty, (select sum(a.qty)
								from T as a
								where a.empid = b.empid
								and a.orderyear <= b.orderyear) as runqty
from T as b
order by b.empid, b.orderyear;

-- E6-1
drop function if exists Production.TopProducts;
go
create function Production.TopProducts(@supid as int, @n as int) returns table as return
(
	select productid, productname, unitprice
	from Production.Products
	where supplierid = @supid
	order by unitprice desc
	offset 0 rows fetch next @n rows only
);
go
select * from Production.TopProducts(5,2);

-- E6-2
select s.supplierid, s.companyname, a.productid, a.productname, a.unitprice
from Production.Suppliers as s
cross apply Production.TopProducts(s.supplierid, 2) as a;
