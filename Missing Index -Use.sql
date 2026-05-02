/* MISSING INDEXES This script returns information about missing indexes. 
The results are sorted by User Impact in descending order. Indexes with higher User 
Impact potential can provide the highest performance improvement. This script generates two outputs. 
The first output is the missing index information. The second output are the CREATE INDEX statements.
The Messages pane also prints some useful information, including CREATE INDEX options you can add, if you choose. 
You may find it useful to change the "Result To Text" from the Query menu in SQL Server Management Studio. 
Do not blindly apply all indexes recommendation from this script (or from the missing index DMVs). 
The missing index DMVs are updated when a query is optimized by the optimizer. 
Similar queries could create similar missing index recommendations.
Nor does this information consider existing indexes that may be similar. 
You may just need to make a minor modification to an existing index, based on the information returned from this script. 
Suggestions when modifying existing indexes or the suggested indexes from this script:
- Remember equality columns should be put before the inequality columns, and together they should make the key of the index.
- Ensure key columns stay in the same order of existing indexes or indexes recommended from this script. Included columns, 
if any, can be in any order. - To determine an effective order for the equality columns, order them based on their selectivity:
list the most selective columns first (leftmost in the column list). 
- Remember, these values are reset after the SQL Server services restarts. 
You can save this information off to a table so you can view across restarts.
In Azure SQL Database, dynamic management views cannot expose information that would impact database 
containment or expose information about other databases the user has access to. To avoid exposing 
this information, every row that contains data that doesn't belong to the connected tenant is filtered out. 
References sys.dm_db_missing_index_group_stats (Transact-SQL) 

https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-db-missing-index-group-stats-transact-sql sys.dm_db_missing_index_groups (Transact-SQL) 
https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-db-missing-index-groups-transact-sql 
sys.dm_db_missing_index_details (Transact-SQL) https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-db-missing-index-details-transact-sql */ 

SET NOCOUNT ON SELECT user_seeks * avg_total_user_cost * (avg_user_impact * 0.5) AS IndexImpact, groupstats.last_user_seek AS LastUserSeek,
details.[statement] AS FullObjectName, REPLACE(REPLACE(REVERSE(LEFT(REVERSE(details.[statement]), CHARINDEX('.', REVERSE(details.[statement]))-1)),'[',''), ']','') AS TableName, details.equality_columns AS EqualityColumns,
details.inequality_columns AS InequalityColumns, details.included_columns AS IncludedColumns, groupstats.unique_compiles AS Compiles,
groupstats.user_seeks AS Seeks, groupstats.avg_total_user_cost AS UserCost, groupstats.avg_user_impact AS UserImpact, DB_NAME(details.database_id) AS DatabaseName 
FROM sys.dm_db_missing_index_group_stats AS groupstats INNER JOIN sys.dm_db_missing_index_groups AS groups ON groupstats.group_handle = groups.index_group_handle 
INNER JOIN sys.dm_db_missing_index_details AS details ON groups.index_handle = details.index_handle;
PRINT '-- Missing Indexes'; PRINT '-- Generated on ' + CONVERT(VARCHAR(50), GETDATE(), 126);
PRINT '/* Review the output for duplicate and redundant indexes. Ensure equality and inquality are unique ' + CHAR(13) + CHAR(10) + 'columns and order. Include columns can be merged into a unique list,
order does not matter. Also, ' + CHAR(13) + CHAR(10) + 'these recommendations may be similar to existing indexes.
You may just need to modify an existing ' + CHAR(13) + CHAR(10) + 'index. ' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + 'Here are some CREATE INDEX options for your reference: ' + CHAR(13) + CHAR(10) + 'WITH (PAD_INDEX = OFF, 
STATISTICS_NORECOMPUTE = OFF, 
SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ' + CHAR(13) + CHAR(10) + 'ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10); 
DECLARE @ProductVersion NVARCHAR(128); SET @ProductVersion = CAST(SERVERPROPERTY ('ProductVersion') AS NVARCHAR(128));
IF CAST(LEFT(@ProductVersion, CHARINDEX('.',@ProductVersion)-1) AS INT) > 8
BEGIN WITH Cte1 ( IndexImpact, LastUserSeek, FullObjectName, TableName, EqualityColumns, InequalityColumns, IncludedColumns, Compiles, Seeks, UserCost, UserImpact,
DatabaseName) AS ( SELECT user_seeks * avg_total_user_cost * (avg_user_impact * 0.5) AS IndexImpact,
groupstats.last_user_seek AS LastUserSeek, details.[statement] AS FullObjectName, REPLACE(REPLACE(REVERSE(LEFT(REVERSE(details.[statement]), 
CHARINDEX('.', REVERSE(details.[statement]))-1)),'[',''), ']','') AS TableName, 
details.equality_columns AS EqualityColumns, details.inequality_columns AS InequalityColumns, details.included_columns AS IncludedColumns, groupstats.unique_compiles AS Compiles, groupstats.user_seeks AS Seeks, groupstats.avg_total_user_cost AS UserCost,
groupstats.avg_user_impact AS UserImpact, DB_NAME(details.database_id) AS DatabaseName
FROM sys.dm_db_missing_index_group_stats AS groupstats INNER JOIN sys.dm_db_missing_index_groups AS groups ON groupstats.group_handle = groups.index_group_handle
INNER JOIN sys.dm_db_missing_index_details AS details ON groups.index_handle = details.index_handle ) SELECT 'CREATE NONCLUSTERED INDEX [IX_' + TableName + '_' + RIGHT(CAST(NEWID() AS CHAR(36)), 12) + '] ON ' + FullObjectName + CHAR(13) + CHAR(10) + '(' + ISNULL(EqualityColumns, '') + CASE WHEN EqualityColumns IS NOT NULL AND InequalityColumns IS NOT NULL THEN ', ' ELSE '' END + ISNULL(InequalityColumns, '') + ') ' + CASE WHEN IncludedColumns IS NOT NULL THEN CHAR(13) + CHAR(10) + CAST('INCLUDE (' + ISNULL(CAST(IncludedColumns AS VARCHAR(1000)), '') + ');' AS VARCHAR(1050))
ELSE ';' END + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) AS CreateIndexStatement 
--INTO
FROM Cte1
END;