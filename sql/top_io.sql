SELECT coalesce(t.spcname, 'pg_default') AS TABLESPACE,
       st.schemaname || '.' ||st.relname AS TABLE,
       round (100*(SUM (coalesce(st.n_tup_ins,0)+coalesce(st.n_tup_upd,0)-coalesce(st.n_tup_hot_upd,0)+coalesce(st.n_tup_del,0)))/ ( SUM (coalesce(st.n_tup_ins,0)+coalesce(st.n_tup_upd,0)-coalesce(st.n_tup_hot_upd,0)+coalesce(st.n_tup_del,0)) over ()), 2) AS pct_io_ops
FROM pg_stat_user_tables st
JOIN pg_class c ON c.oid=st.relid
LEFT JOIN pg_tablespace t ON t.oid=c.reltablespace
WHERE coalesce(n_tup_ins,0)+coalesce(n_tup_upd,0)-coalesce(n_tup_hot_upd,0)+coalesce(n_tup_del,0)>100
GROUP BY 1,
         2,
         st.n_tup_ins,
         st.n_tup_upd,
         st.n_tup_hot_upd,
         st.n_tup_del
ORDER BY pct_io_ops DESC LIMIT 10;
