SET client_min_messages TO WARNING;
with data as (
  select relid::regclass as tbl, (gp_toolkit.__gp_aovisimap_compaction_info(relid)).percent_hidden
  from pg_appendonly ao left join pg_class c on ao.relid = c.oid
  left join pg_namespace n on c.relnamespace = n.oid
  where n.nspname not like 'pg_temp_%'

)
select tbl, max(percent_hidden) as percent_hidden
from data
group by 1
having max(percent_hidden) > (select setting from pg_settings where name = 'gp_appendonly_compaction_threshold')::float
order by percent_hidden desc;
RESET client_min_messages;
