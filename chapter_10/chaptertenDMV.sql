use TSQLV3;

-- using the dynamic view sys.dm_tran_locks to get information about the locking and everything
SELECT -- use * to explore other available attributes
request_session_id AS sid,
resource_type AS restype,
resource_database_id AS dbid,
DB_NAME(resource_database_id) AS dbname,
resource_description AS res,
resource_associated_entity_id AS resid,
request_mode AS mode,
request_status AS status
FROM sys.dm_tran_locks;

-- @@spid is a function that returns the session id
select @@SPID as sid;

-- using sys.dm_exec_connections for troubleshooting blocking
select *
from sys.dm_tran_locks;

SELECT -- use * to explore
session_id AS sid,
connect_time,
last_read,
last_write,
most_recent_sql_handle
FROM sys.dm_exec_connections
WHERE session_id IN(66, 68);

-- getting the sql batch that caused the blocking using the dynamic management view DMV
-- sys.dm_exec_sql_text
SELECT session_id, text
FROM sys.dm_exec_connections
CROSS APPLY sys.dm_exec_sql_text(most_recent_sql_handle) AS ST
WHERE session_id IN(66, 68);

select session_id, event_info
from sys.dm_exec_connections
cross apply sys.dm_exec_input_buffer(session_id, null) as IB
where session_id in (66, 68);

select distinct request_session_id as sid, event_info
from sys.dm_tran_locks
cross apply sys.dm_exec_input_buffer(request_session_id, null) as ib
where request_session_id in (66, 68);


SELECT -- use * to explore
session_id AS sid,
login_time,
host_name,
program_name,
login_name,
nt_user_name,
last_request_start_time,
last_request_end_time
FROM sys.dm_exec_sessions
WHERE session_id IN(66, 68);

SELECT -- use * to explore
session_id AS sid,
blocking_session_id,
command,
sql_handle,
database_id,
wait_type,
wait_time,
wait_resource
FROM sys.dm_exec_requests
WHERE blocking_session_id > 0;

-- to terminate a session by killing it
kill 68; -- session id