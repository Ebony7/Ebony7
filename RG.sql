/*---------------------------
Controlling TempDB Resources with Resource Governor in SQL Server 2025
------------------------------------------------------------------*/


-- Create a workload group for ETL sessions and cap it at 15% of tempdb
CREATE WORKLOAD GROUP etl_group
WITH (GROUP_MAX_TEMPDB_DATA_PERCENT = 15);

-- Classify sessions whose application name is 'DataStage' into that group
USE master;
GO
CREATE OR ALTER FUNCTION dbo.rg_classifier()
RETURNS sysname WITH SCHEMABINDING AS
BEGIN
    RETURN (CASE WHEN APP_NAME() = 'DataStage'
                 THEN 'etl_group'
                 ELSE 'default'
            END);
END;
GO

ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = dbo.rg_classifier);


-- Cap all remaining sessions (default group) at 20 GB
ALTER WORKLOAD GROUP default
    WITH (GROUP_MAX_TEMPDB_DATA_MB = 20480);

-- Turn the new rules on
ALTER RESOURCE GOVERNOR RECONFIGURE;


SELECT name,
       group_max_tempdb_data_mb,
       group_max_tempdb_data_percent,
       tempdb_data_space_kb,
       total_tempdb_data_limit_violation_count
FROM   sys.dm_resource_governor_workload_groups;

SELECT SERVERPROPERTY('ResourceVersion') AS ResourceDB_Version,
       SERVERPROPERTY('ResourceLastUpdateDateTime') AS ResourceDB_LastUpdate;