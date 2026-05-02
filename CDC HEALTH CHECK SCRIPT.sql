--Check if CDC is enabled at the database level
SELECT
    name AS DatabaseName,
    is_cdc_enabled
FROM sys.databases
WHERE name = DB_NAME(); 


--Check CDC-enabled tables
SELECT
    s.name AS SchemaName,
    t.name AS TableName,
    cdc.capture_instance,
    cdc.supports_net_changes,
    cdc.index_name,
    cdc.filegroup_name
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
LEFT JOIN cdc.change_tables cdc 
    ON t.object_id = cdc.source_object_id;


--Monitor CDC Capture and Cleanup Job Status
	SELECT
    j.name,
    ja.run_requested_date,
    ja.stop_execution_date,
    ja.last_executed_step_date,
    ja.run_requested_source
    --ja.current_execution_status
FROM msdb.dbo.sysjobs j
LEFT JOIN msdb.dbo.sysjobactivity ja 
    ON j.job_id = ja.job_id
WHERE j.name LIKE 'cdc%';


--Check last job run outcome:
SELECT
    j.name AS JobName,
    h.run_date,
    h.run_time,
    h.run_duration,
    h.message
FROM msdb.dbo.sysjobhistory h
JOIN msdb.dbo.sysjobs j 
    ON j.job_id = h.job_id
WHERE j.name LIKE 'cdc.%'
ORDER BY h.instance_id DESC;

select * from sys.dm_cdc_log_scan_sessions 


-- Detect CDC latency (log scanning lag)
SELECT
    sys.fn_cdc_get_max_lsn() AS MaxLSN,
    sys.fn_cdc_get_min_lsn('all') AS MinLSN,
    DATEDIFF(SECOND, cdc.lsn_time_mapping.[tran_end_time], GETDATE()) AS SecondsBehind
FROM cdc.lsn_time_mapping
ORDER BY cdc.lsn_time_mapping.tran_end_time DESC;


--Verify the job is running. last_run_outcome = 1 - success, 0 = failed
--current_execution_status IN (1=executing, 4=idle, 7=performing idle action, 2=normal job run) 
--last_run_outcome IN( 0 - LAST run failed, 1 - success, 2 - retry, 3 - cancelled)
EXEC msdb.dbo.sp_help_job @job_name = 'cdc.ctwq_capture';



--determines the exact root cause of cdc cleanup failure
EXEC msdb.dbo.sp_help_job @job_name = 'cdc.ctwq_cleanup';

EXEC msdb.dbo.sp_help_jobhistory
    @job_name = 'cdc.ctwq_cleanup',
    @mode = 'FULL';



	--The job failed.  The Job was invoked by User sam.  The last step to run was step 1 (Change Data Capture Cleanup Agent).
	--Executed as user: NK\svc. Cannot execute as the database principal because the principal "cdc" does not exist, this type of principal cannot be impersonated, or you do not have permission. [SQLSTATE 42000] (Error 15517).  NOTE: The step was retried the requested number of times (10) without succeeding.  The step failed.

	--To fix - I CREATED THE CDC USER

CREATE USER [cdc] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[cdc]
GO
ALTER AUTHORIZATION ON SCHEMA::[cdc] TO [cdc];

EXEC sp_addrolemember 'db_owner', 'cdc';

ALTER AUTHORIZATION ON SCHEMA::cdc TO dbo;


--ALTER USER [cdc] WITH LOGIN = NK\svc_cae_fpmqa;

--restart the cleanup job
EXEC sys.sp_cdc_stop_job  @job_type = 'cleanup';
EXEC sys.sp_cdc_start_job @job_type = 'cleanup';

--Check for long-running or large transactions
SELECT session_id, total_elapsed_time
FROM sys.dm_exec_requests
WHERE total_elapsed_time > 300000;

--Ensure no blocking is stopping cleanup
SELECT
    blocking_session_id, 
    session_id, 
    wait_type
    --resource_description
FROM sys.dm_exec_requests
WHERE command LIKE '%CDC%';

--ALL IN ONE CDC HEALTH CHECK
/* =====================================================================================
   CDC HEALTH CHECK SCRIPT
   Author: M365 Copilot
   Description:
   Validates the health of SQL Server Change Data Capture, including:
   - Status checks
   - Job health
   - Latency detection
   - Cleanup failures
   - Orphan user issues
   - CDC table bloat
   - Log truncation blockers
===================================================================================== */

SET NOCOUNT ON;

PRINT '===========================================';
PRINT ' CDC HEALTH CHECK ';
PRINT '===========================================';

/*-----------------------------------------------------------
  1. Check if CDC is enabled at database level
-----------------------------------------------------------*/
PRINT '1. Database-level CDC status';
SELECT 
    name AS DatabaseName,
    is_cdc_enabled
FROM sys.databases
WHERE name = DB_NAME();
PRINT ' ';

/*-----------------------------------------------------------
  2. Check CDC-enabled tables
-----------------------------------------------------------*/
PRINT '2. CDC-enabled table status';
SELECT 
    s.name AS SchemaName,
    t.name AS TableName,
    c.capture_instance,
    c.index_name,
    c.supports_net_changes,
    c.filegroup_name,
    c.create_date
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
LEFT JOIN cdc.change_tables c ON t.object_id = c.source_object_id;
PRINT ' ';

/*-----------------------------------------------------------
  3. CDC Job Status: Capture & Cleanup
-----------------------------------------------------------*/
PRINT '3. CDC SQL Agent job status';
SELECT 
    j.name AS JobName,
    ja.start_execution_date,
    ja.stop_execution_date,
    ja.last_executed_step_date,
    ja.current_execution_status,
    h.run_status AS LastRunStatus,
    h.message AS LastRunMessage
FROM msdb.dbo.sysjobs j
LEFT JOIN msdb.dbo.sysjobactivity ja ON j.job_id = ja.job_id
LEFT JOIN msdb.dbo.sysjobhistory h ON j.job_id = h.job_id
WHERE j.name LIKE 'cdc.%';
PRINT ' ';

/*-----------------------------------------------------------
  4. Capture latency detection
-----------------------------------------------------------*/
PRINT '4. CDC Latency (Seconds Behind)';
SELECT TOP 1
    sys.fn_cdc_get_max_lsn() AS MaxLSN,
    sys.fn_cdc_get_min_lsn('all') AS MinLSN,
    DATEDIFF(SECOND, t.tran_end_time, GETDATE()) AS SecondsBehind
FROM cdc.lsn_time_mapping t
ORDER BY t.tran_end_time DESC;
PRINT ' ';

/*-----------------------------------------------------------
  5. Check CDC table row counts (bloat indicator)
-----------------------------------------------------------*/
PRINT '5. Size of CDC change tables';
SELECT 
    ct.capture_instance,
    SUM(ps.row_count) AS RowsInChangeTable
FROM cdc.change_tables ct
JOIN sys.dm_db_partition_stats ps ON ct.change_table_id = ps.object_id
GROUP BY ct.capture_instance;
PRINT ' ';

/*-----------------------------------------------------------
  6. Check if log is being blocked from truncation
-----------------------------------------------------------*/
PRINT '6. Log truncation blockers (CDC-related)';
SELECT name, log_reuse_wait, log_reuse_wait_desc
FROM sys.databases
WHERE name = DB_NAME();
PRINT ' ';

/*-----------------------------------------------------------
  7. Check for orphaned CDC principal (your error)
-----------------------------------------------------------*/
PRINT '7. CDC principal exists check';
SELECT 
    dp.name AS PrincipalName,
    dp.type_desc AS PrincipalType
FROM sys.database_principals dp
WHERE dp.name = 'cdc';
PRINT ' ';

/*-----------------------------------------------------------
  8. Disk IO waits relevant to CDC log scanning
-----------------------------------------------------------*/
PRINT '8. IO Waits affecting CDC performance';
SELECT 
    wait_type, 
    wait_time_ms, 
    signal_wait_time_ms
FROM sys.dm_os_wait_stats
WHERE wait_type IN ('WRITELOG', 'LOG_RATE_GOVERNOR', 'LOG_BUFFER', 'IO_COMPLETION');
PRINT ' ';

/*-----------------------------------------------------------
  9. Long running transactions that may delay CDC
-----------------------------------------------------------*/
PRINT '9. Long running open transactions';
SELECT 
    dt.transaction_id,
    at.name AS TransactionName,
    dt.transaction_begin_time,
    DATEDIFF(MINUTE, dt.transaction_begin_time, GETDATE()) AS MinutesOpen,
    es.session_id,
    es.program_name
FROM sys.dm_tran_active_transactions dt
JOIN sys.dm_tran_session_transactions st ON dt.transaction_id = st.transaction_id
JOIN sys.dm_exec_sessions es ON st.session_id = es.session_id
LEFT JOIN sys.dm_tran_database_transactions dbt ON dt.transaction_id = dbt.transaction_id
LEFT JOIN sys.dm_tran_active_transactions at ON dt.transaction_id = at.transaction_id
WHERE dt.transaction_begin_time IS NOT NULL;
PRINT ' ';

/*-----------------------------------------------------------
  10. Final Summary Footer
-----------------------------------------------------------*/
PRINT '===========================================';
PRINT ' CDC HEALTH CHECK COMPLETE ';
PRINT '===========================================';