use tsqlv3;

begin transaction
update Production.Products
set unitprice += 1.0
where productid = 2;
rollback tran;
commit tran;