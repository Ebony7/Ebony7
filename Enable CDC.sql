USE master;
 
GO
 
CREATE DATABASE TestCDCDB;
 
GO
 
-- Add the database to Always On availability group manually if needed
 
-- via SSMS or T-SQL
 
USE TestCDCDB;
 
GO
 
CREATE TABLE dbo.Employee (
 
EmployeeID INT PRIMARY KEY,
 
FirstName NVARCHAR(100),
 
LastName NVARCHAR(100),
 
Salary DECIMAL(10, 2),
 
ModifiedDate DATETIME DEFAULT GETDATE()
 
);
 
GO
 
-- Enable CDC on database
 
EXEC sys.sp_cdc_enable_db;
 
GO
 
-- Enable CDC on table with specific columns to track
 
EXEC sys.sp_cdc_enable_table
 
@source_schema = N'dbo',
 
@source_name = N'Employee',
 
@role_name = NULL,
 
@captured_column_list = 'EmployeeID, FirstName, LastName, Salary'
 
-- @supports_net_changes = 1  ---if the column changes frequenlty, it will only record the change of the last one
 
--@filegroup_name = N'Primary';
 
GO
 
/* Result: it creates 2 agent jobs for cdc capture and cleanup
 
Update mask evaluation will be disabled in net_changes_function because the CLR configuration option is disabled.
 
Job 'cdc.TestCDCDB_capture' started successfully.
 
Job 'cdc.TestCDCDB_cleanup' started successfully.*/
 
/* -start capture job if not already running
 
EXEC sp_MScdc_capture_job
 
-- This statement will remain in status "Executing query..."
 
-- Note that cancelling the execution in query window won't stop the actual job
 
-- Call sp_replflush to release the full logreader context:
 
exec sp_replflush
 
go */
 
--insert records
 
INSERT INTO dbo.Employee (EmployeeID, FirstName, LastName, Salary)
 
VALUES
 
(1, 'John', 'Doe', 60000),
 
(2, 'Jane', 'Smith', 75000);
 
GO
 
 --check cdc jobs
select * from msdb.dbo.cdc_jobs
 
SELECT name, is_cdc_enabled FROM sys.databases;
 
--SELECT name FROM sys.databases WHERE name = 'db_name';
 
/*
 
UPDATE Employee SET salary = '100000.000' WHERE EmployeeID = 4
 
go
 
*/
 
--verify changes captured by cdc
 
DECLARE @from_lsn binary(10), @to_lsn binary(10);
 
SET @from_lsn = sys.fn_cdc_get_min_lsn('dbo.AB');
 
SET @to_lsn = sys.fn_cdc_get_max_lsn();
 
SELECT *
 
FROM cdc.fn_cdc_get_all_changes_dbo_AB(@from_lsn, @to_lsn, 'all');
 
-- take a look at the tracking table:
 
select * from [cdc].[dbo_DB_CT]
select * from [cdc].[dbo_DB_CT]
 
SELECT * FROM cdc.change_tables
 
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
 

 --verify cdc jobs exist
EXEC sys.sp_cdc_help_jobs;
 

 -- Create script on Primary to generate the job
/*
 
DECLARE @Database NVARCHAR(255) = 'CDC-Test' /* Your DATABASE NAME goes here */
 
, @Fields NVARCHAR(200) = '[job_type], [job_id], [maxtrans], [maxscans], [continuous], [pollinginterval], [retention], [threshold]'
 
, @SQL NVARCHAR(1000);
 
SET @SQL = 'SET NOCOUNT ON;
 
DECLARE @Insert VARCHAR(MAX);
 
SELECT @Insert = ISNULL(@Insert + '' UNION '', ''INSERT INTO msdb.dbo.cdc_jobs([database_id], '
 
@Fields + ')'') + CHAR(13) + CHAR(10) + ''SELECT DB_ID('''''  + @Database + '''''),'' + '
 
REPLACE(REPLACE(REPLACE(@Fields, ',', ' + '', '' + '), '[', ''''''''' + CAST('),']',' AS VARCHAR(max)) + ''''''''')
 
' FROM msdb.dbo.cdc_jobs WHERE database_id = DB_ID(''' + @Database + ''');
 
 
PRINT @Insert';
 
EXEC sp_executesql @SQL;
 
*/
 
--Modify cdc job to be alwayson aware for failover scenarios
 
IF sys.fn_hadr_is_primary_replica('TestCDCDB') <> 1
 
BEGIN
 
RAISERROR('Not the primary replica. CDC job step skipped.', 10, 1) WITH NOWAIT;
 
RETURN;
 
END
 
-- Script the capture and cleanup job created
 
-- Run those create-job scripts manually on Secondary
 
-- Set job to "Disabled" using SQL Agent settings
 
--update msdb job in secondary
 
UPDATE c
 
SET c.job_id = s.job_id
 
FROM msdb.dbo.sysjobs s
 
JOIN msdb.dbo.cdc_jobs c
 
ON s.name = 'cdc.' + DB_NAME(c.database_id) + '_' + c.job_type
 
WHERE DB_NAME(c.database_id) = 'Testcdcdb';
 
--insert
 
INSERT INTO dbo.Employee (EmployeeID, FirstName, LastName, Salary)
 
VALUES
 
(3, 'Smith', 'Dee', 90000),
 
(4, 'Oscar', 'Paul', 15000);
 
GO
 
--what table/DB is tracked
 
select name, is_cdc_enabled from sys.databases where name = '[CTWQ_DataBricks_Testing]'
 
select name, is_tracked_by_cdc from sys.tables
 

-- Cleanup:
 
-- Disable CDC on table
 
EXEC sys.sp_cdc_disable_table
 
@source_schema = N'dbo',
 
@source_name = N'Employee',
 
@capture_instance = N'dbo_Employee'
 
GO
 



-- disable database for CDC
 
Use [TestCDCDB]
 
Exec sys.sp_cdc_disable_db
 
Go
 
Use master
 
Go
 
Drop database [TestCDCDB]
 
Go


Update [dbo].[AB]
set 