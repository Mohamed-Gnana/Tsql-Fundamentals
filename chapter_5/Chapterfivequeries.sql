use TSQLV3;

-- using derived table expressions
select orderyear, numcusts
from (select year(orderdate) as orderyear, count(distinct custid) as numcusts
		from sales.orders
		group by year(orderdate)) as newtable;

-- using common table expressions (CTEs) : makes the nesting more readable and better looking

with newtable as 
(
	select year(orderdate) as orderyear, custid
	from sales.orders
),
newesttable as
(
	select orderyear, count(distinct custid) as numcusts
	from newtable
	group by orderyear
)
select orderyear, numcusts
from newesttable;


-- using derived table expressions
select cur.orderyear, cur.numcusts as curnumcusts, prv.numcusts as prvnumcusts, cur.numcusts-prv.numcusts as growth, prv.orderyear as prvyear
from (select year(orderdate) as orderyear,
		count(distinct custid) as numcusts
		from sales.orders
		group by year(orderdate)) as cur
		left outer join
		(select year(orderdate) as orderyear,
		count(distinct custid) as numcusts
		from sales.orders
		group by year(orderdate)) as prv
		on cur.orderyear = prv.orderyear + 1;

-- using common table expressions
with c1 as
(
	select year(orderdate) as orderyear, custid 
	from sales.orders
),
c2 as
(
	select orderyear, count(distinct custid) as numcusts
	from c1
	group by orderyear
)
select a.orderyear, a.numcusts, b.numcusts, a.numcusts-b.numcusts as growth
from c2 as a
left outer join c2 as b
on a.orderyear =  b.orderyear + 1;


with C as 
(
	select empid, mgrid, firstname, lastname
	from hr.employees
	where empid = 2
)
select b.empid, b.mgrid, b.firstname, b.lastname
from C as a
inner join hr.employees as b
on b.mgrid = a.empid;

-- using recursive ctes
with EmpCtes as
(
	select empid, mgrid, firstname, lastname
	from hr.Employees
	where empid = 2

	union all

	select c.empid, c.mgrid, c.firstname, c.lastname
	from EmpCtes as p
	inner join hr.Employees as c
	on c.mgrid = p.empid
)
select empid, mgrid, firstname, lastname
from EmpCtes
option(maxrecursion 1); -- The statement terminated. The maximum recursion 1 has been exhausted before statement completion.

-- creating view
use TSQLV3;
drop view if exists sales.UsaCusts;
go
create view sales.UsaCusts as
(
	select custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax
	from sales.customers
	where country = N'USA'
);
go

select OBJECT_DEFINITION(OBJECT_ID(N'Sales.UsaCusts'));

alter view sales.UsaCusts with encryption as
(
	select custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax
	from sales.customers
	where country = N'USA'
);
go

select OBJECT_DEFINITION(OBJECT_ID('Sales.UsaCusts'));

exec sp_helptext 'sales.UsaCusts';

alter view sales.UsaCusts with encryption, schemabinding as 
(
	select custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax
	from sales.customers
	where country = N'USA'
);
go

alter table sales.customers drop column address;


---- create function (table valued functions TVFs)

drop function if exists dbo.GetCustOrders;
go
create function dbo.GetCustOrders(@cid as int) returns table as return
(
	select orderid, custid, empid, orderdate, requireddate,
	shippeddate, shipperid, freight, shipname, shipaddress, shipcity,
	shipregion, shippostalcode, shipcountry
	from sales.orders
	where custid = @cid
);
go

select orderid, custid
from dbo.GetCustOrders(1);

-- Cross apply and Outer apply similar to Join in a sense

drop function if exists dbo.GetTopOrders;
go
create function dbo.GetTopOrders(@cid as int, @n as int) returns table as return
(
	select top(@n) orderid, empid, orderdate, requireddate
	from sales.orders
	where custid = @cid
	order by orderdate desc, orderid desc
);
go

select C.custid, C.companyname, A.orderid, A.empid, A.orderdate, A.requireddate
from sales.Customers as C
cross join dbo.GetTopOrders(22,3) as A
order by C.custid;

select C.custid, C.companyname, A.orderid, A.empid, A.orderdate, A.requireddate
from sales.Customers as C
cross apply dbo.GetTopOrders(22,3) as A
order by C.custid;



select C.custid, C.companyname, A.orderid, A.empid, A.orderdate, A.requireddate
from sales.Customers as C
outer apply dbo.GetTopOrders(1,3) as A 
order by C.custid;

