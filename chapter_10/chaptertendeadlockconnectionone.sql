use TSQLV3;
set transaction isolation level read committed;
begin tran;

update production.products
set unitprice += 1.00
where productid = 2;

select productid, unitprice, orderid
from sales.OrderDetails
where productid = 2;

commit tran;


UPDATE Production.Products
SET unitprice = 19.00
WHERE productid = 2;
UPDATE Sales.OrderDetails
SET unitprice = 19.00
WHERE productid = 2
AND orderid >= 10500;
UPDATE Sales.OrderDetails
SET unitprice = 15.20
WHERE productid = 2
AND orderid < 10500;