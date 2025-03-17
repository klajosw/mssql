-- Spec a megadott t�bl�zatok �sszes mez�j�nek ellen�rz�se null �rt�k el�fordul�sa ellen�rz�s
--Inf�:
-- select * from all_constraints
-- select * from all_cons_columns
-----
SELECT a.constraint_name, a.table_name, a.column_name,  c.owner, 
       -- referenced pk
       c.r_owner, c_pk.table_name r_table_name, c_pk.constraint_name r_pk
  FROM all_cons_columns a
  JOIN all_constraints c ON a.owner = c.owner
                        AND a.constraint_name = c.constraint_name
  JOIN all_constraints c_pk ON c.r_owner = c_pk.owner
                           AND c.r_constraint_name = c_pk.constraint_name
 WHERE c.constraint_type = 'R' and c.owner  = 'KLAJOS'