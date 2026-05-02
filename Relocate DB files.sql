

/*Move the following databases to G: Create new folder “DataFiles” in G in both the servers and move the DBs.
	LoyaltyMigration
*/


--Step 1 Get file location : 


SELECT name, physical_name AS current_file_location
FROM sys.master_files where name in ('LoyaltyMigration')

-- Step 2 Create folder datafile in G drive



--Step 3: Remove DBs  from primary AG . Run on primary 


USE [master]

GO
ALTER AVAILABILITY GROUP [MIAPETLSQL]
REMOVE DATABASE [LoyaltyMigration];

GO

--STEP 4: TAKE FULL BACKUP

BACKUP DATABASE [APPNKP] TO  DISK = N'E:\APPNKP.BAK' WITH NOFORMAT, NOINIT,  NAME = N'APPNKP-Full Database Backup',
SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10
GO


--Step 5 - Dettach DBs

USE [master]
GO
ALTER DATABASE [Amis] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
USE [master]
GO
EXEC master.dbo.sp_detach_db @dbname = N'LoyaltyMigration'
GO



-- Step 6 --Go physically copy your file and move it to G drive


--STEP 7: MODIFY FILE LOCATION
USE MASTER
GO
ALTER DATABASE APPNKP   
MODIFY FILE (NAME = APPNKP,   
FILENAME = 'I:\data\APPNKP.mdf')


--STEP 8:  Verify datafile resides in the new drive letter

SELECT name, physical_name AS current_file_location
FROM sys.master_files where name in (
	'APPNKP'
)


--STEP 9: SET MULTIUSER
USE [master]
GO
ALTER DATABASE [APPNKP] SET  MULTI_USER
GO

--Step 6 -- Attach your database/BRING DB ONLINE


--Step 7 Add back to AG (remember delete restoring dbs from scondary)
-- RESTORE FULL BACKUP TO SECON  IN NO RECOVERY



--STEP 12: CHECK ALWAYS-ON HEALTH

1	SELECT sadc.database_name, 
2	       ag.name AS ag_name, 
3	       dhrs.is_local, 
4	       dhrs.is_primary_replica, 
5	       dhrs.synchronization_state_desc, 
6	       dhrs.is_commit_participant, 
7	       dhrs.synchronization_health_desc
8	FROM sys.dm_hadr_database_replica_states AS dhrs
9	     INNER JOIN sys.availability_databases_cluster AS sadc ON dhrs.group_id = sadc.group_id AND dhrs.group_database_id = sadc.group_database_id
10	     INNER JOIN sys.availability_groups AS ag ON ag.group_id = dhrs.group_id
11	     INNER JOIN sys.availability_replicas AS sar ON dhrs.group_id = sar.group_id  
12	AND dhrs.replica_id = sar.replica_id;
