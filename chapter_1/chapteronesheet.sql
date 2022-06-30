use TSQLV3;

-- E1
select orderid, orderdate, custid, empid
from sales.orders
--where month(orderdate) = 6
--and year(orderdate) = 2014;
where orderdate >= '20140601'
and orderdate < '20140701';

-- E2
select orderid, orderdate, custid, empid
from sales.orders
--where eomonth(orderdate) = orderdate;
where orderdate = dateadd(month,
						datediff(month, '18991231', orderdate),
						'18991231');
-- E3
select empid, firstname, lastname
from hr.employees
where len(lastname) - len(replace(lastname, N'e', N'')) >= 2;

-- E4
with T as
(
	select orderid, unitprice * qty as totalvalue
	from sales.OrderDetails
)
select orderid, totalvalue
from T
where totalvalue > 10000;

-- E5
select empid, lastname
from hr.employees
where lastname collate Latin1_General_CS_AS like N'[a-z]%';

-- E6
---------------- the first discards all the rows where orderdate < 20150101 -- that means there it wants the
---------------- number of orders places by every employee before 2015 -- unless the employe
---------------- did not handle anything before 2015 it would return all employees
---------------- the second one discard the employees that did not handle any orders after the start of 2015

select empid, count(*) as numoforders
from sales.Orders 
where orderdate < '20150501'
group by empid;

select empid, count(*) as numoforders
from sales.orders
group by empid
having max(orderdate) < '20150501';