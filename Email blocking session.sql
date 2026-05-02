-
-- Send the list of blocked sessions by email
--
set nocount on

declare @BlockingReportHTML nvarchar(max)
declare @WaitTime int = 600000

set @BlockingReportHTML = N'<H1>Blocking Report</H1>' +
						  N'<table border="1">' +
						  N'<tr>' +
						  N'<th>Session_ID</th>' +
						  N'<th>Status</th>' +
						  N'<th>Blocking_Session_ID</th>' +
						  N'<th>Wait_Type</th>' +
						  N'<th>Wait_Resource</th>' +
						  N'<th>Wait_Time_Minutes</th>' +
						  N'<th>CPU_Time</th>' +
						  N'<th>Physical_IO</th>' +
						  N'<th>Statement_Text</th>' +
						  N'<th>Command</th>' +
						  N'<th>Database_Name</th>' +
						  N'<th>Login_Name</th>' +
						  N'<th>Host_Name</th>' +
						  N'<th>Host_Process_ID</th>' +
						  N'<th>Program_Name</th>' +
						  N'<th>Login_Time</th>' +
						  N'<th>Last_Batch</th>' +
						  N'<th>Open_Transaction_Count</th>' +
						  N'</tr>' + cast((
	select td = p.spid, '',
		   td = p.status, '',
		   td = p.blocked, '',
		   td = p.waittype, '',
		   td = p.waitresource, '',
		   td = (p.waittime / 1000)/60, '',
		   td = p.cpu, '',
		   td = p.physical_io, '',
		   td = st.text, '',
		   td = p.cmd, '',
		   td = db_name(p.dbid), '',
		   td = p.loginame, '',
		   td = p.hostname, '',
		   td = p.hostprocess, '',
		   td = p.program_name, '',
		   td = p.login_time, '',
		   td = p.last_batch, '',
		   td = p.open_tran
	  from sys.sysprocesses as p
	 cross apply sys.dm_exec_sql_text(p.sql_handle) as st
	 where (p.waittime >= @WaitTime
	   and ISNULL(p.blocked,0) >0) --and p.blocked is not null)
	    or  p.spid in (select blocked
						 from sys.sysprocesses
						where ISNULL(blocked,0) >0
						  and waittime >= @WaitTime)
	 order by p.blocked,
	          p.spid
       for xml path('tr'),
	       type) as nvarchar(max)) +
						  N'</table>';
--print @BlockingReportHTML
if @BlockingReportHTML is not null 
	execute msdb.dbo.sp_send_dbmail @body = @BlockingReportHTML,
		@body_format = 'HTML',
		@profile_name = N'IT Data Services',
		@recipients = N'ITDataServicesOffshore@spirit.com;DatabaseAdmins@spirit.com;Rama.Vallabhaneni@spirit.com; Mohammed.Khan@spirit.com; Juan.Braceras@spirit.com; Naveen.Kuppili@spirit.com',
@Subject = N'SSCPSBRODS:Blocking Detected';