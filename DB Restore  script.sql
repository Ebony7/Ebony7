-- restore to AG Pri from Blob
USE [master]
RESTORE DATABASE [ITMetrics] FROM  URL = N'https://dbadminsbackupstoragepe.blob.core.windows.net/etlbackups/ITMetrics.bak' WITH  FILE = 1, 
MOVE N'ITMetrics' TO N'H:\data\ITMetrics.mdf',  MOVE N'ITMetrics_log' TO N'G:\log\ITMetrics_log.ldf',  NOUNLOAD, REPLACE,  STATS = 10
 
GO


--Restore to AG sec from url

RESTORE DATABASE [Monitoring] FROM  URL = N'https://dbadminsbackupstoragepe.blob.core.windows.net/etlbackups/Monitoring.bak' WITH  FILE = 1, 
MOVE N'Monitoring' TO N'F:\data\Monitoring.mdf',  MOVE N'Monitoring_log' TO N'G:\log\Monitoring_log.ldf',  NORECOVERY, NOUNLOAD, REPLACE,  STATS = 5
 
GO


--Restore from Disk
restore database APPNKDEV_MM from disk='I:\Backup\APPNKDEV_MM.bak' with stats=1
,MOVE 'APPNKDEV_MM' TO 'F:\DataFiles\APPNKDEV_MM.mdf',      
MOVE 'APPNKDEV_MM_log' TO 'H:\LogFiles\APPNKDEV_MM_Log.ldf'
GO



--RESTORE STRIPED BACKUP FILES FROM STORAGE

USE [master]
RESTORE DATABASE [fpm_nks_test] FROM  URL = N'https://dbadminsbackupstoragepe.blob.core.windows.net/etlbackups/fpm_nks_test_backup1.bak',

 URL = N'https://dbadminsbackupstoragepe.blob.core.windows.net/etlbackups/fpm_nks_test_backup2.bak',
 URL = N'https://dbadminsbackupstoragepe.blob.core.windows.net/etlbackups/fpm_nks_test_backup3.bak', 
 URL = N'https://dbadminsbackupstoragepe.blob.core.windows.net/etlbackups/fpm_nks_test_backup4.bak',
 URL = N'https://dbadminsbackupstoragepe.blob.core.windows.net/etlbackups/fpm_nks_test_backup5.bak',
 URL = N'https://dbadminsbackupstoragepe.blob.core.windows.net/etlbackups/fpm_nks_test_backup6.bak',
 URL = N'https://dbadminsbackupstoragepe.blob.core.windows.net/etlbackups/fpm_nks_test_backup7.bak',
 URL = N'https://dbadminsbackupstoragepe.blob.core.windows.net/etlbackups/fpm_nks_test_backup8.bak',
 URL = N'https://dbadminsbackupstoragepe.blob.core.windows.net/etlbackups/fpm_nks_test_backup9.bak', 
 URL = N'https://dbadminsbackupstoragepe.blob.core.windows.net/etlbackups/fpm_nks_test_backup10.bak'
 WITH  FILE = 1,MOVE N'mfs2datData' TO N'G:\DataFiles\mfs2datData.mdf', 
 MOVE N'mfs2log' TO N'H:\LogFiles\mfs2log.ldf', 
 MOVE N'mfs2ext1Data' TO N'G:\DataFiles\mfs2ext1Data.mdf',NOUNLOAD, REPLACE, NORECOVERY, STATS = 10
 
GO

--restore log

USE [master]
RESTORE LOG [fpm_nks_test] FROM  URL = N'https://dbadminsbackupstoragepe.blob.core.windows.net/etlbackups/fpm_nks_test_backup.trn' WITH  FILE = 1, 
MOVE N'mfs2datData' TO N'G:\DataFiles\mfs2datData.mdf',  MOVE N'mfs2log' TO N'H:\LogFiles\mfs2log.ldf', MOVE N'mfs2ext1Data' TO N'G:\DataFiles\mfs2ext1Data.mdf',NOUNLOAD, REPLACE, NORECOVERY, STATS = 10
 
GO