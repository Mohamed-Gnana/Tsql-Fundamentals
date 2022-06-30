use TSQLV3;

-- This transaction did not ask for a shared lock
-- it went through reading the changed data of the other transaction
-- it causes dirty read
-- Ex -- imagine a rollback happened to that transaction
-- That means that the value read by the reader was never commited to the database
set transaction isolation level read uncommitted;

select productid, unitprice
from production.products
where productid = 2;

-- Using read committed isolation level
-- The lowest isolation level that prevents dirty reads
-- But it has a small problem
-- The duration the reader holds the resourve is too short
-- That another transaction could happen between two reads that causes the reads in
-- small time frames to be inconsistent
set transaction isolation level read committed;

select productid, unitprice
from production.products
where productid = 2;

update production.products
set unitprice = 19.00
where productid = 2;

-- test for repeatable read isolation level
begin tran;

select productid, unitprice
from production.products
where productid = 2;

update production.products
set unitprice += 1.00
where productid = 2;

select productid, unitprice
from production.products
where productid = 2;

commit tran;


update production.products
set unitprice = 19.00
where productid = 2;


-- test for sarializable isolation level

INSERT INTO Production.Products
(productname, supplierid, categoryid,
unitprice, discontinued)
VALUES('Product ABCDE', 1, 1, 20.00, 0);

DELETE FROM Production.Products
WHERE productid > 77;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- test for snapshot isolation level

set transaction isolation level snapshot;

begin tran;

select productid, unitprice
from production.Products
where productid = 2;


select productid, unitprice
from production.products
where productid = 2;

commit tran;

select productid, unitprice
from production.products
where productid = 2;

update production.products
set unitprice = 19.00
where productid = 2;

