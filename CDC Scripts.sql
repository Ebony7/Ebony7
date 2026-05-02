
--disable change Tracking on Table
--USE [CTWQ]
--GO
--ALTER TABLE [dbo].[AB] DISABLE CHANGE_TRACKING 
--GO


--disable CT on Table and capture instance
--EXEC sys.sp_cdc_disable_table  
--    @source_schema = N'dbo',  
--    @source_name   = N'DB',  
--    @capture_instance = N'dbo_DB';


--	--disable CT on database
	USE CTWQ
--	EXEC sys.sp_cdc_disable_db;


--	-- Enable CDC on database
--EXEC sys.sp_cdc_enable_db;
--GO


---- Enable CDC on table with specific columns to track
--EXEC sys.sp_cdc_enable_table
--    @source_schema = N'dbo',
--    @source_name = N'FL',
--    @role_name = NULL,
--   -- @captured_column_list = 'EmployeeID, FirstName, LastName, Salary'
--    @supports_net_changes = 1  ---if the column changes frequenlty, it will only record the change of the --last one
----@filegroup_name = N'Primary';
--GO

---- Enable CDC on table with specific columns to track
--EXEC sys.sp_cdc_enable_table
--    @source_schema = N'dbo',
--    @source_name = N'DB',
--    @role_name = NULL,
--   -- @captured_column_list = 'EmployeeID, FirstName, LastName, Salary'
--    @supports_net_changes = 1  ---if the column changes frequenlty, it will only record the change of the --last one
----@filegroup_name = N'Primary';
--GO

---- Enable CDC on table with specific columns to track
--EXEC sys.sp_cdc_enable_table
--    @source_schema = N'dbo',
--    @source_name = N'AB',
--    @role_name = NULL,
--   -- @captured_column_list = 'EmployeeID, FirstName, LastName, Salary'
--    @supports_net_changes = 1  ---if the column changes frequenlty, it will only record the change of the --last one
----@filegroup_name = N'Primary';
--GO

/* Result: it creates 2 agent jobs for cdc capture and cleanup
Update mask evaluation will be disabled in net_changes_function because the CLR configuration option is disabled.
Job 'cdc.TestCDCDB_capture' started successfully.
Job 'cdc.TestCDCDB_cleanup' started successfully.
*/

/* -start capture job if not already running
EXEC sp_MScdc_capture_job
-- This statement will remain in status "Executing query..."
-- Note that cancelling the execution in query window won't stop the actual job
-- Call sp_replflush to release the full logreader context:
exec sp_replflush
go */

--insert records
--INSERT INTO dbo.Employee (EmployeeID, FirstName, LastName, Salary)
--VALUES 
--    (1, 'John', 'Doe', 60000),
--    (2, 'Jane', 'Smith', 75000);
--GO

--select * from msdb.dbo.cdc_jobs
--SELECT name, is_cdc_enabled FROM sys.databases;
----SELECT name FROM sys.databases WHERE name = 'db_name';

--what table/DB is tracked
select name, is_cdc_enabled from sys.databases where name = 'CTWQ'
select name, is_tracked_by_cdc from sys.tables


--Query the CT info on Table
SELECT
    s.name AS SchemaName,
    t.name AS TableName,
    c.capture_instance,
    c.start_lsn,
    c.end_lsn
FROM 
    cdc.change_tables c
    INNER JOIN sys.tables t ON c.object_id = t.object_id
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id;


--monitor the tables
SELECT * FROM cdc.change_tables;




select * from sys.dm_cdc_log_scan_sessions

--UPDATE Employee SET salary = '100000.000' WHERE EmployeeID = 2
--go


--verify changes captured by cdc
--DECLARE @from_lsn binary(10), @to_lsn binary(10);

--SET @from_lsn = sys.fn_cdc_get_min_lsn('dbo_Employee');
--SET @to_lsn = sys.fn_cdc_get_max_lsn();
--SELECT * 
--FROM cdc.fn_cdc_get_all_changes_dbo_Employee(@from_lsn, @to_lsn, 'all');


/*
Displays metadata information and the actual change
__$start_lsn            __$end_lsn  __$seqval               __$operation  __$update_mask  ID  c1
0x00000028000001220003  NULL        0x00000028000001220002  2             0x03            3   row three
0x00000028000001250003  NULL        0x00000028000001250002  3             0x02            2   row two

__$operation column represents the operation that is associated with the change;
Delete = 1
Insert = 2
Update(old value) = 3
Update (new value) = 4
*/


--Modify cdc job to be alwayson aware for failover scenarios
--IF sys.fn_hadr_is_primary_replica('TestCDCDB') <> 1
--BEGIN
--    RAISERROR('Not the primary replica. CDC job step skipped.', 10, 1) WITH NOWAIT;
--    RETURN;
--END


--confirm creation of cdc jobs
--EXEC sys.sp_cdc_help_jobs;


	-- for Always on --Create script on Primary to generate the job
--DECLARE @Database NVARCHAR(255) = 'TestCDCDB' /* Your DATABASE NAME goes here */
--, @Fields NVARCHAR(200) = '[job_type], [job_id], [maxtrans], [maxscans], [continuous], [pollinginterval], [retention], [threshold]'
-- , @SQL NVARCHAR(1000);
--SET @SQL = 'SET NOCOUNT ON;
--DECLARE @Insert VARCHAR(MAX);
--SELECT @Insert = ISNULL(@Insert + '' UNION '', ''INSERT INTO msdb.dbo.cdc_jobs([database_id], '
-- + @Fields + ')'') + CHAR(13) + CHAR(10) + ''SELECT DB_ID('''''  + @Database + '''''),'' + '
--+ REPLACE(REPLACE(REPLACE(@Fields, ',', ' + '', '' + '), '[', ''''''''' + CAST('),']',' AS VARCHAR(max)) + ''''''''')
-- + ' FROM msdb.dbo.cdc_jobs WHERE database_id = DB_ID(''' + @Database + ''');
--PRINT @Insert';
--EXEC sp_executesql @SQL;


--Create cdc_job table in msdb
--CREATE TABLE [dbo].[cdc_jobs] (
--    [database_id] [int] NOT NULL,
--    [job_type] [nvarchar](20) NOT NULL,
--    [job_id] [uniqueidentifier] NULL,
--    [maxtrans] [int] NULL,
--    [maxscans] [int] NULL,
--    [continuous] [bit] NULL,
--    [pollinginterval] [bigint] NULL,
--    [retention] [bigint] NULL,
--    [threshold] [bigint] NULL,
--    PRIMARY KEY CLUSTERED (
--        [database_id] ASC, 
--        [job_type] ASC
--    )
--    WITH (
--        PAD_INDEX = OFF, 
--        STATISTICS_NORECOMPUTE = OFF, 
--        IGNORE_DUP_KEY = OFF, 
--        ALLOW_ROW_LOCKS = ON, 
--        ALLOW_PAGE_LOCKS = ON
--    ) ON [PRIMARY]
--) ON [PRIMARY];



-- Run the Scripted capture and cleanup job in secondary
--USE [msdb]
--GO
-----

-- Run those create-job scripts manually on Secondary ---this is an example. save the output from above
--INSERT INTO msdb.dbo.cdc_jobs([database_id], [job_type], [job_id], [maxtrans], [maxscans], [continuous], [pollinginterval], [retention], [threshold])
--SELECT DB_ID('TestCDCDB'),'capture', 'E26C7C86-B831-464F-84DD-6289C280AA6E', '500', '10', '1', '5', '0', '0' UNION 
--SELECT DB_ID('TestCDCDB'),'cleanup', 'A387AC7B-76CD-426B-B19E-5914631E4937', '0', '0', '0', '0', '4320', '5000'



--create the cdc_jobs_view system view
--CREATE VIEW dbo.cdc_jobs_view AS
--SELECT
--  [database_id],
--  [job_type],
--  [job_id],
--  [maxtrans],
--  [maxscans],
--  [continuous],
--  [pollinginterval],
--  [retention],
--  [threshold]
--FROM dbo.cdc_jobs;



--update msdb job in secondary
--UPDATE c
--SET c.job_id = s.job_id
--FROM msdb.dbo.sysjobs s
--JOIN msdb.dbo.cdc_jobs c
--ON s.name = 'cdc.' + DB_NAME(c.database_id) + '_' + c.job_type
--WHERE DB_NAME(c.database_id) = 'CTWQ';





----insert
--INSERT INTO dbo.Employee (EmployeeID, FirstName, LastName, Salary)
--VALUES 
--    (3, 'Smith', 'Dee', 90000),
--    (4, 'Oscar', 'Paul', 15000);
--G

select * from sys.dm_cdc_log_scan_sessions



-- Cleanup:

---- Disable CDC on table 
--EXEC sys.sp_cdc_disable_table
--    @source_schema = N'dbo',
--    @source_name = N'Employee',
--    @capture_instance = N'dbo_Employee'
--	GO

---- disable database for CDC
--Use [TestCDCDB]
--Exec sys.sp_cdc_disable_db
--Go

--Use master
--Go
--Drop database [TestCDCDB]
--Go



----for databaricks permission
--GRANT VIEW DEFINITION TO svc_azuredf;
--GRANT VIEW DATABASE STATE TO svc_azuredf;
--GRANT SELECT, UPDATE ON OBJECT::dbo.lakeflowCaptureInstanceInfo_1_1 TO svc_azuredf;
--GRANT SELECT ON SCHEMA::dbo TO svc_azuredf;
--GRANT SELECT, INSERT ON SCHEMA::cdc TO svc_azuredf;
--GRANT SELECT ON SCHEMA::dbo TO svc_azuredf;
--GRANT EXECUTE ON OBJECT::dbo.lakeflowMergeCaptureInstances_1_1 TO svc_azuredf;
--GRANT EXECUTE ON OBJECT::dbo.lakeflowDisableOldCaptureInstance_1_1 TO svc_azuredf;
--GRANT EXECUTE ON OBJECT::dbo.lakeflowMergeCaptureInstances_1_1 TO svc_azuredf;
--/* the currentUser must have DBO permission */
--GRANT IMPERSONATE ON USER::currentUser TO svc_azuredf;






------ Enable CDC on table with specific columns to track
--EXEC sys.sp_cdc_enable_table
--    @source_schema = N'dbo',
--    @source_name = N'DH',
--    @role_name = NULL,
--   -- @captured_column_list = 'EmployeeID, FirstName, LastName, Salary'
--    @supports_net_changes = 1  ---if the column changes frequenlty, it will only record the change of the --last one
----@filegroup_name = N'Primary';
--GO

------ Enable CDC on table with specific columns to track
--EXEC sys.sp_cdc_enable_table
--    @source_schema = N'dbo',
--    @source_name = N'FH',
--    @role_name = NULL,
--   -- @captured_column_list = 'EmployeeID, FirstName, LastName, Salary'
--    @supports_net_changes = 1  ---if the column changes frequenlty, it will only record the change of the --last one
----@filegroup_name = N'Primary';
--GO


------ Enable CDC on table with specific columns to track
--EXEC sys.sp_cdc_enable_table
--    @source_schema = N'dbo',
--    @source_name = N'OT',
--    @role_name = NULL,
--   -- @captured_column_list = 'EmployeeID, FirstName, LastName, Salary'
--    @supports_net_changes = 1  ---if the column changes frequenlty, it will only record the change of the --last one
----@filegroup_name = N'Primary';
--GO



--select name, is_cdc_enabled from sys.databases;
select name, is_cdc_enabled from sys.databases where name ='[CTWQ]'










select name, is_tracked_by_cdc from sys.tables

SELECT name, is_tracked_by_cdc FROM sys.tables WHERE name = 'OX';