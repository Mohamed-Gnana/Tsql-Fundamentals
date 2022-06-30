use tsqlv3;

-- calculating order value and the total per cutomer and the percent
with T1 as
(
select empid, ordermonth, val, sum(val) over(partition by empid
												order by ordermonth
												rows between unbounded preceding
												and current row) as valuetillthismonth,
								sum(val) over(partition by empid) as totalvalue
from sales.EmpOrders
)
select empid, ordermonth, val, totalvalue, 100 * (val / totalvalue)
from T1;

-- using subqueries

select a.empid, a.ordermonth, a.val, (select sum(val)
								from Sales.EmpOrders as o
								where o.empid = a.empid) as totalvalue,
								(select sum(val)
								from sales.EmpOrders as b
								where a.empid = b.empid
								and b.ordermonth <= a.ordermonth) as totaltillnow
from sales.EmpOrders as a;

-- using group by
with t2 as
(
	select empid, sum(val) as totalvalue
	from sales.EmpOrders
	group by empid
),
t3 as
(
	select a.empid, a.ordermonth, a.val, b.totalvalue
	from sales.EmpOrders as a
	inner join t2 as b
	on a.empid = b.empid
)
select empid, ordermonth, val, totalvalue
from t3
order by empid;

-- rank window functions

select orderid, custid, val,
		ROW_NUMBER() over(order by val) as rownum,
		RANK() over(order by val) as "rank",
		DENSE_RANK() over(order by val) as "dense rank",
		NTILE(10) over(order by val) as "Ntile"
from sales.OrderValues;

-- with partition clause
select orderid, custid, val,
		ROW_NUMBER() over(partition by custid
							order by val) as rownum,
		RANK() over(partition by custid
					order by val) as [rank],
		DENSE_RANK() over(partition by custid
						order by val) as [dense rank],
		NTILE(10) over(partition by custid
						order by val) as [Ntile]
from sales.OrderValues
order by custid;

-- lag, lead, first_value, lastvalue

select orderid, custid, val,
		lag(val) over(partition by custid
						order by orderdate, orderid) as prv_value,
		lead(val) over(partition by custid
						order by orderdate, orderid) as nxt_value
from sales.OrderValues;

-- slight modification
select orderid, custid, val,
		lag(val) over(order by orderdate, orderid) as prv_val,
		lead(val) over(order by orderdate, orderid) as nxt_val
from sales.OrderValues
order by orderdate, orderid;

-- the other argument
select orderid, custid, val,
		lag(val, 1, 0) over(partition by custid
						order by orderdate, orderid) as prv_val,
		lead(val, 1, 0) over(partition by custid
								order by orderdate, orderid) as nxt_val
from sales.OrderValues
order by custid;

-- firstvalue and lastvalue

select orderid, custid, val,
		FIRST_VALUE(val) over(partition by custid
							order by orderdate, orderid
							rows between unbounded preceding
							and current row) as firstvalue,
		LAST_VALUE(val) over(partition by custid
								order by orderdate, orderid
								rows between current row
								and unbounded following) as lastvalue
from sales.OrderValues
order by custid, orderdate;

-- aggregate window functions

select orderid, custid, val, sum(val) over(partition by custid)
from sales.OrderValues;

-- aggregate functions don't hide details and they don't query from the start like the subqueries

select orderid, custid, val,
	100 * (val / sum(val) over()) as pall,
	100 * (val / sum(val) over(partition by custid)) as pcall
from sales.OrderValues;

-- to do this using group by it would turn out quiet greusome
-- since you would lose the other details and you would have to use table expressions and joins

with t1 as
(
	select custid, sum(val) as totalvalpercust
	from sales.OrderValues
	group by custid
), t2 as
(
	select b.orderid, a.custid, b.val, a.totalvalpercust, sum(val) over() as totalvalue
	from t1 as a
	inner join sales.OrderValues as b
	on a.custid = b.custid
)
select orderid, custid, val,
		100 * (val / totalvalue) as pall,
		100 * (val / totalvalpercust) as pcall
from t2;

-- test
select DATENAME(month, orderdate) + ' - ' + DATEname(year, orderdate), sum(val) over(order by orderdate, orderid) valpermonth
from sales.OrderValues
order by orderdate;

with t1 as
(
	select DATENAME(month, orderdate) + ' - ' + DATEname(year, orderdate) as Month_Year, val, dense_rank() over(order by year(orderdate), month(orderdate)) as rownum
	from sales.OrderValues
), t2 as
(
	select Month_Year, rownum, sum(val) as valpermonth
	from t1
	group by Month_Year, rownum
)
select Month_Year, valpermonth, sum(valpermonth) over(order by rownum, Month_Year) as totaltillnow
from t2
order by rownum;


-- pivoting data
drop table if exists dbo.orders;
create table dbo.orders
(
	orderid int not null
	constraint pk_orders primary key,
	orderdate date not null,
	empid int not null,
	custid varchar(5) not null,
	qty int not null
);

insert into dbo.orders(orderid, orderdate, empid, custid, qty)
values
	(30001, '20140802', 3, 'A', 10),
	(10001, '20141224', 2, 'A', 12),
	(10005, '20141224', 1, 'B', 20),
	(40001, '20150109', 2, 'A', 40),
	(10006, '20150118', 1, 'C', 14),
	(20001, '20150212', 2, 'B', 12),
	(40005, '20160212', 3, 'A', 10),
	(20002, '20160216', 1, 'C', 20),
	(30003, '20160418', 2, 'B', 15),
	(30004, '20140418', 3, 'C', 22),
	(30007, '20160907', 3, 'D', 30);
SELECT * FROM dbo.Orders;

select 
	sum(case when custid = 'A' then qty else 0 End) as A,
	sum(case when custid = 'B' then qty else 0 End) as B,
	sum(case when custid = 'C' then qty else 0 End) as C,
	sum(case when custid = 'D' then qty else 0 End) as D
from dbo.orders
group by empid;

-- using pivot table operator

select empid, A, B, C, D
from (select empid, custid, qty
		from dbo.orders) as a
pivot(sum(qty) for custid in (A, B, C, D)) as b;

-- unpivoting

drop table if exists dbo.EmpCustOrders;
CREATE TABLE dbo.EmpCustOrders
(
empid INT NOT NULL
CONSTRAINT PK_EmpCustOrders PRIMARY KEY,
A VARCHAR(5) NULL,
B VARCHAR(5) NULL,
C VARCHAR(5) NULL,
D VARCHAR(5) NULL
);
INSERT INTO dbo.EmpCustOrders(empid, A, B, C, D)
SELECT empid, A, B, C, D
FROM (SELECT empid, custid, qty
FROM dbo.Orders) AS D
PIVOT(SUM(qty) FOR custid IN(A, B, C, D)) AS P;
SELECT * FROM dbo.EmpCustOrders;

-- unpivot is three phase operation -- 1- copies  -- 2- extracting the values -- 3- removing the waste

select empid, custid, qty
from dbo.EmpCustOrders
cross apply (values ('A', A), ('B', B), ('C', C), ('D', D)) as C(custid, qty)
where qty is not null;

-- using the unpivot table operator

select empid, custid, qty
from dbo.EmpCustOrders
unpivot(qty for custid in (A, B, C, D)) as U;


-- grouping sets
-- if you want to compine multiple grouping sets you use some subclauses of group by
-- the premitive way to compine the multiple sets

select empid, custid, sum(qty) as sumqty
from dbo.orders
group by empid, custid
union all
select empid, Null, sum(qty)
from dbo.orders
group by empid
union all
select Null, custid, sum(qty)
from dbo.orders
group by custid
union all
select Null, Null, sum(qty)
from dbo.orders;

-- unfortunately this way causes the query to be this long
-- Not only that but it had more cost since the sql server had to aggregate from the start
-- solution -- grouping sets(), Cube(), Rolls up()

select empid, custid, sum(qty) as sumqty
from dbo.orders
group by
	grouping sets
	(
		(empid, custid),
		(empid),
		(custid),
		()
	);
-- Cube is some kind of abbreviation -- it generates the power set
-- Cube(empid, custid) --> grouping sets ( (empid, custid), (empid), (custid), () )
select empid, custid, sum(qty) as sumqty
from dbo.orders
group by
	cube(empid,custid);

-- Rollup uses herirachy
-- Rollup(a, b, c) --> grouping sets( (a, b, c), (a, b), (a), () )

select empid, custid, sum(qty) as sumqty
from dbo.orders
group by rollup(empid, custid); -- grouping sets ( (empid, custid), (empid), () )
