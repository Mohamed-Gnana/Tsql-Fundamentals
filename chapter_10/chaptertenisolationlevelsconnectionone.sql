use TSQLV3;

-- test for the read uncommitted isolation level
begin tran;

update Production.Products
set unitprice += 1.00
where productid = 2;

select productid, unitprice
from production.products
where productid = 2;

rollback tran;


-- test for the read commited isolation level
begin tran;

update Production.products
set unitprice += 1.00
where productid = 2;

select productid, unitprice
from production.products
where productid = 2;

commit tran;

-- test for the repeatable read isolation level
set transaction isolation level repeatable read;
begin tran;

select productid, unitprice
from production.products
where productid = 2;

select productid, unitprice
from production.products
where productid = 2;

commit tran;

-- test for the serilaizable isolation level
-- this one is the same as repeatable read except it add one more feature
-- it prevents future insert with the same key
-- repeatable read locks all the rows with the key you entered
-- But it can't solve the problem if during the read
-- another transaction played dirty and inserted a row with the same key

set transaction isolation level serializable;

begin tran;

SELECT productid, productname, categoryid, unitprice
FROM Production.Products
WHERE categoryid = 1;

SELECT productid, productname, categoryid, unitprice
FROM Production.Products
WHERE categoryid = 1;
COMMIT TRAN;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- test for snapshot isolation level
-- even when you don't specify the snapshot isolation level here
-- sql server still take a copy of the last committed rows to tempdb
-- since you enabled the snapshot isolation level on the database level

begin tran;

update production.products
set unitprice += 1.00
where productid = 2;

select productid, unitprice
from Production.Products
where productid = 2;

commit tran;