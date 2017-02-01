SELECT
     pg_stat_all_tables.schemaname||'.'||relid::regclass AS table,
     round (100* (sum(pg_stat_user_indexes.idx_scan))
                   / (sum(pg_stat_user_indexes.idx_scan) over () )
                    ,2) pct_indx_scans
 FROM
     pg_stat_user_indexes
     JOIN pg_index USING (indexrelid)
     join pg_stat_all_tables using (relid)
     group by pg_stat_all_tables.schemaname||'.'||relid::regclass,pg_stat_user_indexes.idx_scan
     order by 2 desc
     limit 10;
