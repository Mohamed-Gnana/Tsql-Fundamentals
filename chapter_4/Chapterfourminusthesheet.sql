use TSQLV3;
declare @maxorderid as int = (select MAX(orderid)
								from Sales.Orders) -- paranthies are important;
select orderid, orderdate, empid, custid
from Sales.Orders
where orderid = @maxorderid;

select orderid, orderdate, empid, custid
from Sales.Orders
where orderid = (select MAX(orderid)
					from Sales.Orders);

select orderid
from sales.Orders
where empid = (select empid
				from HR.Employees
				where lastname like N'C%');

select orderid
from sales.Orders
where empid = (select empid
				from HR.Employees
				where lastname like N'A%');

select orderid
from sales.Orders
where empid = (select empid
				from HR.Employees
				where lastname like N'D%'); -- Error -- more than one value returned from the subquery

select orderid
from sales.Orders
where empid in (select empid
				from HR.Employees
				where lastname like N'D%'); -- Works this time because I used operator in

select O.orderid
from Sales.Orders as O
	inner join HR.Employees as E
	on O.empid = E.empid
where E.lastname like N'D%';

select custid, orderid, orderdate, empid
from Sales.orders
where custid in (select custid
				from Sales.Customers
				where country = N'USA');

select C.custid, O.orderid, O.orderdate, O.empid
from Sales.Orders as O
	inner join Sales.Customers as C
	on O.custid = C.custid
where C.country = N'USA';

select custid, orderid, orderdate, empid
from sales.orders as o1
where o1.orderid = (select max(o2.orderid)
					from Sales.Orders as o2
					where o2.custid = o1.custid);

select orderyear, qty
from sales.OrderTotalsByYear;
