with _index as (
  select soitableschemaname || '.' || regexp_replace(soitablename, E'_\\d+_prt_\\d+$' , '') as table_name,
  sum(soisize) as size
  from gp_toolkit.gp_size_of_index
  GROUP BY table_name
),
_table as (
  SELECT sotdschemaname || '.' || regexp_replace(sotdtablename, E'_\\d+_prt_\\d+$' , '') as table_name,
  sum(sotdsize) as size,
  sum(sotdtoastsize) as toast,
  sum(sotdadditionalsize) as other
  FROM gp_toolkit.gp_size_of_table_disk
  GROUP BY table_name
)
select t.table_name,
pg_size_pretty(t.size::bigint) as size,
pg_size_pretty(i.size::bigint) as index,
pg_size_pretty(t.toast::bigint) as toast,
pg_size_pretty(t.other::bigint) as other,
pg_size_pretty((coalesce(t.size, 0) + coalesce(i.size,0) + coalesce(t.toast, 0) + coalesce(t.other, 0))::bigint) as total
from _table t left join _index i using (table_name)
ORDER BY (coalesce(t.size, 0) + coalesce(i.size,0) + coalesce(t.toast, 0) + coalesce(t.other, 0))::bigint desc
limit 50;
