use TSQLV3;

select orderid, orderdate, custid, empid
from Sales.Orders
where orderdate = (select max(orderdate)
				from sales.Orders);

select custid, orderid, orderdate, empid
from sales.orders
where custid in (select Top(1) with ties o.custid
				from sales.orders as o
				group by o.custid
				order by count(o.orderid) desc);

select empid, firstname, lastname
from hr.Employees
where empid not in (select O.empid
				from sales.orders as O
				where O.orderdate >= '20150501');


select distinct country
from sales.Customers
where country not in (select country
						from hr.Employees)
order by country;

select custid, orderid, orderdate, empid
from sales.orders as o1
where orderdate = (select max(o2.orderdate)
					from sales.orders as o2
					where o2.custid = o1.custid)
order by custid;


select custid, companyname
from sales.Customers
where custid in(select O.custid
				from sales.orders as O
				where O.orderdate >= '20140101'
				and O.orderdate < '20150101')
		and custid not in (select O.custid
							from sales.orders as O
							where O.orderdate >= '20150101'
							and O.orderdate < '20160101')
order by custid;

select custid, companyname
from sales.Customers as C
where exists(select *
			from sales.orders as O
			where O.custid = C.custid
			and O.orderdate >= '20140101'
			and O.orderdate < '20150101')
	and not exists(select *
					from sales.orders as O
					where O.custid = C.custid
					and O.orderdate >= '20150101'
					and O.orderdate < '20160101')
order by C.custid;

select C.custid, C.companyname
from sales.customers as C
where C.custid in (select O.custid
					from sales.orders as O
					inner join sales.OrderDetails as OD
					on O.orderid = Od.orderid
					where OD.productid = 12)
order by C.custid;


select C.custid, C.ordermonth, C.qty, (select sum(C1.qty)
										from sales.CustOrders as C1
										where C1.custid = C.custid
						and	C1.ordermonth <=C.ordermonth) as runqty
from sales.CustOrders as C
order by C.custid, C.ordermonth;


select O1.custid, O1.orderdate, O1.orderid, datediff(day, (select top(1) O2.orderdate
															from sales.orders as O2
															where O1.custid = O2.custid
															and (O1.orderdate = O2.orderdate and O1.orderid > O2.orderid
																or O2.orderdate < O1.orderdate)
															order by O2.orderdate desc, O2.orderid desc),
															O1.orderdate) as Diff
from sales.orders as O1
order by O1.custid, O1.orderdate, O1.orderid;
				