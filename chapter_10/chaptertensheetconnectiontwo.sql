use TSQLV3;
-- E1
select orderid, productid, unitprice, discount
from sales.OrderDetails
where orderid = 10249;


-- E2
set transaction isolation level read uncommitted;

select orderid, productid, unitprice, discount
from sales.OrderDetails
where orderid = 10249;

-- E2-2
set transaction isolation level read committed;

select orderid, productid, unitprice, discount
from sales.OrderDetails
where orderid = 10249;

-- E2-3

begin tran;

update sales.OrderDetails
set discount = 0.05
where orderid = 10249;

rollback tran;

-- E2-4

begin tran;

insert into sales.OrderDetails(orderid, productid, unitprice, qty, discount)
VALUES(10249, 2, 19.00, 10, 0.00);

rollback tran;

set transaction isolation level read committed;


-- E2-5
set transaction isolation level snapshot;

select orderid, productid, unitprice, discount
from sales.OrderDetails
where orderid = 10249;

update sales.OrderDetails
set discount = 0.00
where orderid = 10249;


-- E3

begin tran;

update production.Products
set unitprice += .5
where productid = 2;

select productid, unitprice
from production.Products
where productid = 3;

rollback tran;

-- test

begin tran;

select custid
from dbo.customers;

commit tran;
