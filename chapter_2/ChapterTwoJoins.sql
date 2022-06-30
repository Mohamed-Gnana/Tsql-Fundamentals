use TSQLV3;

select C.custid, E.empid
from Sales.Customers as C
	cross join HR.Employees as E;

select E1.empid, E1.firstname, E1.lastname,
	E2.empid, E2.firstname, E2.lastname
from HR.Employees as E1
	cross join HR.Employees as E2;

drop table if exists dbo.digits;
create table dbo.digits (digit int not null primary key);
insert into dbo.digits(digit)
	values (0), (1), (2), (3), (4), (5), (6), (7), (8), (9);
select digit from dbo.digits;

select D3.digit * 100 + D2.digit * 10 + D1.digit As n
from dbo.digits as D1
	cross join dbo.digits as D2
	cross join dbo.digits as D3
order by n;

select E.empid, E.firstname, E.lastname, O.orderid
from Hr.Employees as E
	inner join Sales.Orders as O
	On E.empid = O.empid
where E.empid = 1;

select E1.empid, E2.empid
from HR.Employees as E1
	inner join HR.Employees as E2
	on E1.empid < E2.empid
where E1.empid <= 3
	And E2.empid <= 3;

select C.custid, C.companyname, O.orderid,
	OD.productid, OD.qty
from sales.Customers as C 
	inner join sales.Orders as O
	on C.custid = O.custid
	inner join sales.OrderDetails as OD
	on O.orderid = OD.orderid;

select C.custid, C.companyname, O.orderid
from sales.Customers as C
	Left outer join sales.Orders as O
	on C.custid = O.custid
where O.empid is null;

select DATEADD(day, Nums.n-1, cast('20130101' as date)) as order_date,
	O.orderid, O.orderdate, O.empid
from dbo.Nums
	left outer join sales.orders as O
	on dateadd(day, Nums.n - 1, cast('20130101' as date)) = O.orderdate
where Nums.n < DATEDIFF(day, cast('20130101' as date), cast('20151231' as date)) + 1
order by order_date;

select E.empid, E.firstname, E.lastname, O.orderid, Count(*) as numorders
from HR.Employees as E
	inner join Sales.Orders as O
	on E.empid = O.empid;
-- E1
select E.empid, E.firstname, E.lastname, Nums.n
from hr.Employees as E
	cross join dbo.Nums
where Nums.n < 6;
-- E2
select E.empid, DATEADD(day, Nums.n - 1, cast('20150612' as date)) as dt
from Hr.Employees as E
	cross join dbo.Nums
where DATEADD(day, Nums.n - 1, cast('20150612' as date)) <= cast('20150616' as date)
order by E.empid;
-- E3
select C.custid, Count(Distinct O.orderid) as numorders, sum(OD.qty)
from Sales.Customers as C
	inner join Sales.Orders as O
	on C.custid = O.custid
	inner join Sales.OrderDetails as OD
	on O.orderid = OD.orderid
where C.country = N'USA'
Group by C.custid
Order by C.custid;
-- E4
select C.custid, C.companyname, O.orderid, O.orderdate
from Sales.Customers as C
	left outer join Sales.Orders as O
	on C.custid = O.custid;
-- E5
select C.custid, C.companyname, O.orderid, O.orderdate
from Sales.Customers as C
	left outer join Sales.Orders as O
	on C.custid = O.custid
where O.orderid is null;
-- E6
select C.custid, C.companyname, O.orderid, O.orderdate
from Sales.Customers as C
	left outer join Sales.Orders as O
	on C.custid = O.custid
where O.orderdate = cast('20150212' as date);
-- E7
select C.custid, C.companyname, O.orderid, O.orderdate
from Sales.Customers as C
	left outer join Sales.Orders as O
	on C.custid = O.custid
	And O.orderdate = cast('20150212' as date);
-- E8
select C.custid, C.companyname,
		case
			when O.orderid is not null then 'yes'
			else 'no'
		End as HasOrderonthatday
from Sales.Customers as C
	Left outer join Sales.Orders as O
	on C.custid = O.custid
	And O.orderdate = '20150212';
