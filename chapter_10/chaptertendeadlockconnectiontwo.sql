use TSQLV3;
set transaction isolation level read committed;
begin tran;

update sales.OrderDetails
set unitprice += 1.00
where productid = 2;

select productid, unitprice
from production.products
where productid = 2;

commit tran;

select *
from sys.dm_tran_locks;