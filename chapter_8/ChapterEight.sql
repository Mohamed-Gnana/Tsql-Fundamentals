use TSQLV3;

drop table if exists dbo.empyearorders;
drop table if exists dbo.EmpCustOrders;
drop table if exists dbo.orders;

create table dbo.orders
(
	orderid int not null
	constraint pk_orders primary key,
	orderdate date not null
	constraint def_orderdate default(sysdatetime()),
	empid int not null,
	custid int not null
);

alter table dbo.orders
alter column custid varchar(10) not null;

-- insert values statement
insert into dbo.orders(orderid, orderdate, empid, custid) -- specifing the columns name here is optional for better control
values
	(10001, '20160101', 3, 'A');

-- also valid but with less control
insert into dbo.orders
values
	(10002, '20150101', 4, 'B');

-- since orderdate have a default value, you can ignore it like this
insert into dbo.orders(orderid, empid, custid)
values
	(10003, 5, 'C');

select orderid, orderdate, empid, custid
from dbo.orders;

-- Without specifing the column name, this time this will not work here
insert into dbo.orders
values
	(10004, 6, 'D');

-- This will fail because empid doesn't allow null and doesn't have a default value like orderdate
insert into dbo.orders(orderid, custid)
values
	(10004, 'D'); -- if empid allows null, this statement would work in this case and empid will be null

-- Enhanced insert values statement
insert into dbo.orders(orderid, orderdate, empid, custid)
values
	(10004, '20150102', 6, 'D'),
	(10005, '20150103', 7, 'E'),
	(10006, '20150104', 8, 'F'),
	(10007, '20150105', 9, 'G'),
	(10008, '20150106', 10, 'H'); -- this statement is processed as a transaction
-- if one row fails for any reason, none of the other rows will enter the table
select orderid, orderdate, empid, custid
from dbo.orders;

-- values can be used in table-value constructor like this in a derived table format
select orderid, orderdate, empid, custid
from (values
		(10004, '20150102', 6, 'D'),
		(10005, '20150103', 7, 'E'),
		(10006, '20150104', 8, 'F'),
		(10007, '20150105', 9, 'G'),
		(10008, '20150106', 10, 'H')) as O(orderid, orderdate, empid, custid);
-- insert select statement
insert into dbo.orders(orderid, orderdate, empid, custid)
select orderid, orderdate, empid, custid
from sales.Orders
where shipcountry = N'uk';

select orderid, orderdate, empid, custid
from dbo.orders;

insert into dbo.orders
select orderid, orderdate, empid, custid
from sales.orders
where shipcountry = N'usa';

select orderid, orderdate, empid, custid
from dbo.orders;

insert into dbo.orders(orderid, empid, custid)
select orderid, empid, custid
from sales.orders
where shipcountry <> N'uk'
and shipcountry <> N'usa';

select orderid, orderdate, empid, custid
from dbo.orders;

-- insert select is also considered a transaction --

truncate table dbo.orders;

select * from dbo.orders;

-- stored procedure

drop proc if exists dbo.getorders;

create proc dbo.getorders
	(@country as nvarchar(40))
as
	select orderid, orderdate, empid, custid
	from sales.orders
	where shipcountry = @country;

-- insert exec
insert into dbo.orders
exec dbo.getorders @country = N'uk';

-- select into -- is an effecient insert since it uses minimal logged operation to be much faster
drop table if exists dbo.orders;
go
select orderid, orderdate, empid, custid
into dbo.orders
from sales.orders;

-- identity property and sequence object

drop table if exists dbo.orders;
go
create table dbo.orders
(
	orderid int not null identity(1,1)
	constraint pk_orders primary key,
	orderdate date not null
	constraint def_orderdate default(sysdatetime()),
	empid int not null,
	custid varchar(10) not null
);

DROP TABLE IF EXISTS dbo.T1;
CREATE TABLE dbo.T1
(
keycol INT NOT NULL IDENTITY(1, 1)
CONSTRAINT PK_T1 PRIMARY KEY,
datacol VARCHAR(10) NOT NULL
CONSTRAINT CHK_T1_datacol CHECK(datacol LIKE '[ABCDEFGHIJKLMNOPQRSTUVWXYZ]%')
);


INSERT INTO dbo.T1(datacol) VALUES('AAAAA'),('CCCCC'),('BBBBB');

select keycol, datacol
from dbo.t1;

-- another way to get the identity column in sql server
select $identity from dbo.t1;

select datacol
from dbo.t1
where keycol in (select $identity from dbo.t1);

-- @@identity and Scope_identity()

declare @new_key as int;

insert into dbo.t1 values('AAAAAAAA');

set @new_key = SCOPE_IDENTITY()
select @new_key as [new key];
set @new_key = @@IDENTITY;
select @new_key;
select IDENT_CURRENT(N'dbo.t1');

-- limitation of identity property
-- YOu can't update it
-- if the statement failed because of the check constraint, the identity property still change
insert into dbo.t1 values('12345');
insert into dbo.t1 values('ABCDE');
select keycol, datacol
from dbo.t1;

-- to solve this problem, we use set identity insert on
set identity_insert dbo.t1 on;
go
insert into dbo.t1(keycol, datacol) values(8, 'ABCDD');
go
set identity_insert dbo.t1 off;
go
select keycol, datacol
from dbo.t1;
select IDENT_CURRENT(N'dbo.t1');

-- sequence command
create sequence dbo.myseq as int
minvalue 1
cycle;

drop table if exists dbo.t1;
go

create table dbo.t1
(
	keycol int not null
	constraint pk_t1 primary key
	constraint def_seq default(next value for dbo.myseq),
	datacol varchar(10) not null
	CONSTRAINT CHK_T1_datacol CHECK(datacol LIKE '[ABCDEFGHIJKLMNOPQRSTUVWXYZ]%')
);

INSERT INTO dbo.T1(datacol) VALUES('AAAAA'),('CCCCC'),('BBBBB');

select keycol, datacol
from dbo.t1;

drop table if exists dbo.orders;
drop table if exists dbo.t1;
drop sequence if exists dbo.myseq;

-- delete and truncate statements

use TSQLV3;
DROP TABLE IF EXISTS dbo.Orders, dbo.Customers;
CREATE TABLE dbo.Customers
(
custid INT NOT NULL,
companyname NVARCHAR(40) NOT NULL,
contactname NVARCHAR(30) NOT NULL,
contacttitle NVARCHAR(30) NOT NULL,
address NVARCHAR(60) NOT NULL,
city NVARCHAR(15) NOT NULL,
region NVARCHAR(15) NULL,
postalcode NVARCHAR(10) NULL,
country NVARCHAR(15) NOT NULL,
phone NVARCHAR(24) NOT NULL,
fax NVARCHAR(24) NULL,
CONSTRAINT PK_Customers PRIMARY KEY(custid)
);
CREATE TABLE dbo.Orders
(
orderid INT NOT NULL,
custid INT NULL,
empid INT NOT NULL,
orderdate DATE NOT NULL,
requireddate DATE NOT NULL,
shippeddate DATE NULL,
shipperid INT NOT NULL,
freight MONEY NOT NULL
CONSTRAINT DFT_Orders_freight DEFAULT(0),
shipname NVARCHAR(40) NOT NULL,
shipaddress NVARCHAR(60) NOT NULL,
shipcity NVARCHAR(15) NOT NULL,
shipregion NVARCHAR(15) NULL,
shippostalcode NVARCHAR(10) NULL,
shipcountry NVARCHAR(15) NOT NULL,
CONSTRAINT PK_Orders PRIMARY KEY(orderid),
CONSTRAINT FK_Orders_Customers FOREIGN KEY(custid)
REFERENCES dbo.Customers(custid)
on delete cascade
);
GO

INSERT INTO dbo.Customers SELECT * FROM sales.Customers;
INSERT INTO dbo.Orders SELECT * FROM Sales.Orders;

set nocount on;
delete from dbo.orders
where orderdate < '20140101';
set nocount off;
truncate table dbo.customers;
delete from dbo.orders;

select * from dbo.customers;
select * from dbo.orders order by custid;
delete from dbo.Customers where custid = 1;

-- delete join
delete from O
from dbo.orders as O
inner join dbo.Customers as C
on O.custid = C.custid
where C.country = N'usa';

-- or

delete o
from dbo.orders as o
inner join dbo.customers as c
on c.custid = o.custid
where c.country = N'uk';

-- Since delete join is nonstandard, we can use the table expressions

delete from dbo.orders
where exists (select *
				from dbo.customers as c
				where c.custid = dbo.orders.custid
				and c.country = N'france');

drop table if exists dbo.orders, dbo.customers;


-- update statement

DROP TABLE IF EXISTS dbo.OrderDetails, dbo.Orders;
CREATE TABLE dbo.Orders
(
orderid INT NOT NULL,
custid INT NULL,
empid INT NOT NULL,
orderdate DATE NOT NULL,
requireddate DATE NOT NULL,
shippeddate DATE NULL,
shipperid INT NOT NULL,
freight MONEY NOT NULL
CONSTRAINT DFT_Orders_freight DEFAULT(0),
shipname NVARCHAR(40) NOT NULL,
shipaddress NVARCHAR(60) NOT NULL,
shipcity NVARCHAR(15) NOT NULL,
shipregion NVARCHAR(15) NULL,
shippostalcode NVARCHAR(10) NULL,
shipcountry NVARCHAR(15) NOT NULL,
CONSTRAINT PK_Orders PRIMARY KEY(orderid)
);
CREATE TABLE dbo.OrderDetails
(
orderid INT NOT NULL,
productid INT NOT NULL,
unitprice MONEY NOT NULL
CONSTRAINT DFT_OrderDetails_unitprice DEFAULT(0),
qty SMALLINT NOT NULL
CONSTRAINT DFT_OrderDetails_qty DEFAULT(1),
discount NUMERIC(4, 3) NOT NULL
CONSTRAINT DFT_OrderDetails_discount DEFAULT(0),
CONSTRAINT PK_OrderDetails PRIMARY KEY(orderid, productid),
CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY(orderid)
REFERENCES dbo.Orders(orderid),
CONSTRAINT CHK_discount CHECK (discount BETWEEN 0 AND 1),
CONSTRAINT CHK_qty CHECK (qty > 0),
CONSTRAINT CHK_unitprice CHECK (unitprice >= 0)
);
GO
INSERT INTO dbo.Orders SELECT * FROM Sales.Orders;
INSERT INTO dbo.OrderDetails SELECT * FROM Sales.OrderDetails;

-- update statement that can change the value of a subset of rows in a table
select productid, discount
from dbo.OrderDetails
where productid = 51;
update dbo.OrderDetails
set discount += 0.05
where productid = 51;
select productid, discount
from dbo.OrderDetails
where productid = 51;

-- update join
update OD
set OD.discount += .05
from dbo.OrderDetails as od
inner join dbo.orders as o
on o.orderid = od.orderid
where o.custid = 1;

-- using table expression to turn into standard
update dbo.OrderDetails
set discount += .05
where exists( select *
				from dbo.orders as o
				where o.orderid = dbo.OrderDetails.orderid
				and o.custid = 1);

-- assignment update --> used when you don't like using identity and sequence
-- it saves you the time to use update then select statement
drop table if exists dbo.mysequences;
go
create table dbo.mysequences
(
	id varchar(10) not null
	constraint pk_sequences primary key,
	val int not null
);
go
insert into dbo.mysequences(id, val)
values ('seq1', 1);

declare @myvar as int;
update dbo.mysequences
set @myvar = val += 1
where id = 'seq1';
select @myvar;

drop table if exists dbo.mysequences;

-- merging 
DROP TABLE IF EXISTS dbo.Customers, dbo.CustomersStage;
GO
CREATE TABLE dbo.Customers
(
custid INT NOT NULL,
companyname VARCHAR(25) NOT NULL,
phone VARCHAR(20) NOT NULL,
address VARCHAR(50) NOT NULL,
CONSTRAINT PK_Customers PRIMARY KEY(custid)
);
INSERT INTO dbo.Customers(custid, companyname, phone, address)
VALUES
(1, 'cust 1', '(111) 111-1111', 'address 1'),
(2, 'cust 2', '(222) 222-2222', 'address 2'),
(3, 'cust 3', '(333) 333-3333', 'address 3'),
(4, 'cust 4', '(444) 444-4444', 'address 4'),
(5, 'cust 5', '(555) 555-5555', 'address 5');
CREATE TABLE dbo.CustomersStage
(
custid INT NOT NULL,
companyname VARCHAR(25) NOT NULL,
phone VARCHAR(20) NOT NULL,
address VARCHAR(50) NOT NULL,
CONSTRAINT PK_CustomersStage PRIMARY KEY(custid)
);
INSERT INTO dbo.CustomersStage(custid, companyname, phone, address)
VALUES
(2, 'AAAAA', '(222) 222-2222', 'address 2'),
(3, 'cust 3', '(333) 333-3333', 'address 3'),
(5, 'BBBBB', 'CCCCC', 'DDDDD'),
(6, 'cust 6 (new)', '(666) 666-6666', 'address 6'),
(7, 'cust 7 (new)', '(777) 777-7777', 'address 7');

SELECT * FROM dbo.Customers;
SELECT * FROM dbo.CustomersStage;

-- merge statement
merge dbo.customers as tgt
using dbo.customersstage as src
on tgt.custid = src.custid
when matched then
	update set
		TGT.companyname = SRC.companyname,
		TGT.phone = SRC.phone,
		TGT.address = SRC.address
when not matched then
	insert (custid, companyname, phone, address)
	values (src.custid, src.companyname, src.phone, src.address);
go
select * from dbo.Customers;


--- Data modification through table expressions
-- using common table expressions
with c as 
(
	select custid, OD.orderid, productid, discount, discount + .05 as newdiscount
	from dbo.OrderDetails as OD
	inner join dbo.orders as o
	on OD.orderid = o.orderid
	where o.custid = 1
)
update c
set c.discount = c.newdiscount;

-- using derived table

update c
set c.discount = c.newdiscount
from (select custid, od.orderid, productid, discount, discount + .05 as newdiscount
		from dbo.OrderDetails as od
		inner join dbo.orders as o
		on od.orderid = o.orderid
		where custid = 1) as c;

drop table if exists dbo.orders;
drop table if exists dbo.OrderDetails;