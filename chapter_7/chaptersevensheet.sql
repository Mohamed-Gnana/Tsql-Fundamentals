use TSQLV3;

-- Exercise

-- E1)
select custid, orderid, qty,
		rank() over(partition by custid
					order by qty) as rnk,
		dense_rank() over(partition by custid
							order by qty) as dns_rnk
from dbo.orders;

-- E2)
select val, ROW_NUMBER() over(order by val) as rownum
from sales.OrderValues
group by val;

select distinct val, DENSE_RANK() over(order by val) as rownum
from sales.ordervalues;

-- E3)
select custid, orderid, qty,
		qty - lag(qty) over(partition by custid
							order by orderdate, orderid) as diffprev,
		qty - lead(qty) over(partition by custid
								order by orderdate, orderid) as diffnext
from dbo.orders;

-- E4
select empid,
	count(case when year(orderdate) = 2014 then orderid End) as cnt2014,
	count(case when year(orderdate) = 2015 then orderid End) as cnt2015,
	count(case when year(orderdate) = 2016 then orderid End) as cnt2016
from dbo.orders
group by empid;

select empid, [2014] as cnt2014, [2015] as cnt2015, [2016] as cnt2016
from (select empid, year(orderdate) as orderyear, orderid
		from dbo.orders) as o
pivot(count(orderid) for orderyear in ([2014], [2015], [2016])) as P;


-- E5)
USE TSQLV3;
DROP TABLE IF EXISTS dbo.EmpYearOrders;
CREATE TABLE dbo.EmpYearOrders
(
empid INT NOT NULL
CONSTRAINT PK_EmpYearOrders PRIMARY KEY,
cnt2014 INT NULL,
cnt2015 INT NULL,
cnt2016 INT NULL
);
INSERT INTO dbo.EmpYearOrders(empid, cnt2014, cnt2015, cnt2016)
SELECT empid, [2014] AS cnt2014, [2015] AS cnt2015, [2016] AS cnt2016
FROM (SELECT empid, YEAR(orderdate) AS orderyear
FROM dbo.Orders) AS D
PIVOT(COUNT(orderyear)
FOR orderyear IN([2014], [2015], [2016])) AS P;
SELECT * FROM dbo.EmpYearOrders;

-- solution

select empid, cast(right(orderyear, 4) as int) as orderyear, numorders
from dbo.empyearorders as e
cross apply (values (2014, cnt2014), (2015, cnt2015), (2016, cnt2016)) as C(orderyear, numorders)
where numorders <> 0;

select empid, cast(right(orderyear, 4) as int) as orderyear, numorders
from dbo.EmpYearOrders as e
unpivot(numorders for orderyear in (cnt2014, cnt2015, cnt2016)) as U;


-- E6)
select GROUPING_ID(empid, custid, orderyear) as groupingset,
		empid, custid, orderyear, sum(qty) as sumqty
from (select empid, custid, year(orderdate) as orderyear, qty
		from dbo.orders) as o
group by
	grouping sets
	(
		(empid, custid, orderyear),
		(empid, orderyear),
		(custid, orderyear)
	);