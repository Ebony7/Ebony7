SELECT
    'CREATE USER [' + dp.name + '] FOR LOGIN [' + sp.name + '];'
FROM 
    sys.database_principals dp
JOIN 
    sys.server_principals sp ON dp.sid = sp.sid
WHERE 
    dp.type IN ('S', 'U') AND dp.name NOT IN ('dbo', 'guest', 'INFORMATION_SCHEMA', 'sys');
