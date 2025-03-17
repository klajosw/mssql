--- xls-bõl tábla létrehozás
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
---- xls-bõl függõség létrehozás PK és FK
-- ALTER TABLE table_name ADD CONSTRAINT constraint_name PRIMARY KEY (column1);
----

DECLARE
    tabla_ut   VARCHAR2 (500);
    sql_paracs_ut   VARCHAR2(500);    
    
    CURSOR kl_cursor IS select ST_TABLA_NEV,
  'ALTER TABLE   ' || ST_TABLA_NEV || ' add constraint PK_' || ST_OSZLOP_NEV  || ' PRIMARY KEY ( ' ||   ST_OSZLOP_NEV  || '  ) '
  from DW_MASTER_TABLE  where ST_TABLA_NEV = 'enw_BankKivonatJogcim'
  and  pk ='Y' 
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
------- FK
-- ALTER TABLE table_name add constraint fk_cust_name FOREIGN KEY (person_name) references person_table (person_name)
--
DECLARE
    tabla_ut   VARCHAR2 (500);
    sql_paracs_ut   VARCHAR2(500);    
 --- add constraint fk_cust_name FOREIGN KEY (person_name) references person_table (person_name)    
    CURSOR kl_cursor IS     select ST_TABLA_NEV,
  'ALTER TABLE  ' || ST_TABLA_NEV || ' add constraint fk_' ||   ST_OSZLOP_NEV  ||  ' FOREIGN KEY ( ' || ST_OSZLOP_NEV || ')  references  '||  st_fk_tabla || ' (' ||  st_fk_tabla_oszlop || ')'
   from DW_MASTER_TABLE  where ST_TABLA_NEV = 'enw_BankKivonatJogcim'
  and  st_fk_tabla is not null 
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
----
DECLARE
    tabla_ut   VARCHAR2 (500);
    sql_paracs_ut   VARCHAR2(500);    
 --- add constraint fk_cust_name FOREIGN KEY (person_name) references person_table (person_name)    
    CURSOR kl_cursor IS     select ST_TABLA_NEV,
  'ALTER TABLE  ' || ST_TABLA_NEV || ' add constraint fk_' ||  ST_OSZLOP_NEV  ||  ' FOREIGN KEY ( ' || ST_OSZLOP_NEV || ')  references  '||  st_fk_tabla || ' (' ||  st_fk_tabla_oszlop || ')'
   from DW_MASTER_TABLE  where ST_TABLA_NEV = 'enw_BankKivonatJogcim'
  and  st_fk_tabla is not null 
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
----------------
