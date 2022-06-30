use TSQLV3;
-- decaring and setting the variable
declare @i as int;
set @i = 10;
select @i as number;

-- declaring and setting the variable in the same line
declare @i as int = 10;
select @i as number;

-- set can only be used to assign one variable at a time
-- This makes it a little bit non-efficient
-- Can be used with scaler expression which means it can be used with scalar subquery

declare @empname as nvarchar(61);
set @empname = (select firstname + ' ' + lastname
				from hr.Employees
				where empid = 3);
select @empname as empname;

-- multiple sets

declare @firstname as nvarchar(40), @lastname as nvarchar(40);
set @firstname = (select firstname from hr.Employees where empid = 3);
set @lastname = (select lastname from hr.Employees where empid = 3);
select @firstname as firstname, @lastname as lastname;

-- non standard select statement
declare @firstname as nvarchar(40), @lastname as nvarchar(40);
select 
	@firstname = firstname,
	@lastname = lastname
from hr.Employees
where empid = 3;
select @firstname as firstname, @lastname as lastname;

-- if the query returned multiple rows
-- The query would not fail and the value that the variables would hold would be
-- The last row accessed by sql server engine
-- That mean this query would be nondetermenstic

-- A batch is one sql statement or more that are submitted to the engine as a unit
-- Those statements are first parsed(syntax checked) -- Then passed to resolution/binding
-- Before going to the optimization
-- It is not a transaction
-- A batch could contain multiple transaction, And a transaction could be submitted
-- through multiple batches
-- Client application programming interfaces like ado.net provide some methods to 
-- connect and send batches to sql server engine
-- A batch is treated as a unit during parsing
-- That means that if one syntax is wrong somehow, the whole batch would not execute
-- But the batch is not treated as a unit during execution unless withn a transaction

-- Valid batch
print 'First Batch';
use TSQLV3;
go
-- invalid batch
print 'Second Batch';
select custid from sales.Customers;
select empid fom hr.employees;
-- valid batch
print 'Third batch';
select empid from hr.Employees;

-- The variables only exists in their current batches
declare @i as int;
set @i = 10;

-- succeeds
print @i;
go

-- fails
print @i;

-- Some statements can not be combined with other statements in the same batch
-- To solve this problem, you must seperate the statements with the go command
-- Such statements like -- create default, create function, create procedure
-- create function, create trigger

drop view if exists dbo.myview;
go
create view dbo.myview
as
select empid from hr.employees;
go

-- The batch is the unit of resolution
-- That means that the search for the columns is done once before the execution of the batch
-- This means that if the table is altered at some point and we tried to access the changed 
-- data, even though it is valid, the query is going to fail
-- To solve this, try to seperate the data definition language and the data manipulation language
-- with the go command

drop table if exists dbo.t1;
create table dbo.t1( col1 int );

-- Here is the problem
alter table dbo.t1
add col2 int;
go
select col1, col2 from dbo.t1;

drop table if exists dbo.t1;


-- Go command
drop table if exists dbo.t1;
create table dbo.t1(col1 int);

set nocount on;

insert into dbo.t1(col1) default values;
go 100

select * from dbo.t1;

-- Flow control
-- T-sql provides two statements to control the flow
-- If Else statement -- based on a predicate -- The statements after if are executed
-- if the predicate is evaluated as true while the statements after else are executed
-- if the predicate is false or unknown
-- if there are more than one statement, use begin to start the block and end to end it

if year(sysdatetime()) <> year(dateadd(day, 1, sysdatetime()))
begin
	print 'This day is the end of the year';
	print 'Start the required procedure';
	print 'Fuck the whole world';
end
else
	if month(sysdatetime()) <> month(dateadd(day, 1, sysdatetime()))
	begin
		print 'This day is the end of the month';
		print 'Congratulation, you are pregnanat, man';
	end
	else
	begin
		print 'You are quite unlucky';
		print 'Fuck you, man';
	end

-- While is used to make a loop to execute a statement block a number of time

drop table if exists dbo.t1;
create table dbo.t1(col1 int not null);

declare @i as int = 1;

while @i < 1000
begin
	insert into dbo.t1(col1)
	values(@i);
	set @i = @i + 1;
end

select * from dbo.t1;
drop table dbo.t1;


-- Curser -- unrelational set with order
-- The curser process the table one row at a time making it extremely inefficient in 
-- most cases since we would abandon the relational model concept and the set theory
-- But it is quite efficied in a small few cases like when we want to perform a task
-- to each row differently or when dealing with the legacy systems
-- When dealing with the cursor, you are not only going to tell the engine what to get
-- But where to get it as well. In contrast to the set theory...
-- some steps are required
SET NOCOUNT ON;
DECLARE @Result AS TABLE
(
custid INT,
ordermonth DATE,
qty INT,
runqty INT,
PRIMARY KEY(custid, ordermonth)
);
DECLARE
@custid AS INT,
@prvcustid AS INT,
@ordermonth AS DATE,
@qty AS INT,
@runqty AS INT;
-- declare the cursor
declare c cursor fast_forward /* read only, forward only */ for
	select custid, ordermonth, qty
	from sales.CustOrders
	order by custid, ordermonth;

-- opening the cursor to brouse it
open c;

-- Fetch the attribute from the first record in the cursor to the variables
fetch next from c into @custid, @ordermonth, @qty;

select @prvcustid = @custid, @runqty = 0;
-- process , loop, fetch again
while @@FETCH_STATUS = 0
begin
	if @custid <> @prvcustid
		select @prvcustid = @custid, @runqty = 0;
	set @runqty += @qty;
	insert into @Result values(@custid, @ordermonth, @qty, @runqty);
	fetch next from c into @custid, @ordermonth, @qty
end

-- close c
Close c;
-- deallocate C
deallocate c;

SELECT
custid,
CONVERT(VARCHAR(7), ordermonth, 121) AS ordermonth,
qty,
runqty
FROM @Result
ORDER BY custid, ordermonth;


-- doing the same task with the window function which is many times faster
select custid, ordermonth, qty, sum(qty) over(partition by custid
											order by ordermonth
											rows between unbounded preceding
											and current row) as runqty
from sales.CustOrders
order by custid;

-- using the subqueries but it is a bad solution
select C.custid, C.ordermonth, C.qty, (select sum(b.qty)
										from sales.CustOrders as b
										where b.custid = C.custid
										and b.ordermonth <= C.ordermonth) as runqty
from sales.CustOrders as C
order by C.custid;



-- Temporaly tables that exists only for this session
-- local temporary table that are only seen by this session

drop table if exists #myorderstotalbyyear;

create table #myorderstotalbyyear
(
	orderyear int not null primary key,
	qty int not null
);
insert into #myorderstotalbyyear
select Year(O.orderdate) as orderyear,
	sum(od.qty) as qty
from sales.orders as O
inner join sales.OrderDetails as od
on o.orderid = od.orderid
group by Year(O.orderdate);

select Cur.orderyear, Cur.qty as curyearqty, prv.qty as prvyearqty
from #myorderstotalbyyear as Cur
left outer join #myorderstotalbyyear as prv
on cur.orderyear = prv.orderyear + 1;

drop table if exists #myorderstotalbyyear;

-- Global temporary table is like the local temporary table with some differences
-- The table name use the prefix ##table
-- The table data could be accessed from the different session
-- But it would still be destroyed when the main session die

-- table variables is somewhat similar to the local temporary table except
-- it doesn't have a physical present and could only accessed by the batch and session
-- declare @tablename as table ();

-- To make the table reusable, we use create type and then define the variable as created_type

-- Dynamic sql -- using exec and exec sp_executesql


DECLARE
@sql AS NVARCHAR(1000),
@orderyear AS INT,
@first AS INT;
DECLARE C CURSOR FAST_FORWARD FOR
SELECT DISTINCT(YEAR(orderdate)) AS orderyear
FROM Sales.Orders
ORDER BY orderyear;
SET @first = 1;
SET @sql = N'SELECT *
FROM (SELECT shipperid, YEAR(orderdate) AS orderyear, freight
FROM Sales.Orders) AS D
PIVOT(SUM(freight) FOR orderyear IN(';
OPEN C;
FETCH NEXT FROM C INTO @orderyear;
WHILE @@fetch_status = 0
BEGIN
IF @first = 0
SET @sql += N','
ELSE
SET @first = 0;
SET @sql += QUOTENAME(@orderyear);
FETCH NEXT FROM C INTO @orderyear;
END;
CLOSE C;
DEALLOCATE C;
SET @sql += N')) AS P;';
EXEC sp_executesql @stmt = @sql;
