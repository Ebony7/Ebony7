select * from sys.dm_exec_cached_plans

select * from sys.dm_db_file_space_usage;

select * from sys.dm_exec_connections

--how many times index were accessd and used
Select DB_Name(database_id) AS databaseName, 
Object_Name(object_id) AS ObjectName,
*
From sys.dm_db_index_usage_stats;


--checks allocation and indexs in this filegroup. - 0 means the primary filegroup
DBCC CheckDB;
DBCC Checkfilegroup (0, noindex) --noindex means the non clustered indexes will be ignored
with physical_only, --focuese on the structure of the file , not the data
estimateonly; --just checks the amount of space in tempdb required to perform the check
GO

DBCC SQLPERF (LOGSPACE)

	
SELECT NAME, LOG_REUSE_WAIT_DESC FROM SYS.DATABASES