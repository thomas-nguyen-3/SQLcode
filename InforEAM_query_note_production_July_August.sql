--------------****************************************--------------------------
--------- Title: 
--------- Note:
--------------****************************************--------------------------

--------------****************************************--------------------------
--------------*******************END******************--------------------------
--------------****************************************--------------------------

--------------****************************************--------------------------
--------- Title: this query to find out your 5 biggest tables
--------- Note: this MySQL query
--------------****************************************--------------------------


SELECT table_schema,table_name,data_length,index_length
FROM information_schema.tables ORDER BY data_length DESC LIMIT 5;

#then follow up: to conver to gb
select num,format(num/power(1024,3),2) num_gb
   from (
   
  select 31443922568 num union
  select 18475909120 union
    select 14050918400 union
    select 13175286880 union
    select 8841349516
    ) A;
--------------****************************************--------------------------
--------------*******************END******************--------------------------
--------------****************************************--------------------------


--------------****************************************--------------------------
--------- Title: Query Checking : use regularly
--------- Note: SOME OF THE CHECK ROUTINES THAT WILL NEED TO AUTOMATIZE AS DAILY SCHEDULE
--------------****************************************--------------------------


-------- Title: CHECK POS .. IF '+" CHANGE "COVERAGE" TO CONTRACT
--------- Note: (need to work on the auto schedule)
SELECT * from R5OBJECTS WHERE OBJ_UDFCHKBOX01 != '-';


--------- Title: update the PM WO with status "finished' (FIN)
--------- Note: need to update this to avoid duplicate for Pm WO

--CHECK QUERY:
select * from r5events where evt_type = 'PPM' and evt_status = 'FIN' order by evt_date desc;
select evt_code,evt_desc,evt_type,evt_status, evt_completed from r5events where evt_type = 'PPM' and evt_status = 'FIN' order by evt_date desc;

-- update statement
UPDATE EAM.R5EVENTS
SET evt_status = 'CPM'
WHERE evt_type = 'PPM' and evt_status = 'FIN' ;


--------- Title: update the DateReported by eUpdate Start time 
--------- Note: ONLY COSIDER 'FMI', 'PM', 'UPGRADE'

-- CHECKING QUERY TO SEE IF SUCH WO EXISTS
		SELECT  P.PRV_CODE, P.PRV_DVALUE
		FROM EAM.R5PROPERTYVALUES P
		JOIN EAM.R5EVENTS EVT
		ON P.PRV_CODE = EVT.EVT_CODE AND P.PRV_PROPERTY = 'EUPDATE' AND P.PRV_DVALUE IS NOT NULL AND TO_CHAR(P.prv_dvalue, 'hh24:mi') != '00:00' AND P.prv_dvalue != EVT.EVT_REPORTED 
    AND (EVT.EVT_JOBTYPE = 'FMI' or EVT.EVT_JOBTYPE = 'PM' or EVT.EVT_JOBTYPE = 'Upgrade' )
		ORDER BY PRV_DVALUE DESC


-- UPDATE STATEMENT 

DECLARE
  --i NUMBER := 1;
  workorder EAM.R5EVENTS.EVT_CODE%TYPE;
  eupdate EAM.R5PROPERTYVALUES.PRV_DVALUE%TYPE;
BEGIN
  FOR item IN (
		SELECT  P.PRV_CODE, P.PRV_DVALUE
		FROM EAM.R5PROPERTYVALUES P
		JOIN EAM.R5EVENTS EVT
		ON P.PRV_CODE = EVT.EVT_CODE AND P.PRV_PROPERTY = 'EUPDATE' AND P.PRV_DVALUE IS NOT NULL AND TO_CHAR(P.prv_dvalue, 'hh24:mi') != '00:00' AND P.prv_dvalue != EVT.EVT_REPORTED 
    AND (EVT.EVT_JOBTYPE = 'FMI' or EVT.EVT_JOBTYPE = 'PM' or EVT.EVT_JOBTYPE = 'Upgrade' )
		ORDER BY PRV_DVALUE DESC
  ) 
  LOOP
  --DBMS_OUTPUT.PUT_LINE ('item: ' || i || ':  ' || item.EVT_CODE);
  SELECT EVT_CODE INTO workorder FROM EAM.R5EVENTS WHERE EVT_CODE = item.PRV_CODE;
  SELECT PRV_DVALUE INTO eupdate FROM EAM.R5PROPERTYVALUES WHERE PRV_CODE = item.PRV_CODE AND PRV_PROPERTY = 'EUPDATE';
  --DBMS_OUTPUT.PUT_LINE (time_reported);
  --DBMS_OUTPUT.PUT_LINE ('WO are:  ' ||workorder ||'  eupdate = ' || TO_CHAR(eupdate, 'yyyy/mm/dd hh24:mi') );
  --DBMS_OUTPUT.PUT_LINE (workorder ||'  ' ||time_reported);
  UPDATE EAM.R5EVENTS
  SET EVT_REPORTED = eupdate
  WHERE EVT_CODE = workorder;
  --i:= i+1;
  END LOOP;
END;


--------------****************************************--------------------------
--------------*******************END******************--------------------------
--------------****************************************--------------------------


--------------****************************************--------------------------
--------- Title: Missing Site_ ID update statment
--------- Note: reason for mising: empty value in one of the transfer fields. and some unknown reason.
--------------****************************************--------------------------


----- Title: Asset Checking query
------ Note: to verify if any of the (transfer) fields exist 
SELECT 
O.OBJ_CODE Equipment,
O.OBJ_CODE,
SQL_142.prv_value ASSET_NAME,
obj_manufactmodel SiteID,
o.obj_class Modality,
o.obj_manufact Service_Vendor,
SQL_160.prv_value OEM,
SQL_147.prv_value DOMAIN,
SQL_161.prv_value CLINIC_AREA,
SQL_163.prv_value FLOOR,
SQL_139.prv_value ROMENAME,
O.OBJ_VARIABLE3 MF_Hrs_of_Ops,
OBJ_VARIABLE4 SA_Hrs_of_Ops,
OBJ_VARIABLE5 SU_Hrs_of_Ops,
OBJ_VARIABLE6 WK_Hrs_of_Ops,
OBJ_UDFCHAR01 C_Hrs_MF
FROM r5objects o, 
r5propertyvalues SQL_139, r5propertyvalues SQL_147, r5propertyvalues SQL_142, r5propertyvalues SQL_160, r5propertyvalues SQL_161, r5propertyvalues SQL_163
WHERE
obj_code||'#'||obj_org=SQL_147.prv_code(+) and (SQL_147.prv_rentity(+) = 'OBJ') and (SQL_147.prv_property(+)='DOMAIN') and 
obj_code||'#'||obj_org=SQL_139.prv_code(+) and (SQL_139.prv_rentity(+) = 'OBJ') and (SQL_139.prv_property(+)='ROOMNAME') and 
obj_code||'#'||obj_org=SQL_160.prv_code(+) and (SQL_160.prv_rentity(+) = 'OBJ') and (SQL_160.prv_property(+)='OEM') and 
obj_code||'#'||obj_org=SQL_142.prv_code(+) and (SQL_142.prv_rentity(+) = 'OBJ') and (SQL_142.prv_property(+)='ASSETNAM') and
obj_code||'#'||obj_org=SQL_161.prv_code(+) and (SQL_161.prv_rentity(+) = 'OBJ') and (SQL_161.prv_property(+)='CLINIC') and 
obj_code||'#'||obj_org=SQL_163.prv_code(+) and (SQL_163.prv_rentity(+) = 'OBJ') and (SQL_163.prv_property(+)='FLOOR') AND
--OBJ_CODE IN (SELECT EVT_OBJECT FROM R5EVENTS WHERE EVT_RTYPE IN ( 'JOB', 'PPM') AND (EVT_CODE = 62786 ))
OBJ_CODE IN (SELECT EVT_OBJECT FROM R5EVENTS WHERE EVT_RTYPE IN ( 'JOB', 'PPM') AND (EVT_CODE = 62786 OR EVT_CODE = 62940))
;


----- Title: WO Checking query
------ Note: TO MAKE SURE THESE WO FIELDS ARE INDEED EMPTY 
------ Note: AFTER UPDATE, CHECK AGAIN, THERE SHOULD BE 14 FIELDS
SELECT * FROM R5PROPERTYVALUES WHERE
(PRV_CODE = '63040') AND
--(PRV_CODE = '62786' or PRV_CODE = '62940') AND
( PRV_PROPERTY = 'SITEID'
OR PRV_PROPERTY = 'SAHRS'
OR PRV_PROPERTY = 'SUHRS'
OR PRV_PROPERTY = 'VENDOR'
OR PRV_PROPERTY = 'MODALITY'
OR PRV_PROPERTY = 'WKHRS'
OR PRV_PROPERTY = 'MFHRS'
OR PRV_PROPERTY = 'CHRSMF'
OR PRV_PROPERTY = 'ROOM'
OR PRV_PROPERTY = 'ASSETNAM'
OR PRV_PROPERTY = 'OEM'
OR PRV_PROPERTY = 'DOMAIN'
OR PRV_PROPERTY = 'CLINIC'
OR PRV_PROPERTY = 'FLOOR')
ORDER BY PRV_PROPERTY
;


----- Title: WO Checking query - LONG VERSION
------ Note: TO MAKE SURE THESE WO FIELDS ARE INDEED EMPTY 
SELECT E.EVT_CODE,
O.OBJ_CODE Equipment, 
SQL_48.prv_value Asset_Name,
SQL_109.prv_value Site_ID,

SQL_41.prv_value MODALITY,
SQL_47.prv_value VENDOR,
SQL_98.prv_value OEM,
SQL_96.prv_value DOMAIN,
SQL_45.prv_value CLINIC,
SQL_40.prv_value FLOOR,
SQL_43.prv_value ROOM_NAME,
SQL_120.prv_value MFHRS,
SQL_121.prv_value SAHRS,
SQL_122.prv_value SUHRS,
SQL_123.prv_value WKHRS,
SQL_124.prv_value CHRSMF


from r5events e, r5activities a, r5objects o, r5addetails ad,
R5PROPERTYVALUES SQL_48,R5PROPERTYVALUES SQL_109,R5PROPERTYVALUES SQL_41,R5PROPERTYVALUES SQL_47,R5PROPERTYVALUES SQL_98,R5PROPERTYVALUES SQL_96,R5PROPERTYVALUES SQL_45,
R5PROPERTYVALUES SQL_40,R5PROPERTYVALUES SQL_43,R5PROPERTYVALUES SQL_120,R5PROPERTYVALUES SQL_121,R5PROPERTYVALUES SQL_122,R5PROPERTYVALUES SQL_123,R5PROPERTYVALUES SQL_124
where
   e.evt_rstatus IN ('Q', 'R', 'C') 
AND        e.evt_rtype IN ('JOB', 'PPM')
AND e.evt_code = a.act_event (+)
AND e.evt_object = o.obj_code(+)
AND e.evt_object_org = o.obj_org(+)
AND       (a.act_act is null or a.act_act=(select min(b.act_act) from r5activities b where b.act_event=a.act_event) )
   
AND AD.ADD_LINE(+) = A.act_act AND a.act_event || '#10' = AD.ADD_CODE(+)
          AND E.EVT_STATUS <> 'A'
          AND E.EVT_STATUS <> 'REJ'              
          AND E.EVT_STATUS <> 'RJDD'

and (evt_code=SQL_48.prv_code(+) and SQL_48.prv_rentity(+) = 'EVNT' and SQL_48.prv_property(+)='ASSETNAM')
and (evt_code=SQL_109.prv_code(+) and SQL_109.prv_rentity(+) = 'EVNT' and SQL_109.prv_property(+)='SITEID')
and (evt_code=SQL_41.prv_code(+) and  SQL_41.prv_rentity(+) = 'EVNT' and SQL_41.prv_property(+)='MODALITY')
and (evt_code=SQL_47.prv_code(+) and SQL_47.prv_rentity(+) = 'EVNT' and SQL_47.prv_property(+)='VENDOR')
and (evt_code=SQL_98.prv_code(+) and SQL_98.prv_rentity(+) = 'EVNT' and SQL_98.prv_property(+)='OEM')
and (evt_code=SQL_96.prv_code(+) and SQL_96.prv_rentity(+) = 'EVNT' and SQL_96.prv_property(+)='DOMAIN')
and (evt_code=SQL_45.prv_code(+) and SQL_45.prv_rentity(+) = 'EVNT' and SQL_45.prv_property(+)='CLINIC')
and (evt_code=SQL_40.prv_code(+) and SQL_40.prv_rentity(+) = 'EVNT' and SQL_40.prv_property(+)='FLOOR')
and (evt_code=SQL_43.prv_code(+) and SQL_43.prv_rentity(+) = 'EVNT' and SQL_43.prv_property(+)='ROOM')
and (evt_code=SQL_120.prv_code(+) and SQL_120.prv_rentity(+) = 'EVNT' and SQL_120.prv_property(+)='MFHRS')
and (evt_code=SQL_121.prv_code(+) and SQL_121.prv_rentity(+) = 'EVNT' and SQL_121.prv_property(+)='SAHRS')
and (evt_code=SQL_122.prv_code(+) and SQL_122.prv_rentity(+) = 'EVNT' and SQL_122.prv_property(+)='SUHRS')
and (evt_code=SQL_123.prv_code(+) and SQL_123.prv_rentity(+) = 'EVNT' and SQL_123.prv_property(+)='WKHRS')
and (evt_code=SQL_124.prv_code(+) and SQL_124.prv_rentity(+) = 'EVNT' and SQL_124.prv_property(+)='CHRSMF')
AND (EVT_CODE = 62786 OR EVT_CODE = 62940);


-- UPDATE STATEMENT (INCLUDE ALL FIELDS)

DECLARE
--ADD THE WO NUMBER HERE ABER THE :=
WOCODE R5EVENTS.EVT_CODE%TYPE := '59252';
WOOBJECT R5EVENTS.EVT_OBJECT%TYPE;
TIME_REPORTED EAM.R5EVENTS.EVT_REPORTED%TYPE;

SITE_ID 	R5OBJECTS.OBJ_MANUFACTMODEL%TYPE;
SA_HRS 	R5OBJECTS.OBJ_VARIABLE4%TYPE;
SU_HRS 	R5OBJECTS.OBJ_VARIABLE5%TYPE;
VENDOR 	R5OBJECTS.OBJ_MANUFACT%TYPE;
MODALITY 	R5OBJECTS.OBJ_CLASS%TYPE;
WKHRS 	R5OBJECTS.OBJ_VARIABLE6%TYPE;
MF_HRS 	R5OBJECTS.OBJ_VARIABLE3%TYPE;
CHRSMF 	R5OBJECTS.OBJ_UDFCHAR01%TYPE;
ROOM 			R5PROPERTYVALUES.PRV_VALUE%TYPE;
ANAME 		R5PROPERTYVALUES.PRV_VALUE%TYPE;
OEM 			R5PROPERTYVALUES.PRV_VALUE%TYPE;
DNAME 		R5PROPERTYVALUES.PRV_VALUE%TYPE;
CLINIC_AREA 	R5PROPERTYVALUES.PRV_VALUE%TYPE;
FLOOR1 		R5PROPERTYVALUES.PRV_VALUE%TYPE;

BEGIN
--get the equipment name (EVT_OBJECT) from the R5EVENTS table given WO number
SELECT EVT_REPORTED, EVT_OBJECT INTO TIME_REPORTED, WOOBJECT FROM R5EVENTS WHERE EVT_CODE = WOCODE;
--get the non-custom field values
SELECT OBJ_MANUFACTMODEL, OBJ_VARIABLE4, OBJ_VARIABLE5,  OBJ_MANUFACT, OBJ_CLASS, OBJ_VARIABLE6, OBJ_VARIABLE3, OBJ_UDFCHAR01
	INTO SITE_ID, SA_HRS, SU_HRS, VENDOR, MODALITY, WKHRS, MF_HRS, CHRSMF FROM R5OBJECTS WHERE OBJ_CODE=WOOBJECT;
--get the custom field value
SELECT PRV_VALUE INTO ROOM 		FROM R5PROPERTYVALUES WHERE PRV_CODE=WOOBJECT||'#*' AND PRV_RENTITY='OBJ' AND PRV_PROPERTY='ROOMNAME';
SELECT PRV_VALUE INTO ANAME		FROM R5PROPERTYVALUES WHERE PRV_CODE=WOOBJECT||'#*' AND PRV_RENTITY='OBJ' AND PRV_PROPERTY='ASSETNAM';
SELECT PRV_VALUE INTO OEM			FROM R5PROPERTYVALUES WHERE PRV_CODE=WOOBJECT||'#*' AND PRV_RENTITY='OBJ' AND PRV_PROPERTY='OEM';
SELECT PRV_VALUE INTO DNAME		FROM R5PROPERTYVALUES WHERE PRV_CODE=WOOBJECT||'#*' AND PRV_RENTITY='OBJ' AND PRV_PROPERTY='DOMAIN';
SELECT PRV_VALUE INTO CLINIC_AREA	FROM R5PROPERTYVALUES WHERE PRV_CODE=WOOBJECT||'#*' AND PRV_RENTITY='OBJ' AND PRV_PROPERTY='CLINIC';
SELECT PRV_VALUE INTO FLOOR1		FROM R5PROPERTYVALUES WHERE PRV_CODE=WOOBJECT||'#*' AND PRV_RENTITY='OBJ' AND PRV_PROPERTY='FLOOR';

IF 
SITE_ID  		IS NOT NULL AND SA_HRS	IS NOT NULL AND SU_HRS  		IS NOT NULL AND VENDOR	IS NOT NULL AND MODALITY	IS NOT NULL 
AND WKHRS   	IS NOT NULL AND MF_HRS  	IS NOT NULL AND CHRSMF      	IS NOT NULL AND ROOM      	IS NOT NULL AND ANAME 	IS NOT NULL 
AND OEM     	IS NOT NULL AND DNAME   	IS NOT NULL AND CLINIC_AREA 	IS NOT NULL AND FLOOR1    	IS NOT NULL 
THEN
--DBMS_OUTPUT.PUT_LINE ( SITE_ID||'   ' || TIME_REPORTED ||'   ' ||  SA_HRS||'   ' || SU_HRS||'   ' || VENDOR||'   ' || MODALITY||'   ' || WKHRS||'   ' || MF_HRS||'   ' || CHRSMF||'   ' || ROOM||'   ' || ANAME||'   ' || OEM||'   ' || DNAME||'   ' || CLINIC_AREA||'   ' || FLOOR1  );

  INSERT ALL 
INTO EAM.R5PROPERTYVALUES  (PRV_PROPERTY,PRV_RENTITY,PRV_CLASS,PRV_CODE,PRV_SEQNO,PRV_VALUE,PRV_NVALUE,PRV_DVALUE,PRV_CLASS_ORG,PRV_UPDATECOUNT,PRV_CREATED,PRV_UPDATED,PRV_NOTUSED) 
  values ('SITEID','EVNT','*',WOCODE,1,SITE_ID,null,null,'*',0,time_reported,time_reported,'-')

INTO EAM.R5PROPERTYVALUES  (PRV_PROPERTY,PRV_RENTITY,PRV_CLASS,PRV_CODE,PRV_SEQNO,PRV_VALUE,PRV_NVALUE,PRV_DVALUE,PRV_CLASS_ORG,PRV_UPDATECOUNT,PRV_CREATED,PRV_UPDATED,PRV_NOTUSED) 
  values ('SAHRS','EVNT','*',WOCODE,1,SA_HRS,null,null,'*',0,time_reported,time_reported,'-')

INTO EAM.R5PROPERTYVALUES  (PRV_PROPERTY,PRV_RENTITY,PRV_CLASS,PRV_CODE,PRV_SEQNO,PRV_VALUE,PRV_NVALUE,PRV_DVALUE,PRV_CLASS_ORG,PRV_UPDATECOUNT,PRV_CREATED,PRV_UPDATED,PRV_NOTUSED) 
  values ('SUHRS','EVNT','*',WOCODE,1,SU_HRS,null,null,'*',0,time_reported,time_reported,'-')

INTO EAM.R5PROPERTYVALUES  (PRV_PROPERTY,PRV_RENTITY,PRV_CLASS,PRV_CODE,PRV_SEQNO,PRV_VALUE,PRV_NVALUE,PRV_DVALUE,PRV_CLASS_ORG,PRV_UPDATECOUNT,PRV_CREATED,PRV_UPDATED,PRV_NOTUSED) 
  values ('VENDOR','EVNT','*',WOCODE,1,VENDOR,null,null,'*',0,time_reported,time_reported,'-')

INTO EAM.R5PROPERTYVALUES  (PRV_PROPERTY,PRV_RENTITY,PRV_CLASS,PRV_CODE,PRV_SEQNO,PRV_VALUE,PRV_NVALUE,PRV_DVALUE,PRV_CLASS_ORG,PRV_UPDATECOUNT,PRV_CREATED,PRV_UPDATED,PRV_NOTUSED) 
  values ('MODALITY','EVNT','*',WOCODE,1,MODALITY,null,null,'*',0,time_reported,time_reported,'-')

INTO EAM.R5PROPERTYVALUES  (PRV_PROPERTY,PRV_RENTITY,PRV_CLASS,PRV_CODE,PRV_SEQNO,PRV_VALUE,PRV_NVALUE,PRV_DVALUE,PRV_CLASS_ORG,PRV_UPDATECOUNT,PRV_CREATED,PRV_UPDATED,PRV_NOTUSED) 
  values ('WKHRS','EVNT','*',WOCODE,1,WKHRS,null,null,'*',0,time_reported,time_reported,'-')

INTO EAM.R5PROPERTYVALUES  (PRV_PROPERTY,PRV_RENTITY,PRV_CLASS,PRV_CODE,PRV_SEQNO,PRV_VALUE,PRV_NVALUE,PRV_DVALUE,PRV_CLASS_ORG,PRV_UPDATECOUNT,PRV_CREATED,PRV_UPDATED,PRV_NOTUSED) 
  values ('MFHRS','EVNT','*',WOCODE,1,MF_HRS,null,null,'*',0,time_reported,time_reported,'-')

INTO EAM.R5PROPERTYVALUES  (PRV_PROPERTY,PRV_RENTITY,PRV_CLASS,PRV_CODE,PRV_SEQNO,PRV_VALUE,PRV_NVALUE,PRV_DVALUE,PRV_CLASS_ORG,PRV_UPDATECOUNT,PRV_CREATED,PRV_UPDATED,PRV_NOTUSED) 
  values ('CHRSMF','EVNT','*',WOCODE,1,CHRSMF,null,null,'*',0,time_reported,time_reported,'-')

INTO EAM.R5PROPERTYVALUES  (PRV_PROPERTY,PRV_RENTITY,PRV_CLASS,PRV_CODE,PRV_SEQNO,PRV_VALUE,PRV_NVALUE,PRV_DVALUE,PRV_CLASS_ORG,PRV_UPDATECOUNT,PRV_CREATED,PRV_UPDATED,PRV_NOTUSED) 
  values ('ROOM','EVNT','*',WOCODE,1,ROOM,null,null,'*',0,time_reported,time_reported,'-')

INTO EAM.R5PROPERTYVALUES  (PRV_PROPERTY,PRV_RENTITY,PRV_CLASS,PRV_CODE,PRV_SEQNO,PRV_VALUE,PRV_NVALUE,PRV_DVALUE,PRV_CLASS_ORG,PRV_UPDATECOUNT,PRV_CREATED,PRV_UPDATED,PRV_NOTUSED) 
  values ('ASSETNAM','EVNT','*',WOCODE,1,ANAME,null,null,'*',0,time_reported,time_reported,'-')

INTO EAM.R5PROPERTYVALUES  (PRV_PROPERTY,PRV_RENTITY,PRV_CLASS,PRV_CODE,PRV_SEQNO,PRV_VALUE,PRV_NVALUE,PRV_DVALUE,PRV_CLASS_ORG,PRV_UPDATECOUNT,PRV_CREATED,PRV_UPDATED,PRV_NOTUSED) 
  values ('OEM','EVNT','*',WOCODE,1,OEM,null,null,'*',0,time_reported,time_reported,'-')

INTO EAM.R5PROPERTYVALUES  (PRV_PROPERTY,PRV_RENTITY,PRV_CLASS,PRV_CODE,PRV_SEQNO,PRV_VALUE,PRV_NVALUE,PRV_DVALUE,PRV_CLASS_ORG,PRV_UPDATECOUNT,PRV_CREATED,PRV_UPDATED,PRV_NOTUSED) 
  values ('DOMAIN','EVNT','*',WOCODE,1,DNAME,null,null,'*',0,time_reported,time_reported,'-')

INTO EAM.R5PROPERTYVALUES  (PRV_PROPERTY,PRV_RENTITY,PRV_CLASS,PRV_CODE,PRV_SEQNO,PRV_VALUE,PRV_NVALUE,PRV_DVALUE,PRV_CLASS_ORG,PRV_UPDATECOUNT,PRV_CREATED,PRV_UPDATED,PRV_NOTUSED) 
  values ('CLINIC','EVNT','*',WOCODE,1,CLINIC_AREA,null,null,'*',0,time_reported,time_reported,'-')

INTO EAM.R5PROPERTYVALUES  (PRV_PROPERTY,PRV_RENTITY,PRV_CLASS,PRV_CODE,PRV_SEQNO,PRV_VALUE,PRV_NVALUE,PRV_DVALUE,PRV_CLASS_ORG,PRV_UPDATECOUNT,PRV_CREATED,PRV_UPDATED,PRV_NOTUSED) 
  values ('FLOOR','EVNT','*',WOCODE,1,FLOOR1,null,null,'*',0,time_reported,time_reported,'-')

SELECT 1 FROM DUAL;

END IF;
EXCEPTION
WHEN OTHERS THEN NULL;
END;



-- UPDATE STATEMENT (FOR WO WITH EMPTY ROOM AND ASSET_NAME FIELD)

DECLARE
--ADD THE WO NUMBER HERE ABER THE :=
WOCODE R5EVENTS.EVT_CODE%TYPE := '62940';
WOOBJECT R5EVENTS.EVT_OBJECT%TYPE;
TIME_REPORTED EAM.R5EVENTS.EVT_REPORTED%TYPE;

SITE_ID 	R5OBJECTS.OBJ_MANUFACTMODEL%TYPE;
SA_HRS 	R5OBJECTS.OBJ_VARIABLE4%TYPE;
SU_HRS 	R5OBJECTS.OBJ_VARIABLE5%TYPE;
VENDOR 	R5OBJECTS.OBJ_MANUFACT%TYPE;
MODALITY 	R5OBJECTS.OBJ_CLASS%TYPE;
WKHRS 	R5OBJECTS.OBJ_VARIABLE6%TYPE;
MF_HRS 	R5OBJECTS.OBJ_VARIABLE3%TYPE;
CHRSMF 	R5OBJECTS.OBJ_UDFCHAR01%TYPE;
ROOM 			R5PROPERTYVALUES.PRV_VALUE%TYPE;
ANAME 		R5PROPERTYVALUES.PRV_VALUE%TYPE;
OEM 			R5PROPERTYVALUES.PRV_VALUE%TYPE;
DNAME 		R5PROPERTYVALUES.PRV_VALUE%TYPE;
CLINIC_AREA 	R5PROPERTYVALUES.PRV_VALUE%TYPE;
FLOOR1 		R5PROPERTYVALUES.PRV_VALUE%TYPE;

BEGIN
--get the equipment name (EVT_OBJECT) from the R5EVENTS table given WO number
SELECT EVT_REPORTED, EVT_OBJECT INTO TIME_REPORTED, WOOBJECT FROM R5EVENTS WHERE EVT_CODE = WOCODE;
--get the non-custom field values
SELECT OBJ_MANUFACTMODEL, OBJ_VARIABLE4, OBJ_VARIABLE5,  OBJ_MANUFACT, OBJ_CLASS, OBJ_VARIABLE6, OBJ_VARIABLE3, OBJ_UDFCHAR01
	INTO SITE_ID, SA_HRS, SU_HRS, VENDOR, MODALITY, WKHRS, MF_HRS, CHRSMF FROM R5OBJECTS WHERE OBJ_CODE=WOOBJECT;
--get the custom field value
--SELECT PRV_VALUE INTO ROOM 		FROM R5PROPERTYVALUES WHERE PRV_CODE=WOOBJECT||'#*' AND PRV_RENTITY='OBJ' AND PRV_PROPERTY='ROOMNAME';
--SELECT PRV_VALUE INTO ANAME		FROM R5PROPERTYVALUES WHERE PRV_CODE=WOOBJECT||'#*' AND PRV_RENTITY='OBJ' AND PRV_PROPERTY='ASSETNAM';
SELECT PRV_VALUE INTO OEM			FROM R5PROPERTYVALUES WHERE PRV_CODE=WOOBJECT||'#*' AND PRV_RENTITY='OBJ' AND PRV_PROPERTY='OEM';
SELECT PRV_VALUE INTO DNAME		FROM R5PROPERTYVALUES WHERE PRV_CODE=WOOBJECT||'#*' AND PRV_RENTITY='OBJ' AND PRV_PROPERTY='DOMAIN';
SELECT PRV_VALUE INTO CLINIC_AREA	FROM R5PROPERTYVALUES WHERE PRV_CODE=WOOBJECT||'#*' AND PRV_RENTITY='OBJ' AND PRV_PROPERTY='CLINIC';
SELECT PRV_VALUE INTO FLOOR1		FROM R5PROPERTYVALUES WHERE PRV_CODE=WOOBJECT||'#*' AND PRV_RENTITY='OBJ' AND PRV_PROPERTY='FLOOR';

IF 
SITE_ID  		IS NOT NULL AND SA_HRS	IS NOT NULL AND SU_HRS  		IS NOT NULL AND VENDOR	IS NOT NULL AND MODALITY	IS NOT NULL 
AND WKHRS   	IS NOT NULL AND MF_HRS  	IS NOT NULL AND CHRSMF      	IS NOT NULL --AND ROOM      	IS NOT NULL AND ANAME 	IS NOT NULL 
AND OEM     	IS NOT NULL AND DNAME   	IS NOT NULL AND CLINIC_AREA 	IS NOT NULL AND FLOOR1    	IS NOT NULL 
THEN
--DBMS_OUTPUT.PUT_LINE ( SITE_ID||'   ' || TIME_REPORTED ||'   ' ||  SA_HRS||'   ' || SU_HRS||'   ' || VENDOR||'   ' || MODALITY||'   ' || WKHRS||'   ' || MF_HRS||'   ' || CHRSMF||'   ' || ROOM||'   ' || ANAME||'   ' || OEM||'   ' || DNAME||'   ' || CLINIC_AREA||'   ' || FLOOR1  );


  INSERT ALL 
INTO EAM.R5PROPERTYVALUES  (PRV_PROPERTY,PRV_RENTITY,PRV_CLASS,PRV_CODE,PRV_SEQNO,PRV_VALUE,PRV_NVALUE,PRV_DVALUE,PRV_CLASS_ORG,PRV_UPDATECOUNT,PRV_CREATED,PRV_UPDATED,PRV_NOTUSED) 
  values ('SITEID','EVNT','*',WOCODE,1,SITE_ID,null,null,'*',0,time_reported,time_reported,'-')

INTO EAM.R5PROPERTYVALUES  (PRV_PROPERTY,PRV_RENTITY,PRV_CLASS,PRV_CODE,PRV_SEQNO,PRV_VALUE,PRV_NVALUE,PRV_DVALUE,PRV_CLASS_ORG,PRV_UPDATECOUNT,PRV_CREATED,PRV_UPDATED,PRV_NOTUSED) 
  values ('SAHRS','EVNT','*',WOCODE,1,SA_HRS,null,null,'*',0,time_reported,time_reported,'-')

INTO EAM.R5PROPERTYVALUES  (PRV_PROPERTY,PRV_RENTITY,PRV_CLASS,PRV_CODE,PRV_SEQNO,PRV_VALUE,PRV_NVALUE,PRV_DVALUE,PRV_CLASS_ORG,PRV_UPDATECOUNT,PRV_CREATED,PRV_UPDATED,PRV_NOTUSED) 
  values ('SUHRS','EVNT','*',WOCODE,1,SU_HRS,null,null,'*',0,time_reported,time_reported,'-')

INTO EAM.R5PROPERTYVALUES  (PRV_PROPERTY,PRV_RENTITY,PRV_CLASS,PRV_CODE,PRV_SEQNO,PRV_VALUE,PRV_NVALUE,PRV_DVALUE,PRV_CLASS_ORG,PRV_UPDATECOUNT,PRV_CREATED,PRV_UPDATED,PRV_NOTUSED) 
  values ('VENDOR','EVNT','*',WOCODE,1,VENDOR,null,null,'*',0,time_reported,time_reported,'-')

INTO EAM.R5PROPERTYVALUES  (PRV_PROPERTY,PRV_RENTITY,PRV_CLASS,PRV_CODE,PRV_SEQNO,PRV_VALUE,PRV_NVALUE,PRV_DVALUE,PRV_CLASS_ORG,PRV_UPDATECOUNT,PRV_CREATED,PRV_UPDATED,PRV_NOTUSED) 
  values ('MODALITY','EVNT','*',WOCODE,1,MODALITY,null,null,'*',0,time_reported,time_reported,'-')

INTO EAM.R5PROPERTYVALUES  (PRV_PROPERTY,PRV_RENTITY,PRV_CLASS,PRV_CODE,PRV_SEQNO,PRV_VALUE,PRV_NVALUE,PRV_DVALUE,PRV_CLASS_ORG,PRV_UPDATECOUNT,PRV_CREATED,PRV_UPDATED,PRV_NOTUSED) 
  values ('WKHRS','EVNT','*',WOCODE,1,WKHRS,null,null,'*',0,time_reported,time_reported,'-')

INTO EAM.R5PROPERTYVALUES  (PRV_PROPERTY,PRV_RENTITY,PRV_CLASS,PRV_CODE,PRV_SEQNO,PRV_VALUE,PRV_NVALUE,PRV_DVALUE,PRV_CLASS_ORG,PRV_UPDATECOUNT,PRV_CREATED,PRV_UPDATED,PRV_NOTUSED) 
  values ('MFHRS','EVNT','*',WOCODE,1,MF_HRS,null,null,'*',0,time_reported,time_reported,'-')

INTO EAM.R5PROPERTYVALUES  (PRV_PROPERTY,PRV_RENTITY,PRV_CLASS,PRV_CODE,PRV_SEQNO,PRV_VALUE,PRV_NVALUE,PRV_DVALUE,PRV_CLASS_ORG,PRV_UPDATECOUNT,PRV_CREATED,PRV_UPDATED,PRV_NOTUSED) 
  values ('CHRSMF','EVNT','*',WOCODE,1,CHRSMF,null,null,'*',0,time_reported,time_reported,'-')

--INTO EAM.R5PROPERTYVALUES  (PRV_PROPERTY,PRV_RENTITY,PRV_CLASS,PRV_CODE,PRV_SEQNO,PRV_VALUE,PRV_NVALUE,PRV_DVALUE,PRV_CLASS_ORG,PRV_UPDATECOUNT,PRV_CREATED,PRV_UPDATED,PRV_NOTUSED) 
--  values ('ROOM','EVNT','*',WOCODE,1,ROOM,null,null,'*',0,time_reported,time_reported,'-')

--INTO EAM.R5PROPERTYVALUES  (PRV_PROPERTY,PRV_RENTITY,PRV_CLASS,PRV_CODE,PRV_SEQNO,PRV_VALUE,PRV_NVALUE,PRV_DVALUE,PRV_CLASS_ORG,PRV_UPDATECOUNT,PRV_CREATED,PRV_UPDATED,PRV_NOTUSED) 
--  values ('ASSETNAM','EVNT','*',WOCODE,1,ANAME,null,null,'*',0,time_reported,time_reported,'-')

INTO EAM.R5PROPERTYVALUES  (PRV_PROPERTY,PRV_RENTITY,PRV_CLASS,PRV_CODE,PRV_SEQNO,PRV_VALUE,PRV_NVALUE,PRV_DVALUE,PRV_CLASS_ORG,PRV_UPDATECOUNT,PRV_CREATED,PRV_UPDATED,PRV_NOTUSED) 
  values ('OEM','EVNT','*',WOCODE,1,OEM,null,null,'*',0,time_reported,time_reported,'-')

INTO EAM.R5PROPERTYVALUES  (PRV_PROPERTY,PRV_RENTITY,PRV_CLASS,PRV_CODE,PRV_SEQNO,PRV_VALUE,PRV_NVALUE,PRV_DVALUE,PRV_CLASS_ORG,PRV_UPDATECOUNT,PRV_CREATED,PRV_UPDATED,PRV_NOTUSED) 
  values ('DOMAIN','EVNT','*',WOCODE,1,DNAME,null,null,'*',0,time_reported,time_reported,'-')

INTO EAM.R5PROPERTYVALUES  (PRV_PROPERTY,PRV_RENTITY,PRV_CLASS,PRV_CODE,PRV_SEQNO,PRV_VALUE,PRV_NVALUE,PRV_DVALUE,PRV_CLASS_ORG,PRV_UPDATECOUNT,PRV_CREATED,PRV_UPDATED,PRV_NOTUSED) 
  values ('CLINIC','EVNT','*',WOCODE,1,CLINIC_AREA,null,null,'*',0,time_reported,time_reported,'-')

INTO EAM.R5PROPERTYVALUES  (PRV_PROPERTY,PRV_RENTITY,PRV_CLASS,PRV_CODE,PRV_SEQNO,PRV_VALUE,PRV_NVALUE,PRV_DVALUE,PRV_CLASS_ORG,PRV_UPDATECOUNT,PRV_CREATED,PRV_UPDATED,PRV_NOTUSED) 
  values ('FLOOR','EVNT','*',WOCODE,1,FLOOR1,null,null,'*',0,time_reported,time_reported,'-')

SELECT 1 FROM DUAL;

END IF;
EXCEPTION
WHEN OTHERS THEN NULL;
END;




--------------****************************************--------------------------
--------------*******************END******************--------------------------
--------------****************************************--------------------------



--------------****************************************--------------------------
--------- Title: YNWO  TABLE VIEW 
--------- Note: LIST OF ALL WO -  USED FOR CRYSTAL REPORTS
--------------****************************************--------------------------


select 
e.evt_code WO,EVT_REPORTED Date_Reported,EVT_TARGET TARGET,r5o7.o7get_desc('EN','UCOD', e.evt_status,'EVST', '') WO_STATUS, 
EVT_MRC Building,SQL_40.prv_value FLOOR, SQL_46.prv_value ASSET_FLOOR, SQL_45.prv_value Clinic_Area, SQL_44.prv_value Asset_Clinic_Area,
O.OBJ_LOCATION Room#, SQL_43.prv_value Room_Name, SQL_42.prv_value Asset_Room_Name, O.OBJ_COSTCODE Cost_Center, O.OBJ_CLASS Modality,
SQL_41.prv_value Modality_WO, SQL_47.prv_value Service_Vendor, O.OBJ_MANUFACT Asset_Service_Vendor, 
SQL_109.prv_value Site_ID,
SQL_48.prv_value Asset_Name, SQL_49.prv_value AssetName, O.OBJ_VARIABLE1 Model_Name, O.OBJ_VARIABLE2 AH_Number, O.OBJ_DESC Equipment_Description,
E.EVT_DESC Problem_Description, E.EVT_PRIORITY EQPT_STATUS, SQL_50.prv_value Caller, SQL_51.prv_value WO_Type, 
r5o7.o7get_desc('EN','UCOD', e.evt_jobtype,'JBTP', '') Event,
SQL_52.prv_value Issue, SQL_53.prv_value Service1, SQL_54.prv_value SERVICE2, SQL_55.prv_value SERVICE3, SQL_56.prv_value PARTS1,
SQL_57.prv_value PARTS2, SQL_58.prv_value PARTS3, SQL_59.prv_value CPU_SN_OLD, SQL_60.prv_value CPU_SN_NEW, SQL_61.prv_value Coil_SN_Old,
SQL_62.prv_value Coil_SN_NEW, SQL_63.prv_value Probe_SN_Old, SQL_64.PRV_VALUE Probe_SN_NEW,
          AD.ADD_TEXT Work_Performed,
          E.EVT_PERSON Primary_Engineer,
          E.EVT_UDFCHKBOX01 AH_Svc_Event,
SQL_65.PRV_VALUE VEN_Total_Labor_Hrs, SQL_66.PRV_VALUE Total_Labor_Hrs_OPs, SQL_67.PRV_VALUE ENG_TOTAL_LABOR_HRs,
          E.EVT_DOWNTIMEHRS System_Hard_Down_Hrs_Ops,
SQL_68.PRV_VALUE WK_System_HRS_OF_OPS, SQL_69.PRV_DVALUE Availiability, SQL_70.PRV_DVALUE Vendor_Call_Time,
SQL_71.PRV_DVALUE Vendor_Call_Back, SQL_72.PRV_DVALUE Vendor_ETA, SQL_73.PRV_DVALUE Revised_ETA, SQL_74.PRV_DVALUE Vendor_Onsite_Call_Time,
SQL_75.PRV_DVALUE eUpdate_Start_Time,
          E.EVT_COMPLETED Date_Completed,
SQL_76.prv_value Reference#, SQL_77.PRV_VALUE OLE_Engaged,
    E.EVT_UDFCHKBOX05 Recurring_Event,
SQL_78.PRV_VALUE WO_Note,
          E.EVT_UDFCHKBOX04 CCB,
SQL_79.PRV_VALUE Mgt_Engaged, SQL_80.PRV_VALUE Directives_Ignored, SQL_81.PRV_VALUE eUpdate30min, SQL_82.PRV_VALUE FSR7_Days,
SQL_83.PRV_VALUE NOPE, SQL_84.PRV_VALUE Call_Dropped, SQL_85.PRV_VALUE Call_Escalated, SQL_86.PRV_VALUE OnCall_Issues,
SQL_87.PRV_VALUE Parts_ETA_Missed, SQL_88.PRV_VALUE WWWWNoComm, SQL_89.PRV_VALUE Tech_Support_Requested, SQL_90.PRV_VALUE Sent_For_Analysis,
SQL_91.PRV_DVALUE Scheduled_Start, SQL_92.PRV_DVALUE Scheduled_End, SQL_93.PRV_VALUE Planned_Total_Hrs, SQL_94.PRV_VALUE Log#,
SQL_95.PRV_VALUE Block_s, SQL_96.PRV_VALUE Domain, SQL_97.PRV_VALUE Managed_by, 
        O.OBJ_CODE Equipment,
          E.EVT_RTYPE JOBTYPE,
          E.EVT_CREATEDBY WO_Created_By,
SQL_98.PRV_VALUE OEM, SQL_99.PRV_VALUE Asset_OEM, SQL_100.PRV_VALUE PFS, SQL_101.PRV_VALUE VFCCT, SQL_102.PRV_VALUE Mgt_Intervention,
SQL_103.PRV_VALUE Parts_Delayed, SQL_104.PRV_VALUE SubComponent, 
          E.EVT_UDFCHKBOX03 UpDown,
SQL_105.PRV_VALUE UpDown_Time,
          E.EVT_UDFCHKBOX02 OT_Approved,
SQL_106.PRV_DVALUE ENG_Start,
SQL_107.PRV_DVALUE ENG_End,
          TO_NUMBER (TO_CHAR (evt_reported, 'mm')) MonthNum,
SQL_108.PRV_DVALUE System_Up_Time
   
   from r5events e, r5activities a, r5objects o, r5addetails ad,
   r5propertyvalues SQL_47, r5propertyvalues SQL_41, r5propertyvalues SQL_42, r5propertyvalues SQL_43, r5propertyvalues SQL_44, r5propertyvalues SQL_45,
   r5propertyvalues SQL_46, r5propertyvalues SQL_48, r5propertyvalues SQL_49, r5propertyvalues SQL_50, r5propertyvalues SQL_51, r5propertyvalues SQL_52,
   r5propertyvalues SQL_53, r5propertyvalues SQL_54, r5propertyvalues SQL_55, r5propertyvalues SQL_56, r5propertyvalues SQL_57, r5propertyvalues SQL_58,
   r5propertyvalues SQL_59, r5propertyvalues SQL_60, r5propertyvalues SQL_61, r5propertyvalues SQL_62, r5propertyvalues SQL_63, r5propertyvalues SQL_64,
   r5propertyvalues SQL_65, r5propertyvalues SQL_66, r5propertyvalues SQL_67, r5propertyvalues SQL_68, r5propertyvalues SQL_69, r5propertyvalues SQL_70,
   r5propertyvalues SQL_71, r5propertyvalues SQL_72, r5propertyvalues SQL_73, r5propertyvalues SQL_74, r5propertyvalues SQL_75, r5propertyvalues SQL_76,
   r5propertyvalues SQL_77, r5propertyvalues SQL_78, r5propertyvalues SQL_79, r5propertyvalues SQL_80, r5propertyvalues SQL_81, r5propertyvalues SQL_82,
   r5propertyvalues SQL_83, r5propertyvalues SQL_84, r5propertyvalues SQL_85, r5propertyvalues SQL_86, r5propertyvalues SQL_87, r5propertyvalues SQL_88,
   r5propertyvalues SQL_89, r5propertyvalues SQL_90, r5propertyvalues SQL_91, r5propertyvalues SQL_92, r5propertyvalues SQL_93, r5propertyvalues SQL_94,
   r5propertyvalues SQL_95, r5propertyvalues SQL_96, r5propertyvalues SQL_97, r5propertyvalues SQL_98, r5propertyvalues SQL_99, r5propertyvalues SQL_100,
   r5propertyvalues SQL_101, r5propertyvalues SQL_102, r5propertyvalues SQL_103, r5propertyvalues SQL_104, r5propertyvalues SQL_105, r5propertyvalues SQL_106,
   r5propertyvalues SQL_107, r5propertyvalues SQL_108, r5propertyvalues SQL_109, r5propertyvalues SQL_40--, r5propertyvalues p
   
   where
   e.evt_rstatus IN ('Q', 'R', 'C') 
AND        e.evt_rtype IN ('JOB', 'PPM')
 
AND e.evt_code = a.act_event (+)
AND e.evt_object = o.obj_code(+)
AND e.evt_object_org = o.obj_org(+)
AND       (a.act_act is null or a.act_act=(select min(b.act_act) from r5activities b where b.act_event=a.act_event) )
   
AND AD.ADD_LINE(+) = A.act_act AND a.act_event || '#10' = AD.ADD_CODE(+)
          AND E.EVT_STATUS <> 'A'
          AND E.EVT_STATUS <> 'REJ'              
          AND E.EVT_STATUS <> 'RJDD'
          and evt_code=SQL_47.prv_code(+) and (SQL_47.prv_rentity(+) = 'EVNT') and (SQL_47.prv_property(+)='VENDOR')
          and evt_code=SQL_41.prv_code(+) and  (SQL_41.prv_rentity(+) = 'EVNT') and (SQL_41.prv_property(+)='MODALITY')
          and obj_code||'#'||obj_org=SQL_42.prv_code(+) and (SQL_42.prv_rentity(+) = 'OBJ') and (SQL_42.prv_property(+)='ROOMNAME')
          and evt_code=SQL_43.prv_code(+) and (SQL_43.prv_rentity(+) = 'EVNT') and (SQL_43.prv_property(+)='ROOM')
          and obj_code||'#'||obj_org=SQL_44.prv_code(+) and (SQL_44.prv_rentity(+) = 'OBJ') and (SQL_44.prv_property(+)='CLINIC')
          and evt_code=SQL_45.prv_code(+) and (SQL_45.prv_rentity(+) = 'EVNT') and (SQL_45.prv_property(+)='CLINIC')
          and evt_code=SQL_40.prv_code(+) and (SQL_40.prv_rentity(+) = 'EVNT') and (SQL_40.prv_property(+)='FLOOR')
          and obj_code||'#'||obj_org=SQL_46.prv_code(+) and (SQL_46.prv_rentity(+) = 'OBJ') and (SQL_46.prv_property(+)='FLOOR')
          and (evt_code=SQL_48.prv_code(+) and SQL_48.prv_rentity(+) = 'EVNT') and (SQL_48.prv_property(+)='ASSETNAM')
          and obj_code||'#'||obj_org=SQL_49.prv_code(+) and (SQL_49.prv_rentity(+) = 'OBJ') and (SQL_49.prv_property(+)='ASSETNAM')
          and evt_code=SQL_50.prv_code(+) and (SQL_50.prv_rentity(+) = 'EVNT') and (SQL_50.prv_property(+)='ILINQED')
          and evt_code=SQL_51.prv_code(+) and (SQL_51.prv_rentity(+) = 'EVNT') and (SQL_51.prv_property(+)='WOTYPE')
          and evt_code=SQL_52.prv_code(+) and (SQL_52.prv_rentity(+) = 'EVNT') and (SQL_52.prv_property(+)='ISSUE')
          and evt_code=SQL_53.prv_code(+) and (SQL_53.prv_rentity(+) = 'EVNT') and (SQL_53.prv_property(+)='SERVICE1')
          and evt_code=SQL_54.prv_code(+) and (SQL_54.prv_rentity(+) = 'EVNT') and (SQL_54.prv_property(+)='SERVICE2')
          and evt_code=SQL_55.prv_code(+) and (SQL_55.prv_rentity(+) = 'EVNT') and (SQL_55.prv_property(+)='SERVICE3')
          and evt_code=SQL_56.prv_code(+) and (SQL_56.prv_rentity(+) = 'EVNT') and (SQL_56.prv_property(+)='PARTS1')
          and evt_code=SQL_57.prv_code(+) and (SQL_57.prv_rentity(+) = 'EVNT') and (SQL_57.prv_property(+)='PARTS2')
          and evt_code=SQL_58.prv_code(+) and (SQL_58.prv_rentity(+) = 'EVNT') and (SQL_58.prv_property(+)='PARTS3')
          and evt_code=SQL_59.prv_code(+) and (SQL_59.prv_rentity(+) = 'EVNT') and (SQL_59.prv_property(+)='CPUOLD')
          and evt_code=SQL_60.prv_code(+) and (SQL_60.prv_rentity(+) = 'EVNT') and (SQL_60.prv_property(+)='CPUNEW')
          and evt_code=SQL_61.prv_code(+) and (SQL_61.prv_rentity(+) = 'EVNT') and (SQL_61.prv_property(+)='COILOLD')
          and evt_code=SQL_62.prv_code(+) and (SQL_62.prv_rentity(+) = 'EVNT') and (SQL_62.prv_property(+)='COILNEW')
          and evt_code=SQL_63.prv_code(+) and (SQL_63.prv_rentity(+) = 'EVNT') and (SQL_63.prv_property(+)='PROBEOLD')
          and evt_code=SQL_64.prv_code(+) and (SQL_64.prv_rentity(+) = 'EVNT') and (SQL_64.prv_property(+)='PROBENEW')
          and evt_code=SQL_65.prv_code(+) and (SQL_65.prv_rentity(+) = 'EVNT') and (SQL_65.prv_property(+)='SVCHRS')
          and evt_code=SQL_66.prv_code(+) and (SQL_66.prv_rentity(+) = 'EVNT') and (SQL_66.prv_property(+)='OPHOURS')
          and evt_code=SQL_67.prv_code(+) and (SQL_67.prv_rentity(+) = 'EVNT') and (SQL_67.prv_property(+)='ENGLABOR')
          and evt_code=SQL_68.prv_code(+) and (SQL_68.prv_rentity(+) = 'EVNT') and (SQL_68.prv_property(+)='WKHRS')
          and evt_code=SQL_69.prv_code(+) and (SQL_69.prv_rentity(+) = 'EVNT') and (SQL_69.prv_property(+)='AVAILIAB')
          and evt_code=SQL_70.prv_code(+) and (SQL_70.prv_rentity(+) = 'EVNT') and (SQL_70.prv_property(+)='VCALLED')
          and evt_code=SQL_71.prv_code(+) and (SQL_71.prv_rentity(+) = 'EVNT') and (SQL_71.prv_property(+)='VCALBACK')
          and evt_code=SQL_72.prv_code(+) and (SQL_72.prv_rentity(+) = 'EVNT') and (SQL_72.prv_property(+)='VENDETA')
          and evt_code=SQL_73.prv_code(+) and (SQL_73.prv_rentity(+) = 'EVNT') and (SQL_73.prv_property(+)='REVETA')
          and evt_code=SQL_74.prv_code(+) and (SQL_74.prv_rentity(+) = 'EVNT') and (SQL_74.prv_property(+)='VONSITE')
          and evt_code=SQL_75.prv_code(+) and (SQL_75.prv_rentity(+) = 'EVNT') and (SQL_75.prv_property(+)='EUPDATE')
          and evt_code=SQL_76.prv_code(+) and (SQL_76.prv_rentity(+) = 'EVNT') and (SQL_76.prv_property(+)='REFERENC')
          and evt_code=SQL_77.prv_code(+) and (SQL_77.prv_rentity(+) = 'EVNT') and (SQL_77.prv_property(+)='OLEENG')
          and evt_code=SQL_78.prv_code(+) and (SQL_78.prv_rentity(+) = 'EVNT') and (SQL_78.prv_property(+)='WONOTE')
          and evt_code=SQL_79.prv_code(+) and (SQL_79.prv_rentity(+) = 'EVNT') and (SQL_79.prv_property(+)='MGTENGAG')
          and evt_code=SQL_80.prv_code(+) and (SQL_80.prv_rentity(+) = 'EVNT') and (SQL_80.prv_property(+)='DIRIGNOR')
          and evt_code=SQL_81.prv_code(+) and (SQL_81.prv_rentity(+) = 'EVNT') and (SQL_81.prv_property(+)='EUPD30M')
          and evt_code=SQL_82.prv_code(+) and (SQL_82.prv_rentity(+) = 'EVNT') and (SQL_82.prv_property(+)='FSR>7DAY')
          and evt_code=SQL_83.prv_code(+) and (SQL_83.prv_rentity(+) = 'EVNT') and (SQL_83.prv_property(+)='NOPE')
          and evt_code=SQL_84.prv_code(+) and (SQL_84.prv_rentity(+) = 'EVNT') and (SQL_84.prv_property(+)='CALLDROP')
          and evt_code=SQL_85.prv_code(+) and (SQL_85.prv_rentity(+) = 'EVNT') and (SQL_85.prv_property(+)='CALLESCL')
          and evt_code=SQL_86.prv_code(+) and (SQL_86.prv_rentity(+) = 'EVNT') and (SQL_86.prv_property(+)='ONCALLIS')
          and evt_code=SQL_87.prv_code(+) and (SQL_87.prv_rentity(+) = 'EVNT') and (SQL_87.prv_property(+)='PETAMISS')
          and evt_code=SQL_88.prv_code(+) and (SQL_88.prv_rentity(+) = 'EVNT') and (SQL_88.prv_property(+)='WWWNOCOM')
          and evt_code=SQL_89.prv_code(+) and (SQL_89.prv_rentity(+) = 'EVNT') and (SQL_89.prv_property(+)='TECHSUPP')
          and evt_code=SQL_90.prv_code(+) and (SQL_90.prv_rentity(+) = 'EVNT') and (SQL_90.prv_property(+)='ANALYSIS')
          and evt_code=SQL_91.prv_code(+) and (SQL_91.prv_rentity(+) = 'EVNT') and (SQL_91.prv_property(+)='SCHSTART')
          and evt_code=SQL_92.prv_code(+) and (SQL_92.prv_rentity(+) = 'EVNT') and (SQL_92.prv_property(+)='SCHEND')
          and evt_code=SQL_93.prv_code(+) and (SQL_93.prv_rentity(+) = 'EVNT') and (SQL_93.prv_property(+)='TOTALHRS')
          and evt_code=SQL_94.prv_code(+) and (SQL_94.prv_rentity(+) = 'EVNT') and (SQL_94.prv_property(+)='LOGNUM')
          and evt_code=SQL_95.prv_code(+) and (SQL_95.prv_rentity(+) = 'EVNT') and (SQL_95.prv_property(+)='BLOCKS')
          and evt_code=SQL_96.prv_code(+) and (SQL_96.prv_rentity(+) = 'EVNT') and (SQL_96.prv_property(+)='DOMAIN')
          and evt_code=SQL_97.prv_code(+) and (SQL_97.prv_rentity(+) = 'EVNT') and (SQL_97.prv_property(+)='MANAGED')
          and evt_code=SQL_98.prv_code(+) and (SQL_98.prv_rentity(+) = 'EVNT') and (SQL_98.prv_property(+)='OEM')
          and obj_code||'#'||obj_org=SQL_99.prv_code(+) and (SQL_99.prv_rentity(+) = 'OBJ') and (SQL_99.prv_property(+)='OEM')
          and evt_code=SQL_100.prv_code(+) and (SQL_100.prv_rentity(+) = 'EVNT') and (SQL_100.prv_property(+)='PFS')
          and evt_code=SQL_101.prv_code(+) and (SQL_101.prv_rentity(+) = 'EVNT') and (SQL_101.prv_property(+)='VFCCT')
          and evt_code=SQL_102.prv_code(+) and (SQL_102.prv_rentity(+) = 'EVNT') and (SQL_102.prv_property(+)='MGTINTV')
          and evt_code=SQL_103.prv_code(+) and (SQL_103.prv_rentity(+) = 'EVNT') and (SQL_103.prv_property(+)='PARTSDEL')
          and evt_code=SQL_104.prv_code(+) and (SQL_104.prv_rentity(+) = 'EVNT') and (SQL_104.prv_property(+)='SUBCOMP')
          and evt_code=SQL_105.prv_code(+) and (SQL_105.prv_rentity(+) = 'EVNT') and (SQL_105.prv_property(+)='UPDNTIME')
          and evt_code=SQL_106.prv_code(+) and (SQL_106.prv_rentity(+) = 'EVNT') and (SQL_106.prv_property(+)='ENGCALL')
          and evt_code=SQL_107.prv_code(+) and (SQL_107.prv_rentity(+) = 'EVNT') and (SQL_107.prv_property(+)='ENGCBACK')
          and evt_code=SQL_108.prv_code(+) and (SQL_108.prv_rentity(+) = 'EVNT') and (SQL_108.prv_property(+)='SYSUPTM')
	        and evt_code=SQL_109.prv_code(+) and (SQL_109.prv_rentity(+) = 'EVNT') and (SQL_109.prv_property(+)='SITEID')
          
              
         -- AND P.PRV_PROPERTY = 'SITEID' AND E.EVT_CODE = P.PRV_CODE AND P.PRV_RENTITY = 'EVNT'
--------------****************************************--------------------------
--------------*******************END******************--------------------------
--------------****************************************--------------------------




--------------****************************************--------------------------
--------- Title: YNASSET    TABLE  VIEW
--------- Note: SQL FOR ASSET - USED IN ALL CRYSTAL REPORT
--------------****************************************--------------------------

SELECT 
O.OBJ_CODE Equipment,
O.OBJ_SAFETY Budget_only,
SQL_153.prv_value Class,
r5o7.o7get_desc('EN','UCOD', o.obj_status,'OBST', '') Status,
SQL_147.prv_value DOMAIN,
SQL_148.prv_value MANAGED_BY,
obj_costcode Cost_Center,
O.OBJ_MRC Building,
SQL_161.prv_value CLINIC_AREA,
SQL_163.prv_value FLOOR,
o.obj_location Room#,
SQL_139.prv_value ROOM_NAME,
obj_manufactmodel Site_ID,
O.OBJ_DESC Equipment_Description,
SQL_142.prv_value ASSET_NAME,
SQL_145.prv_value  Risk_Level,
SQL_160.prv_value OEM,
o.obj_manufact Service_Vendor,
o.obj_class Modality,
obj_person Primary_Engineer,
o.obj_variable1 Model_Name,
SQL_130.prv_value Model_Number,
obj_serialno Serial_Number,
o.obj_variable2 AH_Number,
SQL_158.prv_dvalue Installation_Comp_Date,
SQL_159.prv_dvalue  Date_of_Mfg,
SQL_360.prv_value Mfg_Site_ID,
SQL_112.prv_value Vendor_PHONE#,
SQL_111.prv_value Clinic_Phone#,
SQL_114.prv_value Console_Phone#,
SQL_115.PRV_DVALUE Physics_Accepted,
SQL_116.PRV_DVALUE First_Patient,
SQL_117.PRV_DVALUE Clinic_Accepted,
SQL_118.PRV_DVALUE InActive_Date,
O.OBJ_SOLDDATE Retired_Date,
SQL_119.PRV_VALUE PO_Number,
O.OBJ_VARIABLE3 MF_Hrs_of_Ops,
OBJ_VARIABLE4 SA_Hrs_of_Ops,
OBJ_VARIABLE5 SU_Hrs_of_Ops,
OBJ_VARIABLE6 WK_Hrs_of_Ops,
O.OBJ_CRITICALITY Coverage,
SQL_120.PRV_VALUE C_Type,
OBJ_UDFCHAR01 C_Hrs_MF,
SQL_121.PRV_VALUE C_Hrs_Sat,
SQL_123.PRV_VALUE C_Hrs_Sun,
SQL_124.PRV_VALUE C_Hrs_ADD,
OBJ_UDFNUM01 C_Annual_$,
SQL_125.PRV_VALUE Network,
SQL_122.prv_value IP,
SQL_105.prv_value AET,
SQL_126.PRV_VALUE HOST,
SQL_155.prv_value Xfer_Protocol,
SQL_144.prv_value Wall_Port,
SQL_127.PRV_VALUE Network_Port,
SQL_128.PRV_VALUE Gateway,
SQL_129.PRV_VALUE Subnet_Mask,
SQL_149.PRV_VALUE NTP,
SQL_131.PRV_VALUE VPN,
SQL_132.PRV_VALUE A1_Panel_Battery,
SQL_133.PRV_VALUE A1_Battery_Type,
SQL_134.PRV_VALUE DST_Mode,
SQL_135.PRV_VALUE Distribution_List,
SQL_136.PRV_VALUE Asset_Note_1,
SQL_137.PRV_VALUE PM_Required,
SQL_138.PRV_VALUE Report_to_BIOMED,
SQL_140.PRV_VALUE PM_Frequency,
SQL_141.PRV_VALUE Coordinated_PM,
SQL_152.PRV_VALUE PM_Start_Time,
SQL_143.PRV_VALUE PM_Duration_Hrs,
SQL_154.PRV_VALUE PM_DOM,
SQL_165.PRV_VALUE JAN,
SQL_146.PRV_VALUE FEB,
SQL_157.PRV_VALUE MAR,
SQL_168.PRV_VALUE APR,
SQL_170.PRV_VALUE MAY,
SQL_171.PRV_VALUE JUN,
SQL_172.PRV_VALUE JUL,
SQL_173.PRV_VALUE AUG,
SQL_174.PRV_VALUE SEP,
SQL_175.PRV_VALUE OCT,
SQL_176.PRV_VALUE NOV,
SQL_177.PRV_VALUE DEC,
SQL_178.PRV_VALUE PM_Note,
SQL_179.PRV_VALUE Eqpt_Room_F,
SQL_180.PRV_VALUE Console_Room_F,
SQL_181.PRV_VALUE Gantry_Room_F,
SQL_182.PRV_VALUE N_Power,
SQL_183.PRV_VALUE OPower,
SQL_184.PRV_VALUE Int_UPS1,
SQL_185.PRV_VALUE Int_UPS2,
SQL_186.PRV_VALUE Ext_UPS1,
SQL_187.PRV_VALUE Ext_UPS2,
SQL_188.PRV_VALUE TECO,
SQL_189.PRV_VALUE Ext_Chiller,
SQL_190.PRV_VALUE HVAC,
SQL_200.PRV_VALUE INF_Note,
SQL_201.PRV_VALUE Replacement,
SQL_202.PRV_VALUE Replacement2,
SQL_203.PRV_VALUE Riser,
SQL_204.PRV_VALUE UpLine_Panel1,
SQL_205.PRV_VALUE UpLine_Panel2,
SQL_206.PRV_VALUE UpLine_Pane3,
SQL_207.PRV_VALUE Transformer1,
SQL_208.PRV_VALUE Transformer2,
SQL_209.PRV_VALUE Transformer3,
SQL_210.PRV_VALUE CB_Panel1,
SQL_211.PRV_VALUE CB_Panel2,
SQL_212.PRV_VALUE CB_Panel3,
SQL_213.PRV_VALUE Air_Handler1,
SQL_214.PRV_VALUE Air_Handler2,
SQL_215.PRV_VALUE Air_Handler3,
SQL_216.PRV_VALUE Chilled_H20_CB,
SQL_217.PRV_VALUE Helium_Comressor_CB,
OBJ_UDFDATE01 System_Delivery_Date,
OBJ_UDFDATE02 Installation_Start_Date,
SQL_218.PRV_VALUE EOL,
OBJ_UDFDATE03 Warranty_Start,
OBJ_UDFDATE04 Warranty_End

     from r5objects o  , r5propertyvalues SQL_142, r5propertyvalues SQL_145, r5propertyvalues SQL_159,
      r5propertyvalues SQL_111 , r5propertyvalues SQL_163 , r5propertyvalues SQL_158 , r5propertyvalues SQL_114,
      r5propertyvalues SQL_148 , r5propertyvalues SQL_155 , r5propertyvalues SQL_153 , r5propertyvalues SQL_115, r5propertyvalues SQL_116,
      r5propertyvalues SQL_122 , r5propertyvalues SQL_160 , r5propertyvalues SQL_130 , r5propertyvalues SQL_117, r5propertyvalues SQL_118,
      r5propertyvalues SQL_147 , r5propertyvalues SQL_144 , r5propertyvalues SQL_139 , r5propertyvalues SQL_119, r5propertyvalues SQL_120,
      r5propertyvalues SQL_161 , r5propertyvalues SQL_105 , r5propertyvalues SQL_112 , r5propertyvalues SQL_121, r5propertyvalues SQL_123,
      r5propertyvalues SQL_124, r5propertyvalues SQL_125, r5propertyvalues SQL_126, r5propertyvalues SQL_127, r5propertyvalues SQL_128, 
      r5propertyvalues SQL_129, r5propertyvalues SQL_149, r5propertyvalues SQL_131, r5propertyvalues SQL_132, r5propertyvalues SQL_133, 
      r5propertyvalues SQL_134, r5propertyvalues SQL_135, r5propertyvalues SQL_136, r5propertyvalues SQL_137, r5propertyvalues SQL_138,
      r5propertyvalues SQL_140, r5propertyvalues SQL_141, r5propertyvalues SQL_152, r5propertyvalues SQL_143, r5propertyvalues SQL_154,
      r5propertyvalues SQL_165, r5propertyvalues SQL_146, r5propertyvalues SQL_157, r5propertyvalues SQL_168, r5propertyvalues SQL_170,
      r5propertyvalues SQL_171, r5propertyvalues SQL_172, r5propertyvalues SQL_173, r5propertyvalues SQL_174, r5propertyvalues SQL_175,
      r5propertyvalues SQL_176, r5propertyvalues SQL_177, r5propertyvalues SQL_178, r5propertyvalues SQL_179, r5propertyvalues SQL_180,
      r5propertyvalues SQL_181, r5propertyvalues SQL_182, r5propertyvalues SQL_183, r5propertyvalues SQL_184, r5propertyvalues SQL_185,
      r5propertyvalues SQL_186, r5propertyvalues SQL_187, r5propertyvalues SQL_188, r5propertyvalues SQL_189, r5propertyvalues SQL_190,
      r5propertyvalues SQL_200, r5propertyvalues SQL_201, r5propertyvalues SQL_202, r5propertyvalues SQL_203, r5propertyvalues SQL_204,
      r5propertyvalues SQL_205, r5propertyvalues SQL_206, r5propertyvalues SQL_207, r5propertyvalues SQL_208, r5propertyvalues SQL_209,
      r5propertyvalues SQL_210, r5propertyvalues SQL_211, r5propertyvalues SQL_212, r5propertyvalues SQL_213, r5propertyvalues SQL_214,
      r5propertyvalues SQL_215, r5propertyvalues SQL_216, r5propertyvalues SQL_217, r5propertyvalues SQL_218, r5propertyvalues SQL_360
      where o.obj_obrtype ='A' and O.OBJ_STATUS <> 'EO' and O.OBJ_STATUS <> 'RET' and
      
       obj_code||'#'||obj_org=SQL_112.prv_code(+) and (SQL_112.prv_rentity(+) = 'OBJ') and (SQL_112.prv_property(+)='VPHONE') and 
       obj_code||'#'||obj_org=SQL_105.prv_code(+) and (SQL_105.prv_rentity(+) = 'OBJ') and (SQL_105.prv_property(+)='AET') and 
       obj_code||'#'||obj_org=SQL_161.prv_code(+) and (SQL_161.prv_rentity(+) = 'OBJ') and (SQL_161.prv_property(+)='CLINIC') and 
       obj_code||'#'||obj_org=SQL_139.prv_code(+) and (SQL_139.prv_rentity(+) = 'OBJ') and (SQL_139.prv_property(+)='ROOMNAME') and 
       obj_code||'#'||obj_org=SQL_144.prv_code(+) and (SQL_144.prv_rentity(+) = 'OBJ') and (SQL_144.prv_property(+)='WPORT') and 
       obj_code||'#'||obj_org=SQL_147.prv_code(+) and (SQL_147.prv_rentity(+) = 'OBJ') and (SQL_147.prv_property(+)='DOMAIN') and 
       obj_code||'#'||obj_org=SQL_130.prv_code(+) and (SQL_130.prv_rentity(+) = 'OBJ') and (SQL_130.prv_property(+)='MODNUM') and 
       obj_code||'#'||obj_org=SQL_160.prv_code(+) and (SQL_160.prv_rentity(+) = 'OBJ') and (SQL_160.prv_property(+)='OEM') and 
       obj_code||'#'||obj_org=SQL_122.prv_code(+) and (SQL_122.prv_rentity(+) = 'OBJ') and (SQL_122.prv_property(+)='IP') and 
       obj_code||'#'||obj_org=SQL_153.prv_code(+) and (SQL_153.prv_rentity(+) = 'OBJ') and (SQL_153.prv_property(+)='RELATION') and 
       obj_code||'#'||obj_org=SQL_155.prv_code(+) and (SQL_155.prv_rentity(+) = 'OBJ') and (SQL_155.prv_property(+)='PROTOCOL') and 
       obj_code||'#'||obj_org=SQL_148.prv_code(+) and (SQL_148.prv_rentity(+) = 'OBJ') and (SQL_148.prv_property(+)='MANAGED') and 
       obj_code||'#'||obj_org=SQL_158.prv_code(+) and (SQL_158.prv_rentity(+) = 'OBJ') and (SQL_158.prv_property(+)='IDATE') and 
       obj_code||'#'||obj_org=SQL_163.prv_code(+) and (SQL_163.prv_rentity(+) = 'OBJ') and (SQL_163.prv_property(+)='FLOOR') and
       obj_code||'#'||obj_org=SQL_159.prv_code(+) and (SQL_159.prv_rentity(+) = 'OBJ') and (SQL_159.prv_property(+)='DOM') and  
       obj_code||'#'||obj_org=SQL_111.prv_code(+) and (SQL_111.prv_rentity(+) = 'OBJ') and (SQL_111.prv_property(+)='CLPHONE') and
       obj_code||'#'||obj_org=SQL_142.prv_code(+) and (SQL_142.prv_rentity(+) = 'OBJ') and (SQL_142.prv_property(+)='ASSETNAM') and
       obj_code||'#'||obj_org=SQL_145.prv_code(+) and (SQL_145.prv_rentity(+) = 'OBJ') and (SQL_145.prv_property(+)='SVCLEVEL') and
       obj_code||'#'||obj_org=SQL_114.prv_code(+) and (SQL_114.prv_rentity(+) = 'OBJ') and (SQL_114.prv_property(+)='COPHONE') and
       obj_code||'#'||obj_org=SQL_115.prv_code(+) and (SQL_115.prv_rentity(+) = 'OBJ') and (SQL_115.prv_property(+)='PHYSICS') and
       obj_code||'#'||obj_org=SQL_116.prv_code(+) and (SQL_116.prv_rentity(+) = 'OBJ') and (SQL_116.prv_property(+)='1STPTNT') and
       obj_code||'#'||obj_org=SQL_117.prv_code(+) and (SQL_117.prv_rentity(+) = 'OBJ') and (SQL_117.prv_property(+)='ACCEPT') and
       obj_code||'#'||obj_org=SQL_118.prv_code(+) and (SQL_118.prv_rentity(+) = 'OBJ') and (SQL_118.prv_property(+)='DECOMMIS') and
       obj_code||'#'||obj_org=SQL_119.prv_code(+) and (SQL_119.prv_rentity(+) = 'OBJ') and (SQL_119.prv_property(+)='PONUM') and
       obj_code||'#'||obj_org=SQL_120.prv_code(+) and (SQL_120.prv_rentity(+) = 'OBJ') and (SQL_120.prv_property(+)='CTYPE') and
       obj_code||'#'||obj_org=SQL_121.prv_code(+) and (SQL_121.prv_rentity(+) = 'OBJ') and (SQL_121.prv_property(+)='CHRSSAT') and
       obj_code||'#'||obj_org=SQL_123.prv_code(+) and (SQL_123.prv_rentity(+) = 'OBJ') and (SQL_123.prv_property(+)='CHRSSUN') and
       obj_code||'#'||obj_org=SQL_124.prv_code(+) and (SQL_124.prv_rentity(+) = 'OBJ') and (SQL_124.prv_property(+)='CHRSADD') and
       obj_code||'#'||obj_org=SQL_125.prv_code(+) and (SQL_125.prv_rentity(+) = 'OBJ') and (SQL_125.prv_property(+)='NETWORK') and
       obj_code||'#'||obj_org=SQL_126.prv_code(+) and (SQL_126.prv_rentity(+) = 'OBJ') and (SQL_126.prv_property(+)='HOST') and
       obj_code||'#'||obj_org=SQL_127.prv_code(+) and (SQL_127.prv_rentity(+) = 'OBJ') and (SQL_127.prv_property(+)='PORT') and
       obj_code||'#'||obj_org=SQL_128.prv_code(+) and (SQL_128.prv_rentity(+) = 'OBJ') and (SQL_128.prv_property(+)='GATEWAY') and
       obj_code||'#'||obj_org=SQL_129.prv_code(+) and (SQL_129.prv_rentity(+) = 'OBJ') and (SQL_129.prv_property(+)='SUBNETM') and
       obj_code||'#'||obj_org=SQL_149.prv_code(+) and (SQL_149.prv_rentity(+) = 'OBJ') and (SQL_149.prv_property(+)='NTP') and
       obj_code||'#'||obj_org=SQL_131.prv_code(+) and (SQL_131.prv_rentity(+) = 'OBJ') and (SQL_131.prv_property(+)='VPN') and
       obj_code||'#'||obj_org=SQL_132.prv_code(+) and (SQL_132.prv_rentity(+) = 'OBJ') and (SQL_132.prv_property(+)='PANELBAT') and
       obj_code||'#'||obj_org=SQL_133.prv_code(+) and (SQL_133.prv_rentity(+) = 'OBJ') and (SQL_133.prv_property(+)='BATTERY') and
       obj_code||'#'||obj_org=SQL_134.prv_code(+) and (SQL_134.prv_rentity(+) = 'OBJ') and (SQL_134.prv_property(+)='DSTMODE') and
       obj_code||'#'||obj_org=SQL_135.prv_code(+) and (SQL_135.prv_rentity(+) = 'OBJ') and (SQL_135.prv_property(+)='DISTLIST') and
       obj_code||'#'||obj_org=SQL_136.prv_code(+) and (SQL_136.prv_rentity(+) = 'OBJ') and (SQL_136.prv_property(+)='ASNOTE1') and
       obj_code||'#'||obj_org=SQL_137.prv_code(+) and (SQL_137.prv_rentity(+) = 'OBJ') and (SQL_137.prv_property(+)='PMREQ') and
       obj_code||'#'||obj_org=SQL_138.prv_code(+) and (SQL_138.prv_rentity(+) = 'OBJ') and (SQL_138.prv_property(+)='BIOMED') and
       obj_code||'#'||obj_org=SQL_140.prv_code(+) and (SQL_140.prv_rentity(+) = 'OBJ') and (SQL_140.prv_property(+)='PMFREQ') and
       obj_code||'#'||obj_org=SQL_141.prv_code(+) and (SQL_141.prv_rentity(+) = 'OBJ') and (SQL_141.prv_property(+)='COOPM') and
       obj_code||'#'||obj_org=SQL_152.prv_code(+) and (SQL_152.prv_rentity(+) = 'OBJ') and (SQL_152.prv_property(+)='PMSTART') and
       obj_code||'#'||obj_org=SQL_143.prv_code(+) and (SQL_143.prv_rentity(+) = 'OBJ') and (SQL_143.prv_property(+)='PMHRS') and
       obj_code||'#'||obj_org=SQL_154.prv_code(+) and (SQL_154.prv_rentity(+) = 'OBJ') and (SQL_154.prv_property(+)='PMDOM') and
       obj_code||'#'||obj_org=SQL_165.prv_code(+) and (SQL_165.prv_rentity(+) = 'OBJ') and (SQL_165.prv_property(+)='JANUARY') and
       obj_code||'#'||obj_org=SQL_146.prv_code(+) and (SQL_146.prv_rentity(+) = 'OBJ') and (SQL_146.prv_property(+)='FEBRUARY') and
       obj_code||'#'||obj_org=SQL_157.prv_code(+) and (SQL_157.prv_rentity(+) = 'OBJ') and (SQL_157.prv_property(+)='MARCH') and
       obj_code||'#'||obj_org=SQL_168.prv_code(+) and (SQL_168.prv_rentity(+) = 'OBJ') and (SQL_168.prv_property(+)='APRIL') and
       obj_code||'#'||obj_org=SQL_170.prv_code(+) and (SQL_170.prv_rentity(+) = 'OBJ') and (SQL_170.prv_property(+)='MAY') and
       obj_code||'#'||obj_org=SQL_171.prv_code(+) and (SQL_171.prv_rentity(+) = 'OBJ') and (SQL_171.prv_property(+)='JUNE') and
       obj_code||'#'||obj_org=SQL_172.prv_code(+) and (SQL_172.prv_rentity(+) = 'OBJ') and (SQL_172.prv_property(+)='JULY') and
       obj_code||'#'||obj_org=SQL_173.prv_code(+) and (SQL_173.prv_rentity(+) = 'OBJ') and (SQL_173.prv_property(+)='AUGUST') and
       obj_code||'#'||obj_org=SQL_174.prv_code(+) and (SQL_174.prv_rentity(+) = 'OBJ') and (SQL_174.prv_property(+)='SEPTEMBE') and
       obj_code||'#'||obj_org=SQL_175.prv_code(+) and (SQL_175.prv_rentity(+) = 'OBJ') and (SQL_175.prv_property(+)='OCTOBER') and
       obj_code||'#'||obj_org=SQL_176.prv_code(+) and (SQL_176.prv_rentity(+) = 'OBJ') and (SQL_176.prv_property(+)='NOVEMBER') and
       obj_code||'#'||obj_org=SQL_177.prv_code(+) and (SQL_177.prv_rentity(+) = 'OBJ') and (SQL_177.prv_property(+)='DECEMBER') and
       obj_code||'#'||obj_org=SQL_178.prv_code(+) and (SQL_178.prv_rentity(+) = 'OBJ') and (SQL_178.prv_property(+)='PMNOTES') and
       obj_code||'#'||obj_org=SQL_179.prv_code(+) and (SQL_179.prv_rentity(+) = 'OBJ') and (SQL_179.prv_property(+)='EQTROOM') and
       obj_code||'#'||obj_org=SQL_180.prv_code(+) and (SQL_180.prv_rentity(+) = 'OBJ') and (SQL_180.prv_property(+)='CONSROOM') and
       obj_code||'#'||obj_org=SQL_181.prv_code(+) and (SQL_181.prv_rentity(+) = 'OBJ') and (SQL_181.prv_property(+)='GANTROOM') and
       obj_code||'#'||obj_org=SQL_182.prv_code(+) and (SQL_182.prv_rentity(+) = 'OBJ') and (SQL_182.prv_property(+)='NPOWER') and
       obj_code||'#'||obj_org=SQL_183.prv_code(+) and (SQL_183.prv_rentity(+) = 'OBJ') and (SQL_183.prv_property(+)='EPOWER') and
       obj_code||'#'||obj_org=SQL_184.prv_code(+) and (SQL_184.prv_rentity(+) = 'OBJ') and (SQL_184.prv_property(+)='INTUPS1') and
       obj_code||'#'||obj_org=SQL_185.prv_code(+) and (SQL_185.prv_rentity(+) = 'OBJ') and (SQL_185.prv_property(+)='INTUPS2') and
       obj_code||'#'||obj_org=SQL_186.prv_code(+) and (SQL_186.prv_rentity(+) = 'OBJ') and (SQL_186.prv_property(+)='EXTUPS1') and
       obj_code||'#'||obj_org=SQL_187.prv_code(+) and (SQL_187.prv_rentity(+) = 'OBJ') and (SQL_187.prv_property(+)='EXTUPS2') and
       obj_code||'#'||obj_org=SQL_188.prv_code(+) and (SQL_188.prv_rentity(+) = 'OBJ') and (SQL_188.prv_property(+)='TECO') and
       obj_code||'#'||obj_org=SQL_189.prv_code(+) and (SQL_189.prv_rentity(+) = 'OBJ') and (SQL_189.prv_property(+)='EXTCHILL') and
       obj_code||'#'||obj_org=SQL_190.prv_code(+) and (SQL_190.prv_rentity(+) = 'OBJ') and (SQL_190.prv_property(+)='AC') and
       obj_code||'#'||obj_org=SQL_200.prv_code(+) and (SQL_200.prv_rentity(+) = 'OBJ') and (SQL_200.prv_property(+)='INFNOTE') and
       obj_code||'#'||obj_org=SQL_201.prv_code(+) and (SQL_201.prv_rentity(+) = 'OBJ') and (SQL_201.prv_property(+)='REPLACE') and
       obj_code||'#'||obj_org=SQL_202.prv_code(+) and (SQL_202.prv_rentity(+) = 'OBJ') and (SQL_202.prv_property(+)='REPLACE2') and
       obj_code||'#'||obj_org=SQL_203.prv_code(+) and (SQL_203.prv_rentity(+) = 'OBJ') and (SQL_203.prv_property(+)='RISER') and
       obj_code||'#'||obj_org=SQL_204.prv_code(+) and (SQL_204.prv_rentity(+) = 'OBJ') and (SQL_204.prv_property(+)='UPANEL1') and
       obj_code||'#'||obj_org=SQL_205.prv_code(+) and (SQL_205.prv_rentity(+) = 'OBJ') and (SQL_205.prv_property(+)='UPANEL2') and
       obj_code||'#'||obj_org=SQL_206.prv_code(+) and (SQL_206.prv_rentity(+) = 'OBJ') and (SQL_206.prv_property(+)='UPANEL3') and
       obj_code||'#'||obj_org=SQL_207.prv_code(+) and (SQL_207.prv_rentity(+) = 'OBJ') and (SQL_207.prv_property(+)='TRANS1') and
       obj_code||'#'||obj_org=SQL_208.prv_code(+) and (SQL_208.prv_rentity(+) = 'OBJ') and (SQL_208.prv_property(+)='TRANS2') and
       obj_code||'#'||obj_org=SQL_209.prv_code(+) and (SQL_209.prv_rentity(+) = 'OBJ') and (SQL_209.prv_property(+)='TRANS3') and
       obj_code||'#'||obj_org=SQL_210.prv_code(+) and (SQL_210.prv_rentity(+) = 'OBJ') and (SQL_210.prv_property(+)='CPANEL1') and
       obj_code||'#'||obj_org=SQL_211.prv_code(+) and (SQL_211.prv_rentity(+) = 'OBJ') and (SQL_211.prv_property(+)='CPANEL2') and
       obj_code||'#'||obj_org=SQL_212.prv_code(+) and (SQL_212.prv_rentity(+) = 'OBJ') and (SQL_212.prv_property(+)='CPANEL3') and
       obj_code||'#'||obj_org=SQL_213.prv_code(+) and (SQL_213.prv_rentity(+) = 'OBJ') and (SQL_213.prv_property(+)='HAND1') and
       obj_code||'#'||obj_org=SQL_214.prv_code(+) and (SQL_214.prv_rentity(+) = 'OBJ') and (SQL_214.prv_property(+)='HAND2') and
       obj_code||'#'||obj_org=SQL_215.prv_code(+) and (SQL_215.prv_rentity(+) = 'OBJ') and (SQL_215.prv_property(+)='HAND3') and
       obj_code||'#'||obj_org=SQL_216.prv_code(+) and (SQL_216.prv_rentity(+) = 'OBJ') and (SQL_216.prv_property(+)='CHILH20') and
       obj_code||'#'||obj_org=SQL_217.prv_code(+) and (SQL_217.prv_rentity(+) = 'OBJ') and (SQL_217.prv_property(+)='HCOMPR') and
       obj_code||'#'||obj_org=SQL_218.prv_code(+) and (SQL_218.prv_rentity(+) = 'OBJ') and (SQL_218.prv_property(+)='EOL') and
       obj_code||'#'||obj_org=SQL_360.prv_code(+) and (SQL_360.prv_rentity(+) = 'OBJ') and (SQL_360.prv_property(+)='SITE')


