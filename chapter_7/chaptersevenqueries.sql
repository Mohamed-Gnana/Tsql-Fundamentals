use TSQLV3;

select empid, ordermonth, val, sum(val) over(partition by empid--) as runval
											order by ordermonth--) as runval
											rows between unbounded preceding
											and current row) as runval
from sales.EmpOrders;

-- using subqueries

select b.empid, b.ordermonth, b.val, (select sum(a.val)
									from sales.EmpOrders as a
									where a.empid = b.empid
									and a.ordermonth <= b.ordermonth) as runval
from sales.EmpOrders as b
order by b.empid;

select orderid, custid, val, row_number() over(partition by custid
							order by val, orderid) as rownum, rank() over(order by val) as ranknum,
		dense_rank() over(order by val) as denserank, ntile(100) over(order by val) as nt
from sales.OrderValues
order by custid;

--- Distinct won't work here since the row number window function produces a distinct integer for each row
--- to remove the duplicate, you must solve this issue in a clause that precedes select clause in the logical
--- query processing like group by

select val, row_number() over(order by val) as rownum, count(val) as countval
from sales.OrderValues
group by val;

-- lag and lead window functions

select empid, ordermonth, val as [This Month's value], Lag(val, 3, 0) over(partition by empid
															order by val) as [The previous month's val],
		lead(val, 3, 0) over(partition by empid order by val) as [The next month's value]
from sales.EmpOrders
order by empid;

select empid, ordermonth, val as [This Month's value], First_value(val) over(partition by empid
															order by val
															rows between unbounded preceding
															and current row) as [The previous month's val],
		last_value(val) over(partition by empid order by val
						rows between current row
						and unbounded following) as [The next month's value]
from sales.EmpOrders
order by empid, val;

select orderid, rank() over() rownum
from sales.orders;

select orderid, custid, val,
		sum(val) over(partition by custid
					order by val
					rows between unbounded preceding
					and current row) as totalvaluepercustomer, -- Window frame gives a meaning to the ordering
		100. * val / sum(val) over() as pctotal,
		100. * val / sum(val) over(partition by custid) as pccust
from sales.OrderValues;

-- playing with the window frame

select orderid, custid, val,
	sum(val) over(partition by custid
				order by val
				rows between 1 preceding
				and 0 following) as specialtotalvalue
from sales.OrderValues;

--- creating dbo.orders table for pivoting -- rotating the rows into columns for presentation

USE TSQLV3;
DROP TABLE IF EXISTS dbo.Orders;
CREATE TABLE dbo.Orders
(
orderid INT NOT NULL,
orderdate DATE NOT NULL,
empid INT NOT NULL,
custid VARCHAR(5) NOT NULL,
qty INT NOT NULL,
CONSTRAINT PK_Orders PRIMARY KEY(orderid)
);
INSERT INTO dbo.Orders(orderid, orderdate, empid, custid, qty)
VALUES
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

-- quering for total orders for each employee and customer

select empid, custid, qty,
		sum(qty) over(partition by empid
					order by qty
					rows between unbounded preceding
					and current row) as totalqtyperempid,
		sum(qty) over(partition by custid
					order by qty
					rows between unbounded preceding
					and current row) as totalqtypercust
		
from dbo.Orders
order by custid;

select empid, custid, sum(qty) as sumqty
from dbo.Orders
group by empid, custid;

-- Pivoting using grouping -- Pivoting has three logical query phases -- grouping using an element
-- spreading using the other attribute -- finally we need to aggregate using an aggregate function
-- based on the grouping and spreading attributes

select empid, -- for rows
		sum( -- aggregating -- last logical process
			case when custid = 'A'	then qty end) as A, -- spreading the columns
		sum(case when custid = 'B'	then qty end) as B,
		sum(case when custid = 'C'	then qty end) as C,
		sum(case when custid = 'D'	then qty end) as D

from dbo.orders
group by empid -- grouping the table using empid -- that means that each row would represent an employee

-- using a pivot table operator. -- you must know that pivot operator needs to work on a table expression
-- that contains only the spreading attirbutes, aggregating attribute and the grouping attribute
-- or all the other attributes other than the spreading and aggregate ones would be used for grouping

with T as
(
	select empid, custid, qty
	from dbo.orders
)
select empid, A, B, C, D
from T
pivot(sum(qty) for custid in (A,B,C,D)) as p;


--- Unpivoting table

use TSQLV3;
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

-- The process of unpivoting require three logical operation
-- First we need to create multiple copies of each row with every customer
-- We will use cross join for this matter or cross apply
-- The difference between the two is that the later evaluate the left side first while the former treat
-- both sides as set

select *
from dbo.EmpCustOrders
cross apply (values('A'), ('B'), ('C'), ('D')) as C(custid);

-- after doing that, we need to take the value that corresponds to cust A and so on... At this point
-- the importance of cross apply show

select empid, custid, qty
from dbo.EmpCustOrders
cross apply (values('A', A), ('B', B), ('C', C), ('D', D)) as C(custid, qty);

-- Now, it is the time to discard the irrevelant information

select empid, custid, qty
from dbo.EmpCustOrders
cross apply (values('A', A), ('B', B), ('C', C), ('D', D)) as C(custid, qty)
where qty is not null;

-- using the unpivot table operator -- involves the same three logical process but it might ignore the third

select empid, custid, qty
from dbo.EmpCustOrders
unpivot(qty for custid in (A,B,C,D)) as p;


