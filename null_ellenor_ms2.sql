--------------------------------------  ms sql serve dw dm st modell ellenõrzés
/*
Módosítás szükséges  a konkrét generált névkonvenció szerin a táblanév, mezõnév, PK-FK név kiválásztást szerint.
Egységes LOG táblába írás a vizsgálatok elõgyûjtése amelyekre elemzõ riportok  készülhetnek.
További bõvíthetõség:
Betöltési dátumonként (Job_ID-nként, tarticionkénti, ..) elemzés futtatás 
Elemzési objektum kör bõvítése (indexek, egyéb függések megléte , be/kikapcsolt állapota, ...)
Összes érintett táblára mezõ töltötség vizsgalat kiterjesztése
/* */
----- Ellenõrzések adatbázis védelmébe behelyezése (SQL Server specifikus)
--####################################################  
--1 táblák meglétének ellenõrzése

/*
Szerzõ: Kecskeméti Lajos 2016
A DW_MASTER_TABLE tábla adatokat megkeresí az adatbázis sémájában
amit nem talál meg azt lelogolja a dw_master_log táblába.
A tipus 'TABLA_ELL' cimke lesz
*/

Create Procedure KL_tabla_ell
(
 @KL_valt Varchar(200)
) 
As
 Begin
-----
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
  --------
   End
--####################################################  
--2 Táblák mezõinek meglétének ellenõrzése  

/*
Szerzõ: Kecskeméti Lajos 2016
A DW_MASTER_TABLE tábla mezõadatokat megkeresí az adatbázis sémájában
amit nem talál meg azt lelogolja a dw_master_log táblába.
A tipus 'MEZO_ELL' cimke lesz
*/

Create Procedure KL_mezo_ell
(
 @KL_valt Varchar(200)
) 
As
----------------------
 Begin
insert into dw_master_log 
select 0 as ossz_db, 0 as tolt_db, 'MEZO_ELL' as tipus, 'klajos' as tmej,
 x.forr_az, x.sema, x.tabla_nev , x.OSZLOP_NEV, getdate() as datum
 from 
(SELECT 'db' as forr,'kl_db' as forr_az, TABLE_SCHEMA as sema, TABLE_NAME as tabla_nev, 
COLUMN_NAME as oszlop_nev, DATA_TYPE as oszlop_tipus, 
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
  --------
   End

--####################################################    
--3 Táblázat FK meglétének ellenõrzése  

/*
Szerzõ: Kecskeméti Lajos 2016
A DW_MASTER_TABLE táblában megadott FK mezõk meglétének ellenõrzése
 és lelogolása a dw_master_log táblába.
A tipus 'FK lét' cimke lesz
*/

Create Procedure KL_fk_let_ell
(
 @KL_valt Varchar(200)
) 
As
 Begin
-----
insert into dw_master_log 
select 0 as ossz_db, 0 as tolt_db, 'FK_LET_ELL' as tipus, 'klajos' as tmej,
 x.forr_az, x.sema, x.tabla_nev , x.OSZLOP_NEV, getdate() as datum
 from 
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
  where d.fk_tabla_oszlop is null
  -- commit
-----
End  
    -- teszt módosítás a xls forrásban  FK_TABLA, FK_TABLA_OSZLOP
--- update DW_MASTER_TABLE set FK_TABLA_OSZLOP ='' , FK_TABLA = 'kl_tabla2' where TABLA_NEV ='kl_tabla' and OSZLOP_NEV ='id'
--- update DW_MASTER_TABLE set FK_TABLA_OSZLOP ='id' , FK_TABLA = 'kl_tabla' where TABLA_NEV ='kl_tabla2' and OSZLOP_NEV ='id2' -- jó beszúrás


--####################################################  
----4   Az FK mezõ -1 érték elõfordulás megszámolása ciklus

/*
Szerzõ: Kecskeméti Lajos 2016
A DW_MASTER_TABLE táblában megadott FK mezõk -1 érték 
elõfordulásának megszámolása és lelogolása a dw_master_log táblába.
A tipus 'PK -1' cimke lesz
*/

Create Procedure KL_pk1_ell
(
 @KL_valt Varchar(200)
) 
As
 Begin
-----
    DECLARE db_cursor CURSOR FOR select 
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
	   EXECUTE (@sql_parancs)    -- sql_parancs futtatása
       FETCH NEXT FROM db_cursor INTO @sql_parancs; -- léptetés
END;
CLOSE db_cursor;
DEALLOCATE db_cursor;
--commit
-----
End


--####################################################  
----5 PK vizsgálat : PK mezonkénti NULL érték elõfordulás számlálása ciklus

/*
Szerzõ: Kecskeméti Lajos 2016
A DW_MASTER_TABLE táblában megadott PK mezõk NULL érték 
nélküli megszámolása és lelogolása a dw_master_log táblába.
A tipus 'PK tölt' cimke lesz
*/

Create Procedure KL_pk_ell
(
 @KL_valt Varchar(200)
) 
As
 Begin
-----
DECLARE db_cursor CURSOR FOR select 
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
	   EXECUTE (@sql_parancs)  -- sql_parancs futtatása
       FETCH NEXT FROM db_cursor INTO @sql_parancs; -- léptetés
END;
CLOSE db_cursor;
DEALLOCATE db_cursor;
--commit
-----
End

--####################################################  
----6   FK vizsgálat : FK mezonkénti NULL érték elõfordulás számlálása ciklus
  
/*
Szerzõ: Kecskeméti Lajos 2016
A DW_MASTER_TABLE táblában megadott FK mezõk NULL érték 
nélküli megszámolása és lelogolása a dw_master_log táblába.
A tipus 'FK tölt' cimke lesz
*/

Create Procedure KL_fk_ell
(
 @KL_valt Varchar(200)
) 
As
 Begin
-----
  DECLARE db_cursor CURSOR FOR select 
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
	   EXECUTE (@sql_parancs)  -- sql_parancs futtatása
       FETCH NEXT FROM db_cursor INTO @sql_parancs; -- léptetés
END;
CLOSE db_cursor;
DEALLOCATE db_cursor;
--commit
-----
End

-------------------------------------------------------------------  VÉGE -----------------------------------------
