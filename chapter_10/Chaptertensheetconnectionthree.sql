use TSQLV3;

select
	request_session_id as sid,
	resource_type as restype,
	resource_database_id as dbid,
	resource_description as res,
	(resource_associated_entity_id) as resid,
	request_mode as mode,
	request_status as status
from sys.dm_tran_locks;

select
	session_id as sid,
	connect_time,
	last_read,
	last_write,
	most_recent_sql_handle
from sys.dm_exec_connections
where session_id in (51, 53);

select
	session_id as sid,
	login_time,
	host_name,
	program_name,
	login_name,
	nt_user_name,
	last_request_start_time,
	last_request_end_time
from sys.dm_exec_sessions
where session_id in (51, 53);

select
	session_id as sid,
	blocking_session_id,
	command,
	sql_handle,
	database_id,
	wait_type,
	wait_time,
	wait_resource
from sys.dm_exec_requests
where blocking_session_id > 0;


select session_id, text
from sys.dm_exec_connections
cross apply sys.dm_exec_sql_text(most_recent_sql_handle) as ST
where session_id in (51, 53);

kill 53;


-- E2-5

alter database tsqlv3 set allow_snapshot_isolation on;

alter database tsqlv3 set allow_snapshot_isolation off;

alter database tsqlv3 set read_committed_snapshot on;