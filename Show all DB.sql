--script to show all databses
SELECT name FROM sys.databases WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb'); 