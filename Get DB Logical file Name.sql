--GET LOGICAL FILE NAME
RESTORE FILELISTONLY FROM DISK='I:\Backup\prosNav.bak';



--Logical file path

SELECT name, physical_name, state_desc AS OnlineStatus
FROM sys.master_files  
WHERE database_id = DB_ID(N'DB')  
GO
