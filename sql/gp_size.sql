with _data as (
    select regexp_replace(schemaname || '.' || tablename, E'_\\d+_prt_.+$' , '') as tbl, --for partitioned tables
    coalesce(pg_relation_size(schemaname || '.' || tablename), 0) as size,
    coalesce(pg_total_relation_size(schemaname || '.' || tablename),0) as total_size
    from pg_tables WHERE schemaname not similar to E'(information\\_schema|pg_%|gp_%)'
)
select tbl, obj_description(tbl::regclass) as comment,
pg_size_pretty(sum(size)::bigint) as size,
pg_size_pretty((sum(total_size) - sum(size))::bigint) as index,
pg_size_pretty(sum(total_size)::bigint) as total_size
from _data
group by tbl
order by sum(size) + sum(total_size) desc
limit 50;
