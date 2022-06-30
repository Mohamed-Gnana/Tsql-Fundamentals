use TSQLV3;

IF OBJECT_ID(N'dbo.departments', N'U') IS NOT NULL
BEGIN
IF OBJECTPROPERTY(OBJECT_ID(N'dbo.departments', N'U'), N'TableTemporalType') = 2
ALTER TABLE dbo.departments SET ( SYSTEM_VERSIONING = OFF );
DROP TABLE IF EXISTS dbo.departmentsHistory, dbo.departments;
END;
-- Exercise
-- E 1-1)

drop table if exists dbo.departments;
go
create table dbo.departments
(
	deptid int not null
	constraint pk_depts primary key nonclustered,
	deptname varchar(25) not null,
	mgrid int not null,
	validfrom datetime2(0)
	generated always as row start hidden not null
	constraint def_validfrom default('19000101'),
	validto datetime2(0)
	generated always as row end hidden not null
	constraint def_validto default('99991231 23:59:59'),
	period for system_time(validfrom, validto),
	index ix_depts clustered(deptid, validfrom, validto)
) with (system_versioning = on( history_table = dbo.departmentshistory));

-- E 1-2)
-- Done --

-- E2)
begin tran;
declare @p1 as datetime2 = sysdatetime();
select @p1;
insert into dbo.departments(deptid, deptname, mgrid)
values
	(1, 'HR', 7),
	(2, 'IT', 5),
	(3, 'Sales', 11),
	(4, 'Marketing', 13);
commit tran;

select deptid, deptname, mgrid, validfrom, validto
from dbo.departments;

-- Done--
begin tran;
declare @p2 as datetime2 = sysdatetime();
select @p1, @p2;
update dbo.departments
set deptname = 'Sales and Marketing'
where deptid = 3;
delete from dbo.departments
where deptid = 4;
select deptid, deptname, mgrid, validfrom, validto
from dbo.departments;
select *
from dbo.departmentshistory;
commit tran;

-- done
-- E 2-3)
begin tran
declare @update_p2 as datetime2 = sysdatetime();
update dbo.departments
set mgrid = 13
where deptid = 3;
select deptid, deptname, mgrid, validfrom, validto
from dbo.departments;
select *
from dbo.departmentshistory;
commit tran;
-- E3)
-- E 3-1)
select *
from dbo.departments;

-- E 3-2)
select @p1, @p2, @update_p2;
select *
from dbo.departments for system_time from @p2 to @update_p2;

-- E4)
if object_id(N'dbo.departments', N'U') is not null
begin
if OBJECTPROPERTY(object_id(N'dbo.departments', N'U'), N'tabletemporaltype') = 2
alter table dbo.departments set(system_versioning = off);
drop table if exists dbo.departmentshistory, dbo.departments;
end;

