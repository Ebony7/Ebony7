SELECT
    t.name AS TableName,
    c.name AS IdentityColumn,
    c.seed_value,
    c.increment_value
FROM 
    sys.tables t
JOIN 
    sys.columns col ON t.object_id = col.object_id
JOIN 
    sys.identity_columns c ON t.object_id = c.object_id AND col.column_id = c.column_id
ORDER BY 
    t.name;
