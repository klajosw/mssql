-- Spec a megadott t�bl�zatok �sszes mez�j�nek ellen�rz�se null �rt�k el�fordul�sa ellen�rz�s
-- 1. t�bla mez�lista alapj�n sql parancsok gener�l�sa �s futtat�sa
-- 2. eredm�nyek elemz�se, hiba log t�lt�s
----------Inf�
-- select * from all_tables where table_name = upper('tabla')
-- select * from ALL_TAB_COLUMNS where table_name = upper('tabla')
----------
-- select GREATEST(tmp) from (
-- select max(tmp) from (
--1
select sql, sorsz from (
select 
 case when rownum = 1 then 'select count(' || COLUMN_NAME || ') as ' || COLUMN_NAME || '_db '
         else ', count(' || COLUMN_NAME  || ') as ' || COLUMN_NAME || '_db '
 end as sql 
 , COLUMN_ID as sorsz
from ALL_TAB_COLUMNS where table_name = upper('tabla') 
union
select ' from ' || 'tabla' || '; ' as sql, 99999 as sorsz  from dual
) a order by rownum desc
----2
select --sql, sorsz, tabla_nev 
LISTAGG(sql,' ') WITHIN GROUP (ORDER BY sorsz)
from (
select 
 case when rownum = 1 then 'select count(' || COLUMN_NAME || ') as ' || COLUMN_NAME || '_db '
         else ', count(' || COLUMN_NAME  || ') as ' || COLUMN_NAME || '_db '
 end as sql 
 , COLUMN_ID as sorsz, table_name as tabla_nev
from ALL_TAB_COLUMNS where table_name = upper('tabla') 
union
select ' from ' || 'tabla' || '; ' as sql, 99999 as sorsz, upper( 'tabla' ) as tabla_nev  from dual
) a order by rownum desc
-----3




