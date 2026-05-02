select auth_scheme from sys.dm_exec_connections where session_id = @@SPID;

select auth_scheme, net_transport, client_net_address
from sys.dm_exec_connections
where session_id = @@SPID;


select * from sys.dm_server_services