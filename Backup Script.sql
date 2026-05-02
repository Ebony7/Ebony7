--backup to url
USE [master]
BACKUP DATABASE [ProsNav] TO  URL = N'https://dbadminsbackupstoragepe.blob.core.windows.net/etlbackups/ProsNav.bak'
WITH NOFORMAT, NOINIT,  NAME = N'ProsNav', NOSKIP, NOREWIND, NOUNLOAD,  STATS = 5

--Backup to disk



--Stripe backup to disk
BACKUP DATABASE [fpm_nks_test] TO  DISK = N'I:\Backup\fpm_test.bak',  
DISK = N'I:\Backup\fpm2.bak',  DISK = N'I:\Backup\fpm3.bak',  
DISK = N'I:\Backup\fpm4.bak',  DISK = N'I:\Backup\fpm5.bak', 
DISK = N'I:\Backup\fpm6.bak',  DISK = N'I:\Backup\fpm7.bak', 
DISK = N'I:\Backup\fpm8.bak',  DISK = N'I:\Backup\fpm9.bak', 
DISK = N'I:\Backup\fpm10.bak' WITH NOFORMAT, NOINIT, 
NAME = N'fpm_nks_test-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10
GO

--bckup log
BACKUP LOG [fpm_nks_test] TO  DISK = N'I:\Backup\fpm.trn' WITH NOFORMAT, NOINIT, 
NAME = N'fpm_nks_test-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO


--stripe backup to url

BACKUP DATABASE [fpm_nks_test] TO  URL = N'https://dbadminsbackupstoragepe.blob.core.windows.net/etlbackups/fpm_nks_test_backup1.bak',  
URL = N'https://dbadminsbackupstoragepe.blob.core.windows.net/etlbackups/fpm_nks_test_backup2.bak',  
URL = N'https://dbadminsbackupstoragepe.blob.core.windows.net/etlbackups/fpm_nks_test_backup3.bak', 
URL = N'https://dbadminsbackupstoragepe.blob.core.windows.net/etlbackups/fpm_nks_test_backup4.bak',  
URL = N'https://dbadminsbackupstoragepe.blob.core.windows.net/etlbackups/fpm_nks_test_backup5.bak',  
URL = N'https://dbadminsbackupstoragepe.blob.core.windows.net/etlbackups/fpm_nks_test_backup6.bak', 
URL = N'https://dbadminsbackupstoragepe.blob.core.windows.net/etlbackups/fpm_nks_test_backup7.bak', 
URL = N'https://dbadminsbackupstoragepe.blob.core.windows.net/etlbackups/fpm_nks_test_backup8.bak', 
URL = N'https://dbadminsbackupstoragepe.blob.core.windows.net/etlbackups/fpm_nks_test_backup9.bak', 
URL = N'https://dbadminsbackupstoragepe.blob.core.windows.net/etlbackups/fpm_nks_test_backup10.bak' 
WITH NOFORMAT, NOINIT, 
NAME = N'fpm_nks_test-Full Database Backup',
NOSKIP, NOREWIND, NOUNLOAD, 
COMPRESSION,  STATS = 10
GO


--backup log to url
BACKUP LOG [fpm_nks_test] TO  URL = N'https://dbadminsbackupstoragepe.blob.core.windows.net/etlbackups/fpm_nks_test_backup.trn'
WITH NOFORMAT, NOINIT, 
NAME = N'fpm_nks_test-Full Database Backup',
NOSKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10
GO