SELECT
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.name AS TableName,
    SUM(p.rows) AS [RowCount]
FROM 
    sys.tables t
JOIN 
    sys.partitions p ON t.object_id = p.object_id
WHERE 
    p.index_id IN (0, 1)  -- 0 = Heap, 1 = Clustered Index
GROUP BY 
    SCHEMA_NAME(t.schema_id), t.name
ORDER BY 
   [RowCount] DESC;
