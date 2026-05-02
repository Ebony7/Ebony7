--TSQL TO GENERATE RESTORE SCRIPTS

select distinct 'restore database ' +  db_name(database_id) + ' from disk=''I:\Backup\' +  db_name(database_id) + '.bak'' with stats=1
,MOVE ''' + db_name(database_id) + ''' TO ''G:\DataFiles\' + db_name(database_id) + '.mdf'',      
MOVE '''+ db_name(database_id) + '_log'' TO ''H:\LogFiles\' + db_name(database_id) + '_Log.ldf''
GO'
from sys.master_files
where physical_name like 'G:\%.mdf%'
and database_id >4
