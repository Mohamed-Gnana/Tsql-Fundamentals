
use TSQLV3;

-- Sheet 8)

-- E1)
DROP TABLE IF EXISTS dbo.Customers;
CREATE TABLE dbo.Customers
(
custid INT NOT NULL PRIMARY KEY,
companyname NVARCHAR(40) NOT NULL,
country NVARCHAR(15) NOT NULL,
region NVARCHAR(15) NULL,
city NVARCHAR(15) NOT NULL
);

-- E1-1)
insert into dbo.Customers(custid, companyname, country, region, city)
values
	(100, N'Coho Winery', N'USA', N'WA', N'Redmond');

-- E 1-2)
insert into dbo.customers(custid, companyname, country, region, city)
select custid, companyname, country, region, city
from sales.Customers
where exists( select *
				from sales.Orders as o
				where sales.Customers.custid = o.custid);
-- E 1-3)
select *
into dbo.orders
from sales.orders
where orderdate >= '20130101' and orderdate < '20160101';

-- E2)
delete from dbo.orders
output deleted.orderid, deleted.orderdate
where orderdate < '20130801';

-- E3)
delete o
from dbo.orders as o
inner join dbo.Customers as c
on o.custid = c.custid
where c.custid = 1;

-- another solution
delete from dbo.orders
where exists( select *
				from dbo.Customers as c
				where orders.custid = c.custid
				and c.custid = 1);

-- E4)
update dbo.Customers
set region = N'<None>'
output deleted.custid,
		deleted.region as oldregion,
		inserted.region as newregion
where region is null;

-- E5)
update o
set o.shipcountry = c.country,
	o.shipregion = c.region,
	o.shipcity = c.city
output deleted.custid, inserted.shipcity, inserted.shipregion, inserted.shipcountry
from dbo.orders as o
inner join dbo.Customers as c
on o.custid = c.custid
where c.country = N'uk';

-- E6)
USE TSQLV3;
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

-- solution
alter table dbo.orderdetails
drop constraint fk_orderdetails_orders;
truncate table dbo.orders;
truncate table dbo.orderdetails;
alter table dbo.orderdetails
add constraint fk_orderdetails_orders
foreign key(orderid)
references dbo.orders(orderid);

select * from dbo.orders;
select * from dbo.OrderDetails;

DROP TABLE IF EXISTS dbo.OrderDetails, dbo.Orders, dbo.Customers;