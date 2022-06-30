use TSQLV3;

-- user defined functions -- one of the three ways to define a routine
-- encapsulate the logic to calculate something
-- don't allow side effects like what the rand fucntion do from choosing a seed

drop function if exists dbo.getage;
go
create function dbo.getage
(
	@birthdate as date,
	@eventdate as date
) returns int
as
begin
	return
		datediff(year, @birthdate, @eventdate)
		- case when (100 * month(@eventdate) + day(@eventdate)
		< 100 * month(@birthdate) + day(@birthdate))
		then 1 else 0
		end;
end;
go
select empid, firstname, lastname, birthdate, dbo.getage(birthdate, sysdatetime()) as age
from hr.Employees;

-- The second form of routines are the stored procedures
-- They encapsulate your code and allow side effects
-- Better at security measures and performance
-- used for chashed data

drop proc if exists dbo.getcustomerorders;
go
create proc dbo.getcustomerorders
(
	@custid as int,
	@fromdate as datetime = '19000101',
	@todate as datetime = '99991231',
	@numrows as int output
)
as
set nocount on;
select orderid, custid, empid, orderdate
from sales.orders
where custid = @custid
and orderdate >= @fromdate
and orderdate < @todate;
set @numrows = @@ROWCOUNT
go

declare @rc as int;
Exec dbo.getcustomerorders
	@custid = 1,
	@fromdate = '20140101',
	@todate = '20150101',
	@numrows = @rc output;
select @rc as rownumber;

-- Triggers -- a special type of stored procedure That can't be run explictly
-- It is attached to an event like insert and delete and so on

drop table if exists dbo.t1, dbo.audit_t1;

create table dbo.t1
(
	keycol int not null primary key,
	datacol varchar(10) not null
);
create table dbo.audit_t1
(
	audit_lsn int not null identity primary key,
	dt datetime2(3) not null default(sysdatetime()),
	login_name sysname not null default(original_login()),
	keycol int not null,
	datacol varchar(10) not null
);
go
create trigger trg_t1_audit on dbo.t1 after insert
as 
set nocount on;
insert into dbo.audit_t1(keycol, datacol)
select keycol, datacol from inserted
go

INSERT INTO dbo.T1(keycol, datacol) VALUES(10, 'a');
INSERT INTO dbo.T1(keycol, datacol) VALUES(30, 'x');
INSERT INTO dbo.T1(keycol, datacol) VALUES(20, 'g');

select audit_lsn, dt, login_name, keycol, datacol
from dbo.audit_t1;
go
create trigger trg_t1_audit2 on dbo.t1 after delete
as
insert into dbo.audit_t1(keycol, datacol)
select keycol, datacol from deleted;
go

delete from dbo.t1
where keycol = 10;

select audit_lsn, dt, login_name, keycol, datacol
from dbo.audit_t1;
go
create trigger trg_t1_audit3 on dbo.t1 after update
as
insert into dbo.audit_t1(keycol, datacol)
select keycol, datacol from deleted;
go
update dbo.t1
set datacol = 'y'
where keycol = 30;
select audit_lsn, dt, login_name, keycol, datacol
from dbo.audit_t1;

drop table dbo.t1, dbo.audit_t1;