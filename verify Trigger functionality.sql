

SELECT 
t.name as trigger_name,
t.is_disabled,
t.type_desc,
object_schema_name(t.parent_id) AS schema_name,
object_name(t.parent_id) AS parent_object
FROM sys.triggers t
WHERE t.name = N'tr_dbo_ContactTracing_0a5fb913-736c-4e12-95d5-498607ff8dfc_Sender'




-- Shows only triggers currently in plan cache (still very handy)
SELECT
  OBJECT_SCHEMA_NAME(object_id) AS schema_name,
  OBJECT_NAME(object_id) AS trigger_name,
  execution_count,
  last_execution_time,
  total_elapsed_time/1000.0 AS total_ms
FROM sys.dm_exec_trigger_stats
WHERE OBJECT_NAME(object_id) = N'tr_dbo_ContactTracing_0a5fb913-736c-4e12-95d5-498607ff8dfc_Sender';







