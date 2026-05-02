 
SELECT
    blocking_session_id AS BlockingSessionID,
    session_id AS VictimSessionID,
    (SELECT text FROM sys.dm_exec_sql_text(sql_handle)) AS SQLQuery
FROM sys.dm_exec_requests
WHERE blocking_session_id > 0