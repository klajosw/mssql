SELECT FORR_AZ,
  SEMA,
  TABLA_NEV,
  OSZLOP_NEV,
  OSZLOP_TIPUS,
  OSZLOP_HOSSZ,
  FK_TABLA,
  FK_TABLA_OSZLOP,
  PK,
  OSZLOP_HOSZ_FORAS,
  ST_TABLA_NEV,
  ST_OSZLOP_NEV,
  ST_OSZLOP_TIPUS,
  ST_OSZLOP_HOSSZ,
  ST_FK_TABLA,
  ST_FK_TABLA_OSZLOP,
  ST_PK
FROM DW_MASTER_TABLE ;
--- sémák száma
SELECT FORR_AZ, SEMA
, count(distinct TABLA_NEV) as tabla_db, count(1) as mezo_db 
FROM DW_MASTER_TABLE group by FORR_AZ, SEMA
;
---- 
SELECT FORR_AZ, SEMA, TABLA_NEV
FROM DW_MASTER_TABLE group by FORR_AZ, SEMA, TABLA_NEV
order by TABLA_NEV, FORR_AZ
;
----
SELECT oszlop_nev
, listagg(FORR_AZ||'_'||TABLA_NEV,', ') WITHIN GROUP (ORDER BY FORR_AZ||'_'||TABLA_NEV)  as forras_tabla_lista
, listagg('1','') WITHIN GROUP (ORDER BY FORR_AZ||'_'||TABLA_NEV)  as jelzo
FROM DW_MASTER_TABLE group by  oszlop_NEV
;
----

select ST_TABLA_NEV, 
LISTAGG(sql_parancs,' ') WITHIN GROUP (ORDER BY rownum)
from (
select ST_TABLA_NEV,
case when db = sorsz then  REPLACE(sql_parancs,'),',') ; ')
         else   sql_parancs
end as sql_parancs
from (
select  ST_TABLA_NEV, sql_parancs
,ROW_NUMBER()   OVER (PARTITION BY ST_TABLA_NEV ORDER BY ST_TABLA_NEV ) AS sorsz
,count(1)   OVER (PARTITION BY ST_TABLA_NEV ORDER BY ST_TABLA_NEV ) AS db
from ( select ST_TABLA_NEV,
case when ROWNUM = 1 then 'CREATE TABLE ' || ST_TABLA_NEV || ' ( ' 
else  ST_OSZLOP_NEV || '  ' ||  ST_OSZLOP_TIPUS || '( ' ||  nvl(ST_OSZLOP_HOSSZ,'') || ' ),'
end as sql_parancs
from DW_MASTER_TABLE  where ST_TABLA_NEV = 'enw_Afa'
) a1 ) a2 order by a2.sorsz ) a3 group by ST_TABLA_NEV

---

DECLARE
    tabla_ut   VARCHAR2 (500);
    sql_paracs_ut   VARCHAR2(500);
    
      CURSOR kl_cursor IS
select ST_TABLA_NEV, 
LISTAGG(sql_parancs,' ') WITHIN GROUP (ORDER BY rownum) as sql_paracs
from (
select ST_TABLA_NEV,
case when db = sorsz then  REPLACE(sql_parancs,'),',') ) ; ')
         else   sql_parancs
end as sql_parancs
from (
select  ST_TABLA_NEV, sql_parancs
,ROW_NUMBER()   OVER (PARTITION BY ST_TABLA_NEV ORDER BY ST_TABLA_NEV ) AS sorsz
,count(1)   OVER (PARTITION BY ST_TABLA_NEV ORDER BY ST_TABLA_NEV ) AS db
from ( select ST_TABLA_NEV,
case when ROWNUM = 1 then 'CREATE TABLE ' || ST_TABLA_NEV || ' ( ' 
else  ST_OSZLOP_NEV || '  ' ||  ST_OSZLOP_TIPUS || '( ' ||  nvl(ST_OSZLOP_HOSSZ,'') || ' ),'
end as sql_parancs
from DW_MASTER_TABLE  where ST_TABLA_NEV = 'enw_BankKivonatJogcim'
) a1 ) a2 order by a2.sorsz ) a3 group by ST_TABLA_NEV
;

BEGIN
      OPEN kl_cursor;
      LOOP
        FETCH kl_cursor INTO  tabla_ut, sql_paracs_ut ;
        EXIT WHEN kl_cursor%NOTFOUND;
        
        DBMS_OUTPUT.put_line (sql_paracs_ut);
       EXECUTE IMMEDIATE sql_paracs_ut ;
       commit;
       
      END LOOP;

      CLOSE kl_cursor;
      
     EXCEPTION  WHEN OTHERS THEN   dbms_output.put_line(sqlerrm); 
	 
------
DECLARE
    tabla_ut   VARCHAR2 (500);
    sql_paracs_ut   VARCHAR2(500);
    
      CURSOR kl_cursor IS
select ST_TABLA_NEV, 
LISTAGG(sql_parancs,' ') WITHIN GROUP (ORDER BY rownum) as sql_paracs
from (
select ST_TABLA_NEV,
case when db = sorsz then  REPLACE(sql_parancs,'),',') )  ')
         else   sql_parancs
end as sql_parancs
from (
select  ST_TABLA_NEV, sql_parancs
,ROW_NUMBER()   OVER (PARTITION BY ST_TABLA_NEV ORDER BY ST_TABLA_NEV ) AS sorsz
,count(1)   OVER (PARTITION BY ST_TABLA_NEV ORDER BY ST_TABLA_NEV ) AS db
from ( select ST_TABLA_NEV,
case when ROWNUM = 1 then 'CREATE TABLE ' || ST_TABLA_NEV || ' ( ' ||  ST_OSZLOP_NEV || '  ' ||  ST_OSZLOP_TIPUS || '( ' ||  nvl(ST_OSZLOP_HOSSZ,'') || ' ),  '
else   ST_OSZLOP_NEV || '  ' ||  ST_OSZLOP_TIPUS || '( ' ||  nvl(ST_OSZLOP_HOSSZ,'') || ' ),'
end as sql_parancs
from DW_MASTER_TABLE  where ST_TABLA_NEV = 'enw_BankKivonatJogcim'
) a1 ) a2 order by a2.sorsz ) a3 group by ST_TABLA_NEV
;

BEGIN
      OPEN kl_cursor;
      LOOP
        FETCH kl_cursor INTO  tabla_ut, sql_paracs_ut ;
        EXIT WHEN kl_cursor%NOTFOUND;        
        DBMS_OUTPUT.put_line (sql_paracs_ut);
    ---    EXECUTE IMMEDIATE sql_paracs_ut ;
        execute immediate ( sql_paracs_ut);
       commit;
       
      END LOOP;
    CLOSE kl_cursor;      
    EXCEPTION  WHEN OTHERS THEN   dbms_output.put_line(sqlerrm); 
END; 	 