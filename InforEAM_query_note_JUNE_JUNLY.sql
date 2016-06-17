
--***GE... SvcRequest WO with downtime > 0
select 
e.evt_code WO,
to_char(EVT_REPORTED, 'mm/DD/YYYY' ) Date_Reported,
r5o7.o7get_desc('EN','UCOD', e.evt_jobtype,'JBTP', '') Event,
--EVT_TARGET TARGET,
--r5o7.o7get_desc('EN','UCOD', e.evt_status,'EVST', '') WO_STATUS, 
--EVT_MRC Building,
O.OBJ_CODE EQUIPMENT,
SQL_109.prv_value Site_ID,
SQL_49.prv_value AssetName,
r5o7.o7get_desc('EN','UCOD', o.obj_status,'OBST', '') ASSET_STATUS,
--O.OBJ_COSTCODE Cost_Center, 
--O.OBJ_CLASS Modality,
SQL_41.prv_value Modality,
--SQL_65.PRV_VALUE VEN_Total_Labor_Hrs,
--down time 
--count(E.evt_code),
SQL_98.PRV_VALUE OEM,
NVL(E.EVT_DOWNTIMEHRS,0) System_Hard_Down_Hrs_Ops,
--planned or unplanned
SQL_51.prv_value WO_Type, 
E.EVT_PRIORITY EQPT_STATUS
--pm or and stuff
--r5o7.o7get_desc('EN','UCOD', e.evt_jobtype,'JBTP', '') Event,
--wo asset name
--SQL_48.prv_value Asset_Name, 
--asset name from object

--r5o7.o7get_desc('EN','UCOD', o.obj_status,'OBST', '') Asset_Status
from  r5events e, r5activities a, r5objects o, r5addetails ad,
      r5propertyvalues SQL_41, r5propertyvalues SQL_51, r5propertyvalues SQL_65, r5propertyvalues SQL_49, r5propertyvalues SQL_48,
      r5propertyvalues SQL_109, r5propertyvalues SQL_98
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

and evt_code=SQL_41.prv_code(+) and  (SQL_41.prv_rentity(+) = 'EVNT') and (SQL_41.prv_property(+)='MODALITY')
and (evt_code=SQL_48.prv_code(+) and SQL_48.prv_rentity(+) = 'EVNT') and (SQL_48.prv_property(+)='ASSETNAM')
and obj_code||'#'||obj_org=SQL_49.prv_code(+) and (SQL_49.prv_rentity(+) = 'OBJ') and (SQL_49.prv_property(+)='ASSETNAM')

and evt_code=SQL_51.prv_code(+) and (SQL_51.prv_rentity(+) = 'EVNT') and (SQL_51.prv_property(+)='WOTYPE')
and evt_code=SQL_65.prv_code(+) and (SQL_65.prv_rentity(+) = 'EVNT') and (SQL_65.prv_property(+)='SVCHRS')
and evt_code=SQL_98.prv_code(+) and (SQL_98.prv_rentity(+) = 'EVNT') and (SQL_98.prv_property(+)='OEM')
and evt_code=SQL_109.prv_code(+) and (SQL_109.prv_rentity(+) = 'EVNT') and (SQL_109.prv_property(+)='SITEID')
--modality is 'MRI'
and (SQL_41.prv_value = 'MRI' or SQL_41.prv_value = 'CT' or SQL_41.prv_value = 'PETCT' or SQL_41.prv_value = 'DR-XR')
--and (O.OBJ_CLASS = 'MRI' or O.OBJ_CLASS = 'CT' or O.OBJ_CLASS = 'PETCT')
--and (O.OBJ_CLASS = 'MRI')
--exclude dunlab, ir, rtschool, saif,  
--AND O.OBJ_COSTCODE != 'DUNLAB' AND O.OBJ_COSTCODE != 'IR' AND O.OBJ_COSTCODE != 'SAIF' AND O.OBJ_COSTCODE != 'RTSCHOOL'
--event_report alway has value null = empty
--and EVT_REPORTED is null
--group by SQL_49.prv_value
--and r5o7.o7get_desc('EN','UCOD', o.obj_status,'OBST', '') != 'Retired' 
--remove outage or unknow wo status
--AND E.EVT_PRIORITY is not NULL
--planned or unplanned
--AND SQL_51.prv_value = 'UnPlanned'
--only use 'SvcRequest'
AND r5o7.o7get_desc('EN','UCOD', e.evt_jobtype,'JBTP', '') = 'SvcRequest'
--check only wo with downtime
AND (E.EVT_DOWNTIMEHRS is not null and E.EVT_DOWNTIMEHRS > 0)
--select only OEM =  GE
AND (SQL_98.PRV_VALUE = 'GE' or SQL_98.PRV_VALUE is NULL)
--AND (trunc(EVT_REPORTED) >= TO_DATE('14-NOV-01', 'YY-MON-DD') AND trunc(EVT_REPORTED) <= TO_DATE('15-OCT-31', 'YY-MON-DD'))
--***currently using
--AND trunc(EVT_REPORTED) >= TO_DATE('15-JAN-01', 'YY-MON-DD') 
AND (trunc(EVT_REPORTED) >= TO_DATE('13-JAN-01', 'YY-MON-DD')AND trunc(EVT_REPORTED) <= TO_DATE('15-DEC-31', 'YY-MON-DD') )
--AND (trunc(EVT_REPORTED) >= TO_DATE('14-JAN-01', 'YY-MON-DD') AND trunc(EVT_REPORTED) <= TO_DATE(SYSDATE, 'YY-MON-DD'))
--group by SQL_49.prv_value, OBJ_CODE, SQL_51.prv_value, O.OBJ_COSTCODE, O.OBJ_CLASS, r5o7.o7get_desc('EN','UCOD', e.evt_jobtype,'JBTP', '')
--group by SQL_49.prv_value, OBJ_CODE, SQL_51.prv_value, O.OBJ_COSTCODE, O.OBJ_CLASS, E.EVT_PRIORITY

--group by OBJ_CODE
--order by SQL_49.prv_value desc
order by EVT_REPORTED"

--****
WITH TABLE1 AS
(select 
e.evt_code WO,
to_char(EVT_REPORTED, 'mm/DD/YYYY' ) Date_Reported,
r5o7.o7get_desc('EN','UCOD', e.evt_jobtype,'JBTP', '') Event,
--EVT_TARGET TARGET,
--r5o7.o7get_desc('EN','UCOD', e.evt_status,'EVST', '') WO_STATUS, 
--EVT_MRC Building,
O.OBJ_CODE EQUIPMENT,
SQL_109.prv_value Site_ID,
SQL_49.prv_value AssetName,
r5o7.o7get_desc('EN','UCOD', o.obj_status,'OBST', '') ASSET_STATUS,
--O.OBJ_COSTCODE Cost_Center, 
--O.OBJ_CLASS Modality,
SQL_41.prv_value Modality,
--SQL_65.PRV_VALUE VEN_Total_Labor_Hrs,
--down time 
--count(E.evt_code),
SQL_98.PRV_VALUE OEM,
NVL(E.EVT_DOWNTIMEHRS,0) System_Hard_Down_Hrs_Ops,
--planned or unplanned
SQL_51.prv_value WO_Type, 
E.EVT_PRIORITY EQPT_STATUS
--pm or and stuff
--r5o7.o7get_desc('EN','UCOD', e.evt_jobtype,'JBTP', '') Event,
--wo asset name
--SQL_48.prv_value Asset_Name, 
--asset name from object

--r5o7.o7get_desc('EN','UCOD', o.obj_status,'OBST', '') Asset_Status
from  r5events e, r5activities a, r5objects o, r5addetails ad,
      r5propertyvalues SQL_41, r5propertyvalues SQL_51, r5propertyvalues SQL_65, r5propertyvalues SQL_49, r5propertyvalues SQL_48,
      r5propertyvalues SQL_109, r5propertyvalues SQL_98
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

and evt_code=SQL_41.prv_code(+) and  (SQL_41.prv_rentity(+) = 'EVNT') and (SQL_41.prv_property(+)='MODALITY')
and (evt_code=SQL_48.prv_code(+) and SQL_48.prv_rentity(+) = 'EVNT') and (SQL_48.prv_property(+)='ASSETNAM')
and obj_code||'#'||obj_org=SQL_49.prv_code(+) and (SQL_49.prv_rentity(+) = 'OBJ') and (SQL_49.prv_property(+)='ASSETNAM')

and evt_code=SQL_51.prv_code(+) and (SQL_51.prv_rentity(+) = 'EVNT') and (SQL_51.prv_property(+)='WOTYPE')
and evt_code=SQL_65.prv_code(+) and (SQL_65.prv_rentity(+) = 'EVNT') and (SQL_65.prv_property(+)='SVCHRS')
and evt_code=SQL_98.prv_code(+) and (SQL_98.prv_rentity(+) = 'EVNT') and (SQL_98.prv_property(+)='OEM')
and evt_code=SQL_109.prv_code(+) and (SQL_109.prv_rentity(+) = 'EVNT') and (SQL_109.prv_property(+)='SITEID')
--modality is 'MRI'
and (SQL_41.prv_value = 'MRI' or SQL_41.prv_value = 'CT' or SQL_41.prv_value = 'PETCT' or SQL_41.prv_value = 'DR-XR')
--and (O.OBJ_CLASS = 'MRI' or O.OBJ_CLASS = 'CT' or O.OBJ_CLASS = 'PETCT')
--and (O.OBJ_CLASS = 'MRI')
--exclude dunlab, ir, rtschool, saif,  
--AND O.OBJ_COSTCODE != 'DUNLAB' AND O.OBJ_COSTCODE != 'IR' AND O.OBJ_COSTCODE != 'SAIF' AND O.OBJ_COSTCODE != 'RTSCHOOL'
--event_report alway has value null = empty
--and EVT_REPORTED is null
--group by SQL_49.prv_value
--and r5o7.o7get_desc('EN','UCOD', o.obj_status,'OBST', '') != 'Retired' 
--remove outage or unknow wo status
--AND E.EVT_PRIORITY is not NULL
--planned or unplanned
--AND SQL_51.prv_value = 'UnPlanned'
--only use 'SvcRequest'
AND r5o7.o7get_desc('EN','UCOD', e.evt_jobtype,'JBTP', '') = 'SvcRequest'
--check only wo with downtime
--AND (E.EVT_DOWNTIMEHRS is not null and E.EVT_DOWNTIMEHRS > 0)
--select only OEM =  GE
AND (SQL_98.PRV_VALUE = 'GE')
--AND (trunc(EVT_REPORTED) >= TO_DATE('14-NOV-01', 'YY-MON-DD') AND trunc(EVT_REPORTED) <= TO_DATE('15-OCT-31', 'YY-MON-DD'))
--***currently using
--AND trunc(EVT_REPORTED) >= TO_DATE('15-JAN-01', 'YY-MON-DD') 
AND (trunc(EVT_REPORTED) >= TO_DATE('13-JAN-01', 'YY-MON-DD')AND trunc(EVT_REPORTED) <= TO_DATE('15-DEC-31', 'YY-MON-DD') )
--AND (trunc(EVT_REPORTED) >= TO_DATE('14-JAN-01', 'YY-MON-DD') AND trunc(EVT_REPORTED) <= TO_DATE(SYSDATE, 'YY-MON-DD'))
--group by SQL_49.prv_value, OBJ_CODE, SQL_51.prv_value, O.OBJ_COSTCODE, O.OBJ_CLASS, r5o7.o7get_desc('EN','UCOD', e.evt_jobtype,'JBTP', '')
--group by SQL_49.prv_value, OBJ_CODE, SQL_51.prv_value, O.OBJ_COSTCODE, O.OBJ_CLASS, E.EVT_PRIORITY

--group by OBJ_CODE
--order by SQL_49.prv_value desc
order by EVT_REPORTED)
SELECT DISTINCT MODALITY, EQUIPMENT, SITE_ID, ASSETNAME, ASSET_STATUS FROM TABLE1 ORDER BY EQUIPMENT


---****** pipoiting the TB_ASSET_OPR_GREG table
SELECT ASSET_NAME ASSETNAME,EQUIPMENT,MODALITY,SITE_ID, MF_TIME, Date_Reported,MONTHLY_OPR_HRS
FROM TB_ASSET_OPH_GREG
UNPIVOT (MONTHLY_OPR_HRS
FOR Date_Reported IN (
JAN012013 AS '01-JAN-13',
FEB012013 AS '01-FEB-13',
MAR012013 AS '01-MAR-13',
APR012013 AS '01-APR-13',
MAY012013 AS '01-MAY-13',
JUN012013 AS '01-JUN-13',
JUL012013 AS '01-JUL-13',
AUG012013 AS '01-AUG-13',
SEP012013 AS '01-SEP-13',
OCT012013 AS '01-OCT-13',
NOV012013 AS '01-NOV-13',
DEC012013 AS '01-DEC-13',
JAN012014 AS '01-JAN-14',
FEB012014 AS '01-FEB-14',
MAR012014 AS '01-MAR-14',
APR012014 AS '01-APR-14',
MAY012014 AS '01-MAY-14',
JUN012014 AS '01-JUN-14',
JUL012014 AS '01-JUL-14',
AUG012014 AS '01-AUG-14',
SEP012014 AS '01-SEP-14',
OCT012014 AS '01-OCT-14',
NOV012014 AS '01-NOV-14',
DEC012014 AS '01-DEC-14',
JAN012015 AS '01-JAN-15',
FEB012015 AS '01-FEB-15',
MAR012015 AS '01-MAR-15',
APR012015 AS '01-APR-15',
MAY012015 AS '01-MAY-15',
JUN012015 AS '01-JUN-15',
JUL012015 AS '01-JUL-15',
AUG012015 AS '01-AUG-15',
SEP012015 AS '01-SEP-15',
OCT012015 AS '01-OCT-15',
NOV012015 AS '01-NOV-15',
DEC012015 AS '01-DEC-15'

        ))


--*** TB_ASSET_OPR_GREG View... ***---
With Asset AS (
SELECT 
O.OBJ_CLASS Modality,
SQL_142.prv_value ASSET_NAME,
obj_manufactmodel Site_ID,
O.OBJ_CODE Equipment,
SQL_160.prv_value OEM,
O.OBJ_VARIABLE3 MF_Hrs_of_Ops,
OBJ_VARIABLE4 SA_Hrs_of_Ops,
OBJ_VARIABLE5 SU_Hrs_of_Ops,

CASE LENGTH(OBJ_VARIABLE4)
  WHEN 4 THEN 'ALL'
  WHEN 1    THEN 'MF'
  --ELSE to_number(to_char(TO_DATE( substr(OBJ_VARIABLE4,-4,4),'HH24MI')- TO_DATE( substr(OBJ_VARIABLE4,1,4),'HH24MI'),'HH24MI'))
  ELSE 'MFSS'
  --ELSE to_char(TO_DATE( substr(OBJ_VARIABLE4,-4,4),'HH24MI'),'HH24MI')
END AS OP_DAY,

CASE LENGTH(OBJ_VARIABLE3)
  WHEN 4 THEN 24
  WHEN 1    THEN 0
  --ELSE to_number(to_char(TO_DATE( substr(OBJ_VARIABLE4,-4,4),'HH24MI')- TO_DATE( substr(OBJ_VARIABLE4,1,4),'HH24MI'),'HH24MI'))
  ELSE Round(to_number(to_char(TO_DATE( substr(OBJ_VARIABLE3,-4,4),'HH24MI')- TO_DATE( substr(OBJ_VARIABLE3,1,4),'HH24MI')))*24,1)
  --ELSE to_char(TO_DATE( substr(OBJ_VARIABLE4,-4,4),'HH24MI'),'HH24MI')
END AS MF_TIME,

CASE LENGTH(OBJ_VARIABLE4)
  WHEN 4 THEN 24
  WHEN 1    THEN 0
  --ELSE to_number(to_char(TO_DATE( substr(OBJ_VARIABLE4,-4,4),'HH24MI')- TO_DATE( substr(OBJ_VARIABLE4,1,4),'HH24MI'),'HH24MI'))
  ELSE Round(to_number(to_char(TO_DATE( substr(OBJ_VARIABLE4,-4,4),'HH24MI')- TO_DATE( substr(OBJ_VARIABLE4,1,4),'HH24MI')))*24,1)
  --ELSE to_char(TO_DATE( substr(OBJ_VARIABLE4,-4,4),'HH24MI'),'HH24MI')
END AS SAT_TIME,

CASE LENGTH(OBJ_VARIABLE5)
  WHEN 4 THEN 24
  WHEN 1    THEN 0
  --ELSE to_number(to_char(TO_DATE( substr(OBJ_VARIABLE4,-4,4),'HH24MI')- TO_DATE( substr(OBJ_VARIABLE4,1,4),'HH24MI'),'HH24MI'))
  ELSE Round(to_number(to_char(TO_DATE( substr(OBJ_VARIABLE5,-4,4),'HH24MI')- TO_DATE( substr(OBJ_VARIABLE5,1,4),'HH24MI')))*24,1)
  --ELSE to_char(TO_DATE( substr(OBJ_VARIABLE4,-4,4),'HH24MI'),'HH24MI')
END AS SUN_TIME

--OBJ_VARIABLE6 WK_Hrs_of_Ops
FROM r5objects o  , r5propertyvalues SQL_142, r5propertyvalues SQL_160

--OE is employee, RET is test object, RFI removed from inventory
--WHERE o.obj_obrtype ='A' AND O.OBJ_STATUS = 'I' AND SQL_142.prv_value IS NOT NULL AND
WHERE o.obj_obrtype ='A' and O.OBJ_STATUS <> 'EO' and O.OBJ_STATUS <> 'RET' AND O.OBJ_STATUS <> 'RFI' and SQL_142.prv_value IS NOT NULL AND
obj_code||'#'||obj_org=SQL_160.prv_code(+) and (SQL_160.prv_rentity(+) = 'OBJ') and (SQL_160.prv_property(+)='OEM') and 
obj_code||'#'||obj_org=SQL_142.prv_code(+) AND (SQL_142.prv_rentity(+) = 'OBJ') AND (SQL_142.prv_property(+)='ASSETNAM')
and (O.OBJ_CLASS = 'MRI' or O.OBJ_CLASS = 'CT' or O.OBJ_CLASS = 'PETCT' or O.OBJ_CLASS = 'DR-XR')
and SQL_160.prv_value = 'GE'

--exclude dunlab, ir, rtschool, saif,  
--AND O.OBJ_COSTCODE != 'DUNLAB' AND O.OBJ_COSTCODE != 'IR' AND O.OBJ_COSTCODE != 'SAIF' AND O.OBJ_COSTCODE != 'RTSCHOOL'
--exclue IOCT (dont have opr time)
--AND SQL_142.prv_value != 'IOCT'
ORDER BY O.OBJ_CLASS, SQL_142.prv_value)
--##start year calculation here##--

SELECT ASSET_NAME, Site_ID, Equipment, Modality, OEM, OP_DAY, MF_TIME, SAT_TIME, SUN_TIME,
 
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-JAN-13'),TO_DATE('31-JAN-13'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-JAN-13'),TO_DATE('31-JAN-13'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-JAN-13'),TO_DATE('31-JAN-13'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('31-JAN-13'))-TRUNC(TO_DATE('01-JAN-13')) ) +1)*24
END AS JAN012013,
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-FEB-13'),TO_DATE('28-FEB-13'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-FEB-13'),TO_DATE('28-FEB-13'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-FEB-13'),TO_DATE('28-FEB-13'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('28-FEB-13'))-TRUNC(TO_DATE('01-FEB-13')) ) +1)*24
END AS FEB012013,
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-MAR-13'),TO_DATE('31-MAR-13'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-MAR-13'),TO_DATE('31-MAR-13'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-MAR-13'),TO_DATE('31-MAR-13'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('31-MAR-13'))-TRUNC(TO_DATE('01-MAR-13')) ) +1)*24
END AS MAR012013,
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-APR-13'),TO_DATE('30-APR-13'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-APR-13'),TO_DATE('30-APR-13'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-APR-13'),TO_DATE('30-APR-13'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('30-APR-13'))-TRUNC(TO_DATE('01-APR-13')) ) +1)*24
END AS APR012013,
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-MAY-13'),TO_DATE('31-MAY-13'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-MAY-13'),TO_DATE('31-MAY-13'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-MAY-13'),TO_DATE('31-MAY-13'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('31-MAY-13'))-TRUNC(TO_DATE('01-MAY-13')) ) +1)*24
END AS MAY012013,
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-JUN-13'),TO_DATE('30-JUN-13'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-JUN-13'),TO_DATE('30-JUN-13'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-JUN-13'),TO_DATE('30-JUN-13'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('30-JUN-13'))-TRUNC(TO_DATE('01-JUN-13')) ) +1)*24
END AS JUN012013,
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-JUL-13'),TO_DATE('31-JUL-13'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-JUL-13'),TO_DATE('31-JUL-13'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-JUL-13'),TO_DATE('31-JUL-13'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('31-JUL-13'))-TRUNC(TO_DATE('01-JUL-13')) ) +1)*24
END AS JUL012013,
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-AUG-13'),TO_DATE('31-AUG-13'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-AUG-13'),TO_DATE('31-AUG-13'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-AUG-13'),TO_DATE('31-AUG-13'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('31-AUG-13'))-TRUNC(TO_DATE('01-AUG-13')) ) +1)*24
END AS AUG012013,
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-SEP-13'),TO_DATE('30-SEP-13'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-SEP-13'),TO_DATE('30-SEP-13'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-SEP-13'),TO_DATE('30-SEP-13'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('30-SEP-13'))-TRUNC(TO_DATE('01-SEP-13')) ) +1)*24
END AS SEP012013,
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-OCT-13'),TO_DATE('31-OCT-13'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-OCT-13'),TO_DATE('31-OCT-13'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-OCT-13'),TO_DATE('31-OCT-13'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('31-OCT-13'))-TRUNC(TO_DATE('01-OCT-13')) ) +1)*24
END AS OCT012013,
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-NOV-13'),TO_DATE('30-NOV-13'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-NOV-13'),TO_DATE('30-NOV-13'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-NOV-13'),TO_DATE('30-NOV-13'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('30-NOV-13'))-TRUNC(TO_DATE('01-NOV-13')) ) +1)*24
END AS NOV012013,
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-DEC-13'),TO_DATE('31-DEC-13'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-DEC-13'),TO_DATE('31-DEC-13'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-DEC-13'),TO_DATE('31-DEC-13'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('31-DEC-13'))-TRUNC(TO_DATE('01-DEC-13')) ) +1)*24
END AS DEC012013,
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-JAN-14'),TO_DATE('31-JAN-14'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-JAN-14'),TO_DATE('31-JAN-14'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-JAN-14'),TO_DATE('31-JAN-14'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('31-JAN-14'))-TRUNC(TO_DATE('01-JAN-14')) ) +1)*24
END AS JAN012014,
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-FEB-14'),TO_DATE('28-FEB-14'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-FEB-14'),TO_DATE('28-FEB-14'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-FEB-14'),TO_DATE('28-FEB-14'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('28-FEB-14'))-TRUNC(TO_DATE('01-FEB-14')) ) +1)*24
END AS FEB012014,
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-MAR-14'),TO_DATE('31-MAR-14'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-MAR-14'),TO_DATE('31-MAR-14'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-MAR-14'),TO_DATE('31-MAR-14'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('31-MAR-14'))-TRUNC(TO_DATE('01-MAR-14')) ) +1)*24
END AS MAR012014,
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-APR-14'),TO_DATE('30-APR-14'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-APR-14'),TO_DATE('30-APR-14'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-APR-14'),TO_DATE('30-APR-14'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('30-APR-14'))-TRUNC(TO_DATE('01-APR-14')) ) +1)*24
END AS APR012014,
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-MAY-14'),TO_DATE('31-MAY-14'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-MAY-14'),TO_DATE('31-MAY-14'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-MAY-14'),TO_DATE('31-MAY-14'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('31-MAY-14'))-TRUNC(TO_DATE('01-MAY-14')) ) +1)*24
END AS MAY012014,
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-JUN-14'),TO_DATE('30-JUN-14'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-JUN-14'),TO_DATE('30-JUN-14'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-JUN-14'),TO_DATE('30-JUN-14'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('30-JUN-14'))-TRUNC(TO_DATE('01-JUN-14')) ) +1)*24
END AS JUN012014,
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-JUL-14'),TO_DATE('31-JUL-14'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-JUL-14'),TO_DATE('31-JUL-14'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-JUL-14'),TO_DATE('31-JUL-14'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('31-JUL-14'))-TRUNC(TO_DATE('01-JUL-14')) ) +1)*24
END AS JUL012014,
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-AUG-14'),TO_DATE('31-AUG-14'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-AUG-14'),TO_DATE('31-AUG-14'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-AUG-14'),TO_DATE('31-AUG-14'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('31-AUG-14'))-TRUNC(TO_DATE('01-AUG-14')) ) +1)*24
END AS AUG012014,
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-SEP-14'),TO_DATE('30-SEP-14'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-SEP-14'),TO_DATE('30-SEP-14'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-SEP-14'),TO_DATE('30-SEP-14'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('30-SEP-14'))-TRUNC(TO_DATE('01-SEP-14')) ) +1)*24
END AS SEP012014,
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-OCT-14'),TO_DATE('31-OCT-14'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-OCT-14'),TO_DATE('31-OCT-14'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-OCT-14'),TO_DATE('31-OCT-14'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('31-OCT-14'))-TRUNC(TO_DATE('01-OCT-14')) ) +1)*24
END AS OCT012014,
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-NOV-14'),TO_DATE('30-NOV-14'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-NOV-14'),TO_DATE('30-NOV-14'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-NOV-14'),TO_DATE('30-NOV-14'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('30-NOV-14'))-TRUNC(TO_DATE('01-NOV-14')) ) +1)*24
END AS NOV012014,
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-DEC-14'),TO_DATE('31-DEC-14'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-DEC-14'),TO_DATE('31-DEC-14'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-DEC-14'),TO_DATE('31-DEC-14'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('31-DEC-14'))-TRUNC(TO_DATE('01-DEC-14')) ) +1)*24
END AS DEC012014,
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-JAN-15'),TO_DATE('31-JAN-15'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-JAN-15'),TO_DATE('31-JAN-15'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-JAN-15'),TO_DATE('31-JAN-15'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('31-JAN-15'))-TRUNC(TO_DATE('01-JAN-15')) ) +1)*24
END AS JAN012015,
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-FEB-15'),TO_DATE('28-FEB-15'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-FEB-15'),TO_DATE('28-FEB-15'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-FEB-15'),TO_DATE('28-FEB-15'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('28-FEB-15'))-TRUNC(TO_DATE('01-FEB-15')) ) +1)*24
END AS FEB012015,
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-MAR-15'),TO_DATE('31-MAR-15'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-MAR-15'),TO_DATE('31-MAR-15'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-MAR-15'),TO_DATE('31-MAR-15'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('31-MAR-15'))-TRUNC(TO_DATE('01-MAR-15')) ) +1)*24
END AS MAR012015,
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-APR-15'),TO_DATE('30-APR-15'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-APR-15'),TO_DATE('30-APR-15'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-APR-15'),TO_DATE('30-APR-15'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('30-APR-15'))-TRUNC(TO_DATE('01-APR-15')) ) +1)*24
END AS APR012015,
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-MAY-15'),TO_DATE('31-MAY-15'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-MAY-15'),TO_DATE('31-MAY-15'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-MAY-15'),TO_DATE('31-MAY-15'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('31-MAY-15'))-TRUNC(TO_DATE('01-MAY-15')) ) +1)*24
END AS MAY012015,
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-JUN-15'),TO_DATE('30-JUN-15'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-JUN-15'),TO_DATE('30-JUN-15'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-JUN-15'),TO_DATE('30-JUN-15'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('30-JUN-15'))-TRUNC(TO_DATE('01-JUN-15')) ) +1)*24
END AS JUN012015,
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-JUL-15'),TO_DATE('31-JUL-15'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-JUL-15'),TO_DATE('31-JUL-15'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-JUL-15'),TO_DATE('31-JUL-15'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('31-JUL-15'))-TRUNC(TO_DATE('01-JUL-15')) ) +1)*24
END AS JUL012015,
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-AUG-15'),TO_DATE('31-AUG-15'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-AUG-15'),TO_DATE('31-AUG-15'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-AUG-15'),TO_DATE('31-AUG-15'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('31-AUG-15'))-TRUNC(TO_DATE('01-AUG-15')) ) +1)*24
END AS AUG012015,
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-SEP-15'),TO_DATE('30-SEP-15'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-SEP-15'),TO_DATE('30-SEP-15'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-SEP-15'),TO_DATE('30-SEP-15'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('30-SEP-15'))-TRUNC(TO_DATE('01-SEP-15')) ) +1)*24
END AS SEP012015,
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-OCT-15'),TO_DATE('31-OCT-15'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-OCT-15'),TO_DATE('31-OCT-15'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-OCT-15'),TO_DATE('31-OCT-15'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('31-OCT-15'))-TRUNC(TO_DATE('01-OCT-15')) ) +1)*24
END AS OCT012015,
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-NOV-15'),TO_DATE('30-NOV-15'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-NOV-15'),TO_DATE('30-NOV-15'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-NOV-15'),TO_DATE('30-NOV-15'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('30-NOV-15'))-TRUNC(TO_DATE('01-NOV-15')) ) +1)*24
END AS NOV012015,
CASE OP_DAY
 WHEN 'MF' THEN BUSDAYS_BETWEEN(TO_DATE('01-DEC-15'),TO_DATE('31-DEC-15'))*MF_TIME
 WHEN 'MFSS' THEN BUSDAYS_BETWEEN(TO_DATE('01-DEC-15'),TO_DATE('31-DEC-15'))*MF_TIME + WEEKENDS_BETWEEN(TO_DATE('01-DEC-15'),TO_DATE('31-DEC-15'))*SAT_TIME
 ELSE ((TRUNC(TO_DATE('31-DEC-15'))-TRUNC(TO_DATE('01-DEC-15')) ) +1)*24
END AS DEC012015



FROM Asset