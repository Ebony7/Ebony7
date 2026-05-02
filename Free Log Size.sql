
SELECT DISTINCT
    vs.volume_mount_point AS Drive,
    vs.total_bytes / 1024 / 1024 / 1024 AS TotalSize_GB,
    vs.available_bytes / 1024 / 1024 / 1024 AS FreeSpace_GB
FROM sys.master_files mf
CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.file_id) vs
WHERE vs.volume_mount_point LIKE 'E:%';  -- Change 'L' to the log drive letter
