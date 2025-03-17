--- modell elenõrzés
------------------------------------------------
---- Tábla és mezõ ellenõr : A mezõ nevek ellenõrzése név konvenció szerint forrás és st táblákon (szervíz adatok ellenõrzésével is ki kell egészíteni)
select * 
from
(
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, DATA_PRECISION
FROM dba_TAB_COLS WHERE 1=1
and owner = 'KLAJOS'
and TABLE_NAME = upper('enw_BankKivonatJogcim')
)a FULL OUTER JOIN 
(select ST_TABLA_NEV as TABLE_NAME,	ST_OSZLOP_NEV as COLUMN_NAME,	ST_OSZLOP_TIPUS as DATA_TYPE,	ST_OSZLOP_HOSSZ as DATA_PRECISION
from dw_master_table
where ST_TABLA_NEV ='enw_BankKivonatJogcim'
) b
ON upper(b.TABLE_NAME) = a.TABLE_NAME and upper(b.COLUMN_NAME) = a.COLUMN_NAME
where  a.COLUMN_NAME is null or  b.COLUMN_NAME is null

------------------------------------------------
--- függõség ellenõr :  A PK és FK meglétének ellenõrzése név alapján

select * from (
select ST_TABLA_NEV as TABLE_NAME,	
case when pk ='Y' then 'PK_'|| st_oszlop_nev
         else  'FK_'|| st_oszlop_nev
end as  CONSTRAINT_NAME        
from dw_master_table
where ST_TABLA_NEV ='enw_BankKivonatJogcim'
and (pk ='Y' or st_fk_tabla is not null)
) a FULL OUTER JOIN (
SELECT TABLE_NAME,  CONSTRAINT_NAME --, CONSTRAINT_TYPE,	R_CONSTRAINT_NAME	
FROM all_constraints WHERE 1=1
and owner = 'KLAJOS'
and TABLE_NAME = upper('enw_BankKivonatJogcim')
and STATUS = 'ENABLED') b
ON upper(a.TABLE_NAME) = b.TABLE_NAME and upper(a.CONSTRAINT_NAME) =  b.CONSTRAINT_NAME   
where  a.CONSTRAINT_NAME is null or  b.CONSTRAINT_NAME is null
;
------------------------------------------------
----  FK -zás lookup ellenõrzés : Elõforduló -1 értékek ellenõrzése
DECLARE
    tabla_ut   VARCHAR2 (500);
    sql_paracs_ut   VARCHAR2(500);
     sql_paracs_ut2   VARCHAR2(500);
    
      CURSOR kl_cursor IS     select ST_TABLA_NEV , st_oszlop_nev   
from dw_master_table
where ST_TABLA_NEV ='enw_BankKivonatJogcim'
and  st_fk_tabla is not null
;

BEGIN
      OPEN kl_cursor;
      LOOP
        FETCH kl_cursor INTO  tabla_ut, sql_paracs_ut ;        
         EXIT WHEN kl_cursor%NOTFOUND;        
          sql_paracs_ut2 := 'insert into dw_service_log select 5 as type1, 5 as type2,  to_char(count(1))  as szoveg,''' || tabla_ut ||'  '|| sql_paracs_ut || ''' as tabla_oszlop from '|| tabla_ut || ' where ' || sql_paracs_ut || ' =-1' ;
        DBMS_OUTPUT.put_line (sql_paracs_ut2);
    --    EXECUTE IMMEDIATE sql_paracs_ut2 ;
        execute immediate ( sql_paracs_ut2);
       commit;
       
      END LOOP;
    CLOSE kl_cursor;      
    EXCEPTION  WHEN OTHERS THEN   dbms_output.put_line(sqlerrm); 
END; 

---- Mezõ töltöttség ellenõrzése csupa null értékû mezõ felderítése { count(1) <> count(adat_mezõ)  vizsgálat}






