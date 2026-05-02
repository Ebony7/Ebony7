EXEC sp_MSforeachdb N'USE [?];
SELECT
    DB_NAME() AS [DatabaseName],
    file_id,
    type_desc AS [FileType],
    name AS [LogicalName],
    Physical_Name AS [PhysicalName],
    (size * 8.0 / 1024) AS [SizeMB],
    (FILEPROPERTY(name, ''SpaceUsed'') * 8.0 / 1024) AS [SpaceUsedMB],
    ((size - FILEPROPERTY(name, ''SpaceUsed'')) * 8.0 / 1024) AS [FreeSpaceMB]
FROM sys.master_files
WHERE
    DB_NAME(database_id) = DB_NAME()
ORDER BY
    type, file_id;
'