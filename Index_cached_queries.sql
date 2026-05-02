SELECT 
	d.name,
	st.text AS TSQL_Text,
	qs.execution_count,
	 qs.total_logical_reads, 
	 qs.total_physical_reads, 
	 qp.query_plan,
	 
	CAST(CAST( qs.total_worker_time AS DECIMAL)/CAST( qs.execution_count AS DECIMAL) AS bigint) as cpu_per_execution,
	CAST(CAST( qs.total_logical_reads AS DECIMAL)/CAST( qs.execution_count AS DECIMAL) AS bigint) as logical_reads_per_execution,
	CAST(CAST( qs.total_elapsed_time AS DECIMAL)/CAST( qs.execution_count AS DECIMAL) AS bigint) as elapsed_time_per_execution,
	 qs.creation_time, 
	 qs.total_worker_time AS total_cpu_time,
	 qs.max_worker_time AS max_cpu_time, 
	 qs.total_elapsed_time, 
	 qs.max_elapsed_time, 
	 qs.max_logical_reads,
	 qs.max_physical_reads,
	cp.cacheobjtype,
	cp.objtype,
	cp.size_in_bytes
FROM   sys.dm_exec_query_stats qs 
CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
INNER JOIN sys.databases d
ON st.dbid = d.database_id
INNER JOIN sys.dm_exec_cached_plans cp
ON cp.plan_handle =  qs.plan_handle
--WHERE databases.name = 'EBIDWP'
ORDER BY  qs.max_logical_reads DESC;