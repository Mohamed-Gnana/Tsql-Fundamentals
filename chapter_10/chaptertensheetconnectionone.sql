use TSQLV3;
-- E1
begin tran;

update sales.OrderDetails
set discount = .05
where orderid = 10249;

rollback tran;

-- E2

begin tran;

update sales.OrderDetails
set discount = .05
where orderid = 10249;

select orderid, productid, discount, unitprice
from sales.OrderDetails
where orderid = 10249;

rollback tran;

-- E2-2

begin tran;

update sales.OrderDetails
set discount = 0.05
where orderid = 10249;

select orderid, productid, unitprice, discount
from sales.OrderDetails
where orderid = 10249;

rollback tran;

-- E2-3
set transaction isolation level repeatable read;

begin tran;

select orderid, productid, unitprice, discount
from sales.OrderDetails
where orderid = 10249;

select orderid, productid, unitprice, discount
from sales.orderdetails
where orderid = 10249;

commit tran;

-- test for the change

set transaction isolation level read uncommitted;

select orderid, productid, unitprice, discount
from sales.OrderDetails
where orderid = 10249;


-- E2-4

set transaction isolation level serializable;

begin tran;

select orderid, productid, unitprice, discount
from sales.OrderDetails
where orderid = 10249;

select orderid, productid, unitprice, discount
from sales.OrderDetails
where orderid = 10249;

commit tran;

-- test the change
set transaction isolation level read uncommitted;

select orderid, productid, unitprice, discount
from sales.OrderDetails
where orderid = 10249;

set transaction isolation level read committed;

-- E2-5

begin tran;

update sales.OrderDetails
set discount += 0.05
where orderid = 10249;

select orderid, productid, unitprice, discount
from sales.OrderDetails
where orderid = 10249;

commit tran;


-- E3

begin tran;

update Production.Products
set unitprice += .5
where productid = 3;

select productid, unitprice
from Production.Products
where productid = 2;

rollback tran;

-- test

begin tran;

alter table dbo.customers
drop column companyname;

rollback tran;