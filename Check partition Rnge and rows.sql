-- partition range and rows

SELECT
    OBJECT_NAME(p.object_id) AS TableName,
i.name AS IndexName,
    p.partition_number,
    pr.value AS BoundaryValue,
    p.rows AS [RowCount]
FROM
    sys.partitions p
JOIN
    sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
LEFT JOIN
    sys.partition_range_values pr ON p.partition_number = pr.boundary_id AND pr.function_id = i.data_space_id
WHERE
    OBJECT_NAME(p.object_id) = 'YourTableName' -- Specify the table name here
ORDER BY
    p.partition_number;
