Ellenõrzési szempontok:

Mezõ töltés is null számosság

FK -1 érték számolás

SELECT *
FROM all_constraints WHERE 1=1
and owner = 'KLAJOS'
=>
OWNER	CONSTRAINT_NAME	CONSTRAINT_TYPE	TABLE_NAME	SEARCH_CONDITION	R_OWNER	R_CONSTRAINT_NAME
KLAJOS	FK_UPDATEDATETIME	R	ENW_BANKKIVONATJOGCIM		KLAJOS	TABLA_PK

select * from ALL_CONS_COLUMNS WHERE 1=1 and owner = 'KLAJOS'


--- konstain lista FK
SELECT a.constraint_name, a.table_name, a.column_name,  c.owner, 
       -- referenced pk
       c.r_owner, c_pk.table_name r_table_name, c_pk.constraint_name r_pk
  FROM all_cons_columns a
  JOIN all_constraints c ON a.owner = c.owner
                        AND a.constraint_name = c.constraint_name
  JOIN all_constraints c_pk ON c.r_owner = c_pk.owner
                           AND c.r_constraint_name = c_pk.constraint_name
 WHERE c.constraint_type = 'R' and c.owner  = 'KLAJOS'
/*

-- select * from all_tables where table_name = upper('tabla')
-- select * from ALL_TAB_COLUMNS where table_name = upper('tabla')
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
/* */


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

Javasolt Név konvenciók:
-- tábla nevezéktan:
ST (stages): összes forrás tábla, öszes mezõ (mezõnev, táblanév, sémanév +'_st')
 + betöltési dátum       : load_job_date
 + betöltõ job azonosító : load_job_id
	  
DW (data warehouse): összes forrás tábla, öszes mezõ  (mezõnev, táblanév, sémanév +'_dw')
 + valid_fom
 + valid_to
 + dw_id
 + source_system_id
 + source_key_1  - 5
 + source_obj_id
 + active_flag
 + upd_job_id (bekerülési vagy módosítási töldés id)
 + lost_upd_job_id (kikerülési töldés id)
 
DM (data mart): összes cél (riport igény) táblazes mezõ (mezõnev, táblanév, sémanév +'_dm')
 + valid_fom
 + valid_to
 + dm_id
 + dw_id
 
-- seq, proc, 

-- Meta séma  (meta object : mo)

 + mo_source_object
 + mo_source_system
 + mo_job
	+ mo_job_hist
	+ mo_job_hist_log
	+ mo_job_dependency

	
---- Orcale specifikus vizsgálatok
SELECT *   FROM 
--user_cons_columns
-- all_cons_columns
all_constraints
--  USER_VIEWS --USER_TAB_COLS --USER_SEQUENCES -- USER_OBJECTS -- USER_CATALOG --user_tables
-----------------------

-- procedura lista:
SELECT owner, object_name FROM dba_objects WHERE 1=1
and owner = 'KLAJOS' and object_type = 'PROCEDURE'

-- tábla és mezõ lista
SELECT * FROM dba_TAB_COLS WHERE 1=1
and owner = 'KLAJOS'

-- megszorítások
SELECT *
FROM all_constraints WHERE 1=1
and owner = 'KLAJOS'

-- szekvenciák
SELECT * FROM ALL_SEQUENCES WHERE 1=1
and SEQUENCE_owner = 'KLAJOS'

-- indexek
select * from all_indexes WHERE 1=1
and owner = 'KLAJOS'

-- triggerek
select * from aLL_TRIGGERS WHERE 1=1
and owner = 'KLAJOS'


---- mssql specifikus vizsgálatok

-- procedura lista:
SELECT 
    SchemaName = s.name,
    ProcedureName = pr.name 
FROM 
    databasename.sys.procedures pr


-- tábla és mezõ lista
SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, ORDINAL_POSITION,
       COLUMN_DEFAULT, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH,
       NUMERIC_PRECISION, NUMERIC_PRECISION_RADIX, NUMERIC_SCALE,
       DATETIME_PRECISION
FROM INFORMATION_SCHEMA.COLUMNS


/*
SELECT t.name 
  FROM sys.tables AS t
  INNER JOIN sys.schemas AS s
  ON t.[schema_id] = s.[schema_id]
  WHERE s.name = N'schema_name';
/* */


-- megszorítások :
SELECT 
    TableName = t.Name,
    ColumnName = c.Name,
    dc.Name,
    dc.definition
FROM sys.tables t
INNER JOIN sys.default_constraints dc ON t.object_id = dc.parent_object_id
INNER JOIN sys.columns c ON dc.parent_object_id = c.object_id AND c.column_id = dc.parent_column_id
ORDER BY t.Name

/*
    sys.default_constraints ->  default constraints on columns
    sys.check_constraints -> check constraints on columns
    sys.key_constraints   -> key constraints (e.g. primary keys)
    sys.foreign_keys       ->  foreign key relations
/* */

-- indexek:
SELECT 
     TableName = t.name,
     IndexName = ind.name,
     IndexId = ind.index_id,
     ColumnId = ic.index_column_id,
     ColumnName = col.name,
     ind.*,
     ic.*,
     col.* 
FROM 
     sys.indexes ind 
INNER JOIN 
     sys.index_columns ic ON  ind.object_id = ic.object_id and ind.index_id = ic.index_id 
INNER JOIN 
     sys.columns col ON ic.object_id = col.object_id and ic.column_id = col.column_id 
INNER JOIN 
     sys.tables t ON ind.object_id = t.object_id 
WHERE 
     ind.is_primary_key = 0 
     AND ind.is_unique = 0 
     AND ind.is_unique_constraint = 0 
     AND t.is_ms_shipped = 0 
ORDER BY 
     t.name, ind.name, ind.index_id, ic.index_column_id 
	 
-- triggerek:
SELECT 
     sysobjects.name AS trigger_name 
    ,USER_NAME(sysobjects.uid) AS trigger_owner 
    ,s.name AS table_schema 
    ,OBJECT_NAME(parent_obj) AS table_name 
    ,OBJECTPROPERTY( id, 'ExecIsUpdateTrigger') AS isupdate 
    ,OBJECTPROPERTY( id, 'ExecIsDeleteTrigger') AS isdelete 
    ,OBJECTPROPERTY( id, 'ExecIsInsertTrigger') AS isinsert 
    ,OBJECTPROPERTY( id, 'ExecIsAfterTrigger') AS isafter 
    ,OBJECTPROPERTY( id, 'ExecIsInsteadOfTrigger') AS isinsteadof 
    ,OBJECTPROPERTY(id, 'ExecIsTriggerDisabled') AS [disabled] 
FROM sysobjects 
INNER JOIN sysusers ON sysobjects.uid = sysusers.uid 
INNER JOIN sys.tables t  ON sysobjects.parent_obj = t.object_id 
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id 
WHERE sysobjects.type = 'TR' 

---- dinamic sql minta:
DECLARE @SQL NVARCHAR(200) 
SET @SQL = 'SELECT * FROM Employee WHERE LastName = @EmpLastName' 
EXEC sp_executesql @SQL, N'@EmpLastName NVARCHAR(50)', @EmpLastName = 'Smith' 
---
DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql += N'
  UNION ALL SELECT db = N''' + name + ''', 
    s.name COLLATE Latin1_General_CI_AI,
    o.name COLLATE Latin1_General_CI_AI
  FROM ' + QUOTENAME(name) + '.sys.procedures AS o
  INNER JOIN ' + QUOTENAME(name) + '.sys.schemas AS s
  ON o.[schema_id] = s.[schema_id]'
FROM sys.databases
-- WHERE ... -- probably don't need system databases at least

SELECT @sql = STUFF(@sql, 1, 18, '') 
  -- you may have to adjust  ^^ 18 due to copy/paste, cr/lf, tabs etc 
  + ' ORDER BY by db, s.name, o.name';

EXEC sp_executesql @sql;

-----

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

----
select distinct OSZLOP_TIPUS from DW_MASTER_TABLE

--- UPDATE DW_MASTER_TABLE  SET ST_OSZLOP_HOSSZ = '500' WHERE ST_OSZLOP_HOSSZ ='max'
-- UPDATE DW_MASTER_TABLE  SET ST_OSZLOP_TIPUS = 'integer' WHERE ST_OSZLOP_TIPUS ='int'

UPDATE DW_MASTER_TABLE  SET ST_OSZLOP_TIPUS = 'integer' WHERE ST_OSZLOP_TIPUS ='int'