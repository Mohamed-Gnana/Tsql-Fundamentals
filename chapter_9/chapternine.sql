use TSQLV3;

-- Temporal table -- sql server system-versioned temporal table
-- Must have the following elements
-- a primary key
-- Two columns of Datetime2 type with any precesion marked as the start and end of the validaty period
-- the start column must be marked with the option --> Generated always as row start
-- The ednd column must be marked with the option --> Generated always as row end
-- A designation of the period columns( the start and the end) with the option
-- --> perion for system_time(start, end)
-- The table itselef must be marked with the option --> system_versioning = On(set to on)
-- The table would be linked to the history table that would hold the old data
-- Sql server would create it for us
-- We also must know that according to sql standard
-- system-versioned temporal table is only one of the three types of temporal table
-- and rely on the system transactions to define the validaty of the period of the row
-- The second type is the application-time period table that rely on the application definition
-- to define the validaty of the period of the row
-- The last type is bitemporal that compines the other two types

drop table if exists dbo.employees;
go
create table dbo.employees
(
	empid int not null
	constraint pk_employees primary key nonclustered,
	empname varchar(25) not null,
	department varchar(50) not null,
	salary numeric(10,2) not null,
	sysstart datetime2(0)
	generated always as row start hidden not null,
	sysend datetime2(0)
	generated always as row end hidden not null,
	period for system_time(sysstart, sysend),
	index ix_employees clustered(empid, sysstart, sysend)
) with (system_versioning = on( history_table = dbo.employeeshistory));

-- What is marked as hidden won't appear using the select statement unless you state them explicitely
select *
from dbo.employees;

select empid, empname, department, salary, sysstart, sysend
from dbo.employees;

-- you can alter the table without needing to turn the system versioning off
-- The change will echo into the history table as well
alter table dbo.employees
add hiredate date not null
constraint def_hiredate default('19000101');

select *
from dbo.employees;
select * from dbo.employeeshistory;

alter table dbo.employees
drop constraint def_hiredate;
go
alter table dbo.employees
drop column hiredate;


-- table modification
-- unlike table creation, modification is the same as regular table except sql server doesn't
-- support truncate for temporal tables
INSERT INTO dbo.Employees(empid, empname, department, salary)
VALUES	(1, 'Sara', 'IT' , 50000.00),
		(2, 'Don' , 'HR' , 45000.00),
		(3, 'Judy', 'Sales' , 55000.00),
		(4, 'Yael', 'Marketing', 55000.00),
		(5, 'Sven', 'IT' , 45000.00),
		(6, 'Paul', 'Sales' , 40000.00);


-- quering the tables to see what changed
select empid, empname, department, salary, sysstart, sysend
from dbo.employees;
select empid, empname, department, salary, sysstart, sysend
from dbo.employeeshistory;

-- let's see what happened if a change happened to dbo.employees table
delete from dbo.employees
where empid = 6;

-- let's try an update statement that consists of a delete statement and insert one
update dbo.employees
set salary *= 1.05
where department = 'IT';

-- The time recorded is the start time of doing the transaction, let's try this
begin tran
update dbo.employees
set department = 'sales'
where empid = 5;

update dbo.employees
set department = 'IT'
where empid = 3;


-- droping a temporal table
-- Drop tables if exist
use TSQLV3;
IF OBJECT_ID(N'dbo.Employees', N'U') IS NOT NULL
BEGIN
IF OBJECTPROPERTY(OBJECT_ID(N'dbo.Employees', N'U'), N'TableTemporalType') = 2
ALTER TABLE dbo.Employees SET ( SYSTEM_VERSIONING = OFF );
DROP TABLE IF EXISTS dbo.EmployeesHistory, dbo.Employees;
END;
GO
-- Create and populate Employees table
CREATE TABLE dbo.Employees
(
empid INT NOT NULL
CONSTRAINT PK_Employees PRIMARY KEY NONCLUSTERED,
empname VARCHAR(25) NOT NULL,
department VARCHAR(50) NOT NULL,
salary NUMERIC(10, 2) NOT NULL,
sysstart DATETIME2(0) NOT NULL,
sysend DATETIME2(0) NOT NULL,
INDEX ix_Employees CLUSTERED(empid, sysstart, sysend)
);
INSERT INTO dbo.Employees(empid, empname, department, salary, sysstart, sysend)
VALUES
(1 , 'Sara', 'IT' , 52500.00, '2016-02-16T17:20:02', '9999-12-31T23:59:59'),
(2 , 'Don' , 'HR' , 45000.00, '2016-02-16T17:08:41', '9999-12-31T23:59:59'),
(3 , 'Judy', 'IT' , 55000.00, '2016-02-16T17:28:10', '9999-12-31T23:59:59'),
(4 , 'Yael', 'Marketing', 55000.00, '2016-02-16T17:08:41', '9999-12-31T23:59:59'),
(5 , 'Sven', 'Sales' , 47250.00, '2016-02-16T17:28:10', '9999-12-31T23:59:59');
-- Create and populate EmployeesHistory table
CREATE TABLE dbo.EmployeesHistory
(
empid INT NOT NULL,
empname VARCHAR(25) NOT NULL,
department VARCHAR(50) NOT NULL,
salary NUMERIC(10, 2) NOT NULL,
sysstart DATETIME2(0) NOT NULL,
sysend DATETIME2(0) NOT NULL,
INDEX ix_EmployeesHistory CLUSTERED(sysend, sysstart)
WITH (DATA_COMPRESSION = PAGE)
);
INSERT INTO dbo.EmployeesHistory(empid, empname, department, salary, sysstart,
sysend) VALUES
(6 , 'Paul', 'Sales' , 40000.00, '2016-02-16 17:08:41', '2016-02-16 17:15:26'),
(1 , 'Sara', 'IT' , 50000.00, '2016-02-16 17:08:41', '2016-02-16 17:20:02'),
(5 , 'Sven', 'IT' , 45000.00, '2016-02-16 17:08:41', '2016-02-16 17:20:02'),
(3 , 'Judy', 'Sales' , 55000.00, '2016-02-16 17:08:41', '2016-02-16 17:28:10'),
(5 , 'Sven', 'IT' , 47250.00, '2016-02-16 17:20:02', '2016-02-16 17:28:10');
-- Enable system versioning
ALTER TABLE dbo.Employees ADD PERIOD FOR SYSTEM_TIME (sysstart, sysend);
ALTER TABLE dbo.Employees ALTER COLUMN sysstart ADD HIDDEN;
ALTER TABLE dbo.Employees ALTER COLUMN sysend ADD HIDDEN;
ALTER TABLE dbo.Employees
SET ( SYSTEM_VERSIONING = ON ( HISTORY_TABLE = dbo.EmployeesHistory ) );


-- Get the old data from the history table using for system time as of required datetime
select * from dbo.EmployeesHistory;
select sysstart, sysend from dbo.employees;
select *
from dbo.Employees for system_time as of '20160216 17:10:00';

-- for comparing the changes in different periods of time
select t2.empid, t2.empname,
		cast( (t2.salary / t1.salary - 1.0) * 100.0 as numeric(10 , 2)) as pct 
from dbo.employees for system_time as of '20160216 17:10:00' as t1
inner join dbo.Employees for system_time as of '20160216 17:25:00' as t2
on t1.empid = t2.empid
and t2.salary > t1.salary;

-- There are other subclauses like from starttime to endtime
-- Between starttime and endtime
-- contained in(starttime, endtime)


-- For the time zone
SELECT empid, empname, department, salary,
sysstart AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time' AS sysstart,
CASE
WHEN sysend = '9999-12-31 23:59:59'
THEN sysend AT TIME ZONE 'UTC'
ELSE sysend AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time'
END AS sysend
FROM dbo.Employees FOR SYSTEM_TIME ALL;


IF OBJECT_ID(N'dbo.Employees', N'U') IS NOT NULL
BEGIN
IF OBJECTPROPERTY(OBJECT_ID(N'dbo.Employees', N'U'), N'TableTemporalType') = 2
ALTER TABLE dbo.Employees SET ( SYSTEM_VERSIONING = OFF );
DROP TABLE IF EXISTS dbo.EmployeesHistory, dbo.Employees;
END;