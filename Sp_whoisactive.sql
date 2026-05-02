
Exec dbo.sp_whoisactive 
@get_plans = 1 , 
@get_transaction_info = 1, 
@get_additional_info = 1


EXEC sp_WhoIsActive
    @get_transaction_info = 1,
    @get_plans = 1,
    @get_locks = 1,
    @output_column_list = '[session_id][login_name][database_name][open_transaction_count][transaction_duration][sql_text][blocking_session_id][wait_info][query_plan][cpu][lock][used_memory][status][program_name][start_time][elapsed_time]';
