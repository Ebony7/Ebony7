SELECT object_name, counter_name, instance_name, cntr_value
FROM sys.dm_os_performance_counters
WHERE object_name LIKE '%Buffer Manager%'
  AND counter_name IN ('Buffer cache hit ratio', 'Buffer cache hit ratio base');


SELECT
  CAST(
    100.0 * hit.cntr_value / NULLIF(base.cntr_value, 0)
    AS decimal(6,2)
  ) AS buffer_cache_hit_ratio_pct
FROM sys.dm_os_performance_counters AS hit
JOIN sys.dm_os_performance_counters AS base
  ON hit.object_name   = base.object_name
 AND hit.instance_name = base.instance_name
WHERE hit.counter_name  = 'Buffer cache hit ratio'
  AND base.counter_name = 'Buffer cache hit ratio base'
  AND hit.object_name LIKE '%Buffer Manager%';
 