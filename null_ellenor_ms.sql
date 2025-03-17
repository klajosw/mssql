--------------------------------------  ms sql server
----- elõkészítés 
--beszúrás a master táblába
INSERT INTO dw_master_table  ( forr_az, sema, tabla_nev, oszlop_nev, oszlop_tipus, oszlop_hossz)
SELECT 'kl_db' as forr_az, TABLE_SCHEMA as sema, TABLE_NAME as tabla_nev, COLUMN_NAME as oszlop_nev, --ORDINAL_POSITION,
       DATA_TYPE as oszlop_tipus,
	   -- CHARACTER_MAXIMUM_LENGTH,   NUMERIC_PRECISION,
	    ISNULL(CHARACTER_MAXIMUM_LENGTH,NUMERIC_PRECISION) oszlop_hossz		
FROM INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME ='kl_tabla'
-- Master táblából tábla generálás

--------------------------------------
----- Ellenõrzések:
--1 táblák meglétének ellenõrzése
-- ossz_db, tolt_db,tipus, tmegj,FORR_AZ ,SEMA,TABLA_NEV ,OSZLOP_NEV , datum
/*
insert into dw_master_log select count(1) as ossz_db, count(id) as tolt_db, 'PK -1' as tipus, 'klajos' as tmej,
  'kl_db' as FORR_AZ,
  'dbo' as SEMA,
 'kl_tabla' as TABLA_NEV,
 'id' as OSZLOP_NEV, getdate() as datum
   from kl_tabla where id= -1 ;
   /* */
select d.*, x.* from 
(SELECT distinct 'db' as forr,'kl_db' as forr_az, TABLE_SCHEMA as sema, TABLE_NAME as tabla_nev
FROM INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME ='kl_tabla') d FULL OUTER JOIN
(SELECT distinct 'xls' as forr, FORR_AZ
      ,SEMA
      ,TABLA_NEV
  FROM DW_MASTER_TABLE where TABLA_NEV ='kl_tabla') x
  on 1=1
  and d.FORR_AZ = x.FORR_AZ 
  and d.SEMA = x.SEMA
  and d.TABLA_NEV = x.TABLA_NEV
  -- teszt módosítás a xls forrásban
  ---update DW_MASTER_TABLE set SEMA ='nev2'  where TABLA_NEV ='kl_tabla' -- eltérés létrehozása  kl_db
  ---update DW_MASTER_TABLE set SEMA ='dbo' where TABLA_NEV ='kl_tabla'  -- eltérés megszüntetése kl_db
  
insert into dw_master_log 
select 0 as ossz_db, 0 as tolt_db, 'TABLA_ELL' as tipus, 'klajos' as tmej,
 x.forr_az, x.sema, x.tabla_nev , '-' as OSZLOP_NEV, getdate() as datum
from 
(SELECT distinct 'db' as forr,'kl_db' as forr_az, TABLE_SCHEMA as sema, TABLE_NAME as tabla_nev
FROM INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME ='kl_tabla') d FULL OUTER JOIN
(SELECT distinct 'xls' as forr, FORR_AZ
      ,SEMA
      ,TABLA_NEV
  FROM DW_MASTER_TABLE where TABLA_NEV ='kl_tabla') x
  on 1=1
  and d.FORR_AZ = x.FORR_AZ 
  and d.SEMA = x.SEMA
  and d.TABLA_NEV = x.TABLA_NEV
  where d.TABLA_NEV is null  --- hiányzó tábla (ami nincs legenerálva)

--2 Táblák mezõinek meglétének ellenõrzése  
select d.*, x.* from 
(SELECT 'db' as forr,'kl_db' as forr_az, TABLE_SCHEMA as sema, TABLE_NAME as tabla_nev, COLUMN_NAME as oszlop_nev, --ORDINAL_POSITION,
       DATA_TYPE as oszlop_tipus,
	   -- CHARACTER_MAXIMUM_LENGTH,   NUMERIC_PRECISION,
	    ISNULL(CHARACTER_MAXIMUM_LENGTH,NUMERIC_PRECISION) oszlop_hossz		
FROM INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME ='kl_tabla') d FULL OUTER JOIN
(SELECT 'xls' as forr, FORR_AZ
      ,SEMA
      ,TABLA_NEV
      ,OSZLOP_NEV
      ,OSZLOP_TIPUS
      ,OSZLOP_HOSSZ    
  FROM DW_MASTER_TABLE where TABLA_NEV ='kl_tabla') x
  on 1=1
  and d.FORR_AZ = x.FORR_AZ 
  and d.SEMA = x.SEMA
  and d.TABLA_NEV = x.TABLA_NEV
  and d.OSZLOP_NEV = x.OSZLOP_NEV
  and d.OSZLOP_TIPUS = x.OSZLOP_TIPUS
  where d.OSZLOP_NEV is null  --- hiányzó tábla oszlop (ami nincs legenerálva)
  
  -- and d.OSZLOP_HOSSZ  = and x.OSZLOP_HOSSZ 
  -- teszt módosítás a xls forrásban
  ---update DW_MASTER_TABLE set OSZLOP_NEV ='nev2' where TABLA_NEV ='kl_tabla' and OSZLOP_NEV ='nev' -- eltérés létrehozása
  ---update DW_MASTER_TABLE set OSZLOP_NEV ='nev' where TABLA_NEV ='kl_tabla' and OSZLOP_NEV ='nev2' -- eltérés megszüntetése
  
  insert into dw_master_log 
select 0 as ossz_db, 0 as tolt_db, 'MEZO_ELL' as tipus, 'klajos' as tmej,
 x.forr_az, x.sema, x.tabla_nev , x.OSZLOP_NEV, getdate() as datum
 from 
(SELECT 'db' as forr,'kl_db' as forr_az, TABLE_SCHEMA as sema, TABLE_NAME as tabla_nev, COLUMN_NAME as oszlop_nev, --ORDINAL_POSITION,
       DATA_TYPE as oszlop_tipus,
	   -- CHARACTER_MAXIMUM_LENGTH,   NUMERIC_PRECISION,
	    ISNULL(CHARACTER_MAXIMUM_LENGTH,NUMERIC_PRECISION) oszlop_hossz		
FROM INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME ='kl_tabla') d FULL OUTER JOIN
(SELECT 'xls' as forr, FORR_AZ
      ,SEMA
      ,TABLA_NEV
      ,OSZLOP_NEV
      ,OSZLOP_TIPUS
      ,OSZLOP_HOSSZ    
  FROM DW_MASTER_TABLE where TABLA_NEV ='kl_tabla') x
  on 1=1
  and d.FORR_AZ = x.FORR_AZ 
  and d.SEMA = x.SEMA
  and d.TABLA_NEV = x.TABLA_NEV
  and d.OSZLOP_NEV = x.OSZLOP_NEV
  and d.OSZLOP_TIPUS = x.OSZLOP_TIPUS
  where d.OSZLOP_NEV is null  --- hiányzó tábla oszlop (ami nincs legenerálva)
  
--3 Táblázat FK meglétének ellenõrzése  
  select FORR_AZ, SEMA, TABLA_NEV ,FK_TABLA, FK_TABLA_OSZLOP from DW_MASTER_TABLE 
  where FK_TABLA_OSZLOP IS NOT NULL and TABLA_NEV like 'kl_tabla%'
  --
 select FORR_AZ, 
  SEMA, TABLA_NEV ,OSZLOP_NEV, FK_TABLA, FK_TABLA_OSZLOP from DW_MASTER_TABLE 
  where FK_TABLA_OSZLOP IS NOT NULL and TABLA_NEV like 'kl_tabla%'
  union

SELECT 'kl_db' as forr_az, -- obj.name AS FK_NAME,
    sch.name AS sema,
    tab1.name AS tabla_nev,
    col1.name AS oszlop_nev,
    tab2.name AS fk_tabla,
    col2.name AS fk_tabla_oszlop
FROM sys.foreign_key_columns fkc
INNER JOIN sys.objects obj
    ON obj.object_id = fkc.constraint_object_id
INNER JOIN sys.tables tab1
    ON tab1.object_id = fkc.parent_object_id
INNER JOIN sys.schemas sch
    ON tab1.schema_id = sch.schema_id
INNER JOIN sys.columns col1
    ON col1.column_id = parent_column_id AND col1.object_id = tab1.object_id
INNER JOIN sys.tables tab2
    ON tab2.object_id = fkc.referenced_object_id
INNER JOIN sys.columns col2
    ON col2.column_id = referenced_column
---- végleges
  select x.*, d.* from 
  (select FORR_AZ, 
  SEMA, TABLA_NEV ,OSZLOP_NEV, FK_TABLA, FK_TABLA_OSZLOP from DW_MASTER_TABLE 
  where FK_TABLA_OSZLOP IS NOT NULL and TABLA_NEV like 'kl_tabla%') x
  FULL OUTER JOIN 
(SELECT 'kl_db' as forr_az, -- obj.name AS FK_NAME,
    sch.name AS sema,
    tab1.name AS tabla_nev,
    col1.name AS oszlop_nev,
    tab2.name AS fk_tabla,
    col2.name AS fk_tabla_oszlop
FROM sys.foreign_key_columns fkc
INNER JOIN sys.objects obj
    ON obj.object_id = fkc.constraint_object_id
INNER JOIN sys.tables tab1
    ON tab1.object_id = fkc.parent_object_id
INNER JOIN sys.schemas sch
    ON tab1.schema_id = sch.schema_id
INNER JOIN sys.columns col1
    ON col1.column_id = parent_column_id AND col1.object_id = tab1.object_id
INNER JOIN sys.tables tab2
    ON tab2.object_id = fkc.referenced_object_id
INNER JOIN sys.columns col2
    ON col2.column_id = referenced_column_id AND col2.object_id = tab2.object_id) d
on 1=1
  and d.FORR_AZ = x.FORR_AZ 
  and d.SEMA = x.SEMA
  and d.TABLA_NEV = x.TABLA_NEV
  and d.OSZLOP_NEV = x.OSZLOP_NEV
    and d.fk_tabla = x.fk_tabla
  and d.fk_tabla_oszlop = x.fk_tabla_oszlop
  
    -- teszt módosítás a xls forrásban  FK_TABLA, FK_TABLA_OSZLOP
--- update DW_MASTER_TABLE set FK_TABLA_OSZLOP ='' , FK_TABLA = 'kl_tabla2' where TABLA_NEV ='kl_tabla' and OSZLOP_NEV ='id'
--- update DW_MASTER_TABLE set FK_TABLA_OSZLOP ='id' , FK_TABLA = 'kl_tabla' where TABLA_NEV ='kl_tabla2' and OSZLOP_NEV ='id2' -- jó beszúrás
  
----4   Az FK mezõ -1 érték elõfordulás megszámolása ciklus
--- végleges -1 figyelés
    DECLARE db_cursor CURSOR FOR select -- FORR_AZ,   SEMA, TABLA_NEV ,OSZLOP_NEV, 
  'insert into dw_master_log select count(1) as ossz_db, count('+ OSZLOP_NEV +') as tolt_db, ''PK -1'' as tipus, ''klajos'' as tmej,
  '''+ FORR_AZ + ''' as FORR_AZ,
  '''+ SEMA +''' as SEMA,
 '''+ TABLA_NEV +''' as TABLA_NEV,
 '''+ OSZLOP_NEV +''' as OSZLOP_NEV, getdate() as datum
   from ' + TABLA_NEV + ' where '+ OSZLOP_NEV +'= -1 ;' as sql_paracs
  from DW_MASTER_TABLE 
  where FK_TABLA_OSZLOP IS NOT NULL 
  and FK_TABLA_OSZLOP IS NOT NULL 
  and TABLA_NEV like 'kl_tabla%'
  ;
DECLARE @sql_parancs VARCHAR(2000);
OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @sql_parancs; 
WHILE @@FETCH_STATUS = 0  
BEGIN  
--	    select @sql_parancs;  -- sql_parancs listázás
       -- sql_parancs futtatása
	   EXECUTE (@sql_parancs)
--	   EXECUTE sp_executesql @sql_parancs, ''

       FETCH NEXT FROM db_cursor INTO @sql_parancs; -- léptetés
END;
CLOSE db_cursor;
DEALLOCATE db_cursor;
--commit

---- PK vizsgálat

DECLARE db_cursor CURSOR FOR select -- FORR_AZ,   SEMA, TABLA_NEV ,OSZLOP_NEV, 
  'insert into dw_master_log select count(1) as ossz_db, count('+ OSZLOP_NEV +') as tolt_db, ''PK tölt'' as tipus, ''klajos'' as tmej,
  '''+ FORR_AZ + ''' as FORR_AZ,
  '''+ SEMA +''' as SEMA,
 '''+ TABLA_NEV +''' as TABLA_NEV,
 '''+ OSZLOP_NEV +''' as OSZLOP_NEV, getdate() as datum
   from ' + TABLA_NEV + ' ;' as sql_paracs
  from DW_MASTER_TABLE 
  where PK ='Y'   -- PK jelzõ figyelése
  and TABLA_NEV like 'kl_tabla%'
  ;
DECLARE @sql_parancs VARCHAR(2000);
OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @sql_parancs; 
WHILE @@FETCH_STATUS = 0  
BEGIN  
--	    select @sql_parancs;  -- sql_parancs listázás
       -- sql_parancs futtatása
	   EXECUTE (@sql_parancs)
--	   EXECUTE sp_executesql @sql_parancs, ''

       FETCH NEXT FROM db_cursor INTO @sql_parancs; -- léptetés
END;
CLOSE db_cursor;
DEALLOCATE db_cursor;
--commit

----5   Mezonkénti NULL érték elõfordulás számlálása ciklus

 select FORR_AZ, 
  SEMA, TABLA_NEV ,OSZLOP_NEV, 
  ' select count(1) as ossz_db, count('+ OSZLOP_NEV +') as tolt_db from ' + TABLA_NEV + ' ;' as sql_paracs
  from DW_MASTER_TABLE 
  where FK_TABLA_OSZLOP IS NOT NULL 
  and FK_TABLA_OSZLOP IS NOT NULL 
  and TABLA_NEV like 'kl_tabla%'
  
---  végleges null -al csökkentett számlálás
  DECLARE db_cursor CURSOR FOR select -- FORR_AZ,   SEMA, TABLA_NEV ,OSZLOP_NEV, 
  'insert into dw_master_log select count(1) as ossz_db, count('+ OSZLOP_NEV +') as tolt_db, ''FK tölt'' as tipus, ''klajos'' as tmej,
  '''+ FORR_AZ + ''' as FORR_AZ,
  '''+ SEMA +''' as SEMA,
 '''+ TABLA_NEV +''' as TABLA_NEV,
 '''+ OSZLOP_NEV +''' as OSZLOP_NEV, getdate() as datum
   from ' + TABLA_NEV + ' ;' as sql_paracs
  from DW_MASTER_TABLE 
  where FK_TABLA_OSZLOP IS NOT NULL 
  and FK_TABLA_OSZLOP IS NOT NULL 
  and TABLA_NEV like 'kl_tabla%'
  ;
DECLARE @sql_parancs VARCHAR(2000);
OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @sql_parancs; 
WHILE @@FETCH_STATUS = 0  
BEGIN  
--	    select @sql_parancs;  -- sql_parancs listázás
       -- sql_parancs futtatása
	   EXECUTE (@sql_parancs)
--	   EXECUTE sp_executesql @sql_parancs, ''

       FETCH NEXT FROM db_cursor INTO @sql_parancs; -- léptetés
END;
CLOSE db_cursor;
DEALLOCATE db_cursor;
--commit



----------------------------- Infók
-- procedura lista:
SELECT 
    SchemaName = s.name,
    ProcedureName = pr.name 
FROM 
    databasename.sys.procedures pr


-- tábla és mezõ lista
SELECT * FROM sys.tables where NAME ='kl_tabla'
---
SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, ORDINAL_POSITION,
       COLUMN_DEFAULT, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH,
       NUMERIC_PRECISION, NUMERIC_PRECISION_RADIX, NUMERIC_SCALE,
       DATETIME_PRECISION
FROM INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME ='kl_tabla'
----

--- FK
SELECT  obj.name AS FK_NAME,
    sch.name AS [schema_name],
    tab1.name AS [table],
    col1.name AS [column],
    tab2.name AS [referenced_table],
    col2.name AS [referenced_column]
FROM sys.foreign_key_columns fkc
INNER JOIN sys.objects obj
    ON obj.object_id = fkc.constraint_object_id
INNER JOIN sys.tables tab1
    ON tab1.object_id = fkc.parent_object_id
INNER JOIN sys.schemas sch
    ON tab1.schema_id = sch.schema_id
INNER JOIN sys.columns col1
    ON col1.column_id = parent_column_id AND col1.object_id = tab1.object_id
INNER JOIN sys.tables tab2
    ON tab2.object_id = fkc.referenced_object_id
INNER JOIN sys.columns col2
    ON col2.column_id = referenced_column_id AND col2.object_id = tab2.object_id
--
SELECT
  object_name(parent_object_id) as tabla,
  object_name(referenced_object_id) as apa_tabla,
  name as fk_nev
FROM sys.foreign_keys
WHERE parent_object_id = object_id('kl_tabla2')


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
DECLARE @SQL NVARCHAR(200) 
SET @SQL = 'Select *, 100000000 as id from  kl_tabla' 
EXEC sp_executesql @SQL
---
DECLARE @sqlCommand nvarchar(1000)
DECLARE @city varchar(75)
declare @counts int
SET @city = 'New York'
SET @sqlCommand = 'SELECT @cnt=COUNT(*) FROM customers WHERE City = @city'
EXECUTE sp_executesql @sqlCommand, N'@city nvarchar(75),@cnt int OUTPUT', @city = @city, @cnt=@counts OUTPUT
select @counts as Counts




-----------------
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
-------------
INSERT INTO Customers (CustomerName, Country)
SELECT SupplierName, Country FROM Suppliers
WHERE Country='Germany'; 
--
Select * into kl_tabla2  from  kl_tabla

ALTER TABLE kl_tabla2
ADD CONSTRAINT fk_kl_table2
FOREIGN KEY (id2)
REFERENCES kl_tabla(id)

---- KL MSSQL 
T Service\MSSQL$SQLEXPRESS

DESKTOP-QR04FL0\SQLEXPRESS
DESKTOP-QR04FL0\SQLEXPRESS
instans name : SQLEXPRESS
db name : master
DESKTOP-QR04FL0\klajosw

jdbc:sqlserver://localhost:1433;databaseName=kl_db;

jdbc:sqlserver://DESKTOP-QR04FL0\SQLEXPRESS:1433/master

-- knime ora con : jdbc:oracle:thin:@localhost:1521/xe