use TSQLV3;

-- set lock_timeout 5000;
set lock_timeout -1;
select productid, unitprice
from production.Products
where productid = 2;