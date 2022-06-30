use TSQLV3;

alter database tsqlv3 set allow_snapshot_isolation on;

alter database tsqlv3 set read_committed_snapshot on;

alter database tsqlv3 set allow_snapshot_isolation off;
alter database tsqlv3 set read_committed_snapshot off;


select *
from sys.dm_tran_locks;