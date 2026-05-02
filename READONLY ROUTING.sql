
--Validate Routing Behavior --check which replica you're connected
SELECT
    ar.replica_server_name,
    ars.role_desc,
    ars.connected_state_desc,
    ars.synchronization_health_desc
FROM sys.availability_replicas ar
JOIN sys.dm_hadr_availability_replica_states ars
    ON ar.replica_id = ars.replica_id
WHERE ars.is_local = 1;


--Verify Routing List
SELECT * FROM sys.availability_read_only_routing_lists;


--Check Replica Readability
SELECT replica_server_name, secondary_role_allow_connections
FROM sys.availability_replicas;


--Validate Connection String - Ensure it includes:
------------ApplicationIntent=ReadOnly------------------------

--Check Listener Configuration
SELECT * FROM sys.availability_group_listeners;


--Test Connection String from Application
---------------------------------------------------
--Server=YourListenerName;Database=YourDB;ApplicationIntent=ReadOnly;MultiSubnetFailover=True;
---------------------------------------------------


