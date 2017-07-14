
 #Orignial DataMatrix Query:
  select th.dataID ,th.LesionNumber ,th.TTP, th.LobeLocation, th.SegmentLocation, th.ChemoUsed, th.WeeksBetweenBLandTACE, th.TreatmentDose, th.hepatitis, th.age, th.gender, th.smoking, th.alcohol,
          th.Cirrhosis, th.Pathology, th.Vascular, th.Metastasis, th.Lymphnodes, th.Thrombosis, th.AFP, th.FirstLineTherapy ,
          th.MVIStatus ,th.PNPLA3    ,th.PNPLA73   ,th.pnpl2     ,
          th.TTPTraining, th.LabelTraining , 
          rf.TimeID  ,   qa.Status , rf.StudyUID,
          a.labellocation, a.Volume,
          a.Pre_RAWIMAGE,a.Art_RAWIMAGE,a.Ven_RAWIMAGE,a.Del_RAWIMAGE,a.Pre_DENOISE,a.Art_DENOISE,a.Ven_DENOISE,a.Del_DENOISE,a.Pre_GRADIENT,a.Art_GRADIENT,a.Ven_GRADIENT,a.Del_GRADIENT,a.Pre_ATROPOS_GMM_POSTERIORS1,a.Art_ATROPOS_GMM_POSTERIORS1,a.Ven_ATROPOS_GMM_POSTERIORS1,a.Del_ATROPOS_GMM_POSTERIORS1,a.Pre_ATROPOS_GMM_POSTERIORS2,a.Art_ATROPOS_GMM_POSTERIORS2,a.Ven_ATROPOS_GMM_POSTERIORS2,a.Del_ATROPOS_GMM_POSTERIORS2,a.Pre_ATROPOS_GMM_POSTERIORS3,a.Art_ATROPOS_GMM_POSTERIORS3,a.Ven_ATROPOS_GMM_POSTERIORS3,a.Del_ATROPOS_GMM_POSTERIORS3,a.Pre_ATROPOS_GMM_LABEL1_DISTANCE,a.Art_ATROPOS_GMM_LABEL1_DISTANCE,a.Ven_ATROPOS_GMM_LABEL1_DISTANCE,a.Del_ATROPOS_GMM_LABEL1_DISTANCE,a.Pre_MEAN_RADIUS_1,a.Art_MEAN_RADIUS_1,a.Ven_MEAN_RADIUS_1,a.Del_MEAN_RADIUS_1,a.Pre_MEAN_RADIUS_3,a.Art_MEAN_RADIUS_3,a.Ven_MEAN_RADIUS_3,a.Del_MEAN_RADIUS_3,a.Pre_MEAN_RADIUS_5,a.Art_MEAN_RADIUS_5,a.Ven_MEAN_RADIUS_5,a.Del_MEAN_RADIUS_5,a.Pre_SIGMA_RADIUS_1,a.Art_SIGMA_RADIUS_1,a.Ven_SIGMA_RADIUS_1,a.Del_SIGMA_RADIUS_1,a.Pre_SIGMA_RADIUS_3,a.Art_SIGMA_RADIUS_3,a.Ven_SIGMA_RADIUS_3,a.Del_SIGMA_RADIUS_3,a.Pre_SIGMA_RADIUS_5,a.Art_SIGMA_RADIUS_5,a.Ven_SIGMA_RADIUS_5,a.Del_SIGMA_RADIUS_5,a.Pre_SKEWNESS_RADIUS_1,a.Art_SKEWNESS_RADIUS_1,a.Ven_SKEWNESS_RADIUS_1,a.Del_SKEWNESS_RADIUS_1,a.Pre_SKEWNESS_RADIUS_3,a.Art_SKEWNESS_RADIUS_3,a.Ven_SKEWNESS_RADIUS_3,a.Del_SKEWNESS_RADIUS_3,a.Pre_SKEWNESS_RADIUS_5,a.Art_SKEWNESS_RADIUS_5,a.Ven_SKEWNESS_RADIUS_5,a.Del_SKEWNESS_RADIUS_5,a.LEFTLUNGDISTANCE,a.RIGHTLUNGDISTANCE,a.LANDMARKDISTANCE0,a.LANDMARKDISTANCE1,a.LANDMARKDISTANCE2,a.HESSOBJ,a.NORMALIZEDDISTANCE  
   from      RandomForestHCCResponse.treatmenthistory th
   left join RandomForestHCCResponse.imaginguids      rf on (rf.studyUID=th.BaselineStudyUID or  rf.studyUID=th.FollowupStudyUID )
   left join RandomForestHCCResponse.qadata           qa on  rf.studyUID=qa.InstanceUID   
   left join (  select vl.InstanceUID, lk.location labellocation, group_concat( distinct vl.Volume SEPARATOR ';') Volume,
                       group_concat( distinct CASE WHEN fi.id = 1 THEN vl.mean  END ) as  Pre_RAWIMAGE,group_concat( distinct CASE WHEN fi.id = 2 THEN vl.mean  END ) as  Art_RAWIMAGE,
                       group_concat( distinct CASE WHEN fi.id = 3 THEN vl.mean  END ) as  Ven_RAWIMAGE,group_concat( distinct CASE WHEN fi.id = 4 THEN vl.mean  END ) as  Del_RAWIMAGE,
                       group_concat( distinct CASE WHEN fi.id = 5 THEN vl.mean  END ) as  Pre_DENOISE,group_concat( distinct CASE WHEN fi.id = 6 THEN vl.mean  END ) as  Art_DENOISE,
                       group_concat( distinct CASE WHEN fi.id = 7 THEN vl.mean  END ) as  Ven_DENOISE,group_concat( distinct CASE WHEN fi.id = 8 THEN vl.mean  END ) as  Del_DENOISE,
                       group_concat( distinct CASE WHEN fi.id = 9 THEN vl.mean  END ) as  Pre_GRADIENT,group_concat( distinct CASE WHEN fi.id = 10 THEN vl.mean  END ) as  Art_GRADIENT,
                       group_concat( distinct CASE WHEN fi.id = 11 THEN vl.mean  END ) as  Ven_GRADIENT,group_concat( distinct CASE WHEN fi.id = 12 THEN vl.mean  END ) as  Del_GRADIENT,
                       group_concat( distinct CASE WHEN fi.id = 13 THEN vl.mean  END ) as  Pre_ATROPOS_GMM_POSTERIORS1,group_concat( distinct CASE WHEN fi.id = 14 THEN vl.mean  END ) as  Art_ATROPOS_GMM_POSTERIORS1,
                       group_concat( distinct CASE WHEN fi.id = 15 THEN vl.mean  END ) as  Ven_ATROPOS_GMM_POSTERIORS1,group_concat( distinct CASE WHEN fi.id = 16 THEN vl.mean  END ) as  Del_ATROPOS_GMM_POSTERIORS1,
                       group_concat( distinct CASE WHEN fi.id = 17 THEN vl.mean  END ) as  Pre_ATROPOS_GMM_POSTERIORS2,group_concat( distinct CASE WHEN fi.id = 18 THEN vl.mean  END ) as  Art_ATROPOS_GMM_POSTERIORS2,
                       group_concat( distinct CASE WHEN fi.id = 19 THEN vl.mean  END ) as  Ven_ATROPOS_GMM_POSTERIORS2,group_concat( distinct CASE WHEN fi.id = 20 THEN vl.mean  END ) as  Del_ATROPOS_GMM_POSTERIORS2,
                       group_concat( distinct CASE WHEN fi.id = 21 THEN vl.mean  END ) as  Pre_ATROPOS_GMM_POSTERIORS3,group_concat( distinct CASE WHEN fi.id = 22 THEN vl.mean  END ) as  Art_ATROPOS_GMM_POSTERIORS3,
                       group_concat( distinct CASE WHEN fi.id = 23 THEN vl.mean  END ) as  Ven_ATROPOS_GMM_POSTERIORS3,group_concat( distinct CASE WHEN fi.id = 24 THEN vl.mean  END ) as  Del_ATROPOS_GMM_POSTERIORS3,
                       group_concat( distinct CASE WHEN fi.id = 25 THEN vl.mean  END ) as  Pre_ATROPOS_GMM_LABEL1_DISTANCE,group_concat( distinct CASE WHEN fi.id = 26 THEN vl.mean  END ) as  Art_ATROPOS_GMM_LABEL1_DISTANCE,
                       group_concat( distinct CASE WHEN fi.id = 27 THEN vl.mean  END ) as  Ven_ATROPOS_GMM_LABEL1_DISTANCE,group_concat( distinct CASE WHEN fi.id = 28 THEN vl.mean  END ) as  Del_ATROPOS_GMM_LABEL1_DISTANCE,
                       group_concat( distinct CASE WHEN fi.id = 29 THEN vl.mean  END ) as  Pre_MEAN_RADIUS_1,group_concat( distinct CASE WHEN fi.id = 30 THEN vl.mean  END ) as  Art_MEAN_RADIUS_1,
                       group_concat( distinct CASE WHEN fi.id = 31 THEN vl.mean  END ) as  Ven_MEAN_RADIUS_1,group_concat( distinct CASE WHEN fi.id = 32 THEN vl.mean  END ) as  Del_MEAN_RADIUS_1,
                       group_concat( distinct CASE WHEN fi.id = 33 THEN vl.mean  END ) as  Pre_MEAN_RADIUS_3,group_concat( distinct CASE WHEN fi.id = 34 THEN vl.mean  END ) as  Art_MEAN_RADIUS_3,
                       group_concat( distinct CASE WHEN fi.id = 35 THEN vl.mean  END ) as  Ven_MEAN_RADIUS_3,group_concat( distinct CASE WHEN fi.id = 36 THEN vl.mean  END ) as  Del_MEAN_RADIUS_3,
                       group_concat( distinct CASE WHEN fi.id = 37 THEN vl.mean  END ) as  Pre_MEAN_RADIUS_5,group_concat( distinct CASE WHEN fi.id = 38 THEN vl.mean  END ) as  Art_MEAN_RADIUS_5,
                       group_concat( distinct CASE WHEN fi.id = 39 THEN vl.mean  END ) as  Ven_MEAN_RADIUS_5,group_concat( distinct CASE WHEN fi.id = 40 THEN vl.mean  END ) as  Del_MEAN_RADIUS_5,
                       group_concat( distinct CASE WHEN fi.id = 41 THEN vl.mean  END ) as  Pre_SIGMA_RADIUS_1,group_concat( distinct CASE WHEN fi.id = 42 THEN vl.mean  END ) as  Art_SIGMA_RADIUS_1,
                       group_concat( distinct CASE WHEN fi.id = 43 THEN vl.mean  END ) as  Ven_SIGMA_RADIUS_1,group_concat( distinct CASE WHEN fi.id = 44 THEN vl.mean  END ) as  Del_SIGMA_RADIUS_1,
                       group_concat( distinct CASE WHEN fi.id = 45 THEN vl.mean  END ) as  Pre_SIGMA_RADIUS_3,group_concat( distinct CASE WHEN fi.id = 46 THEN vl.mean  END ) as  Art_SIGMA_RADIUS_3,
                       group_concat( distinct CASE WHEN fi.id = 47 THEN vl.mean  END ) as  Ven_SIGMA_RADIUS_3,group_concat( distinct CASE WHEN fi.id = 48 THEN vl.mean  END ) as  Del_SIGMA_RADIUS_3,
                       group_concat( distinct CASE WHEN fi.id = 49 THEN vl.mean  END ) as  Pre_SIGMA_RADIUS_5,group_concat( distinct CASE WHEN fi.id = 50 THEN vl.mean  END ) as  Art_SIGMA_RADIUS_5,
                       group_concat( distinct CASE WHEN fi.id = 51 THEN vl.mean  END ) as  Ven_SIGMA_RADIUS_5,group_concat( distinct CASE WHEN fi.id = 52 THEN vl.mean  END ) as  Del_SIGMA_RADIUS_5,
                       group_concat( distinct CASE WHEN fi.id = 53 THEN vl.mean  END ) as  Pre_SKEWNESS_RADIUS_1,group_concat( distinct CASE WHEN fi.id = 54 THEN vl.mean  END ) as  Art_SKEWNESS_RADIUS_1,
                       group_concat( distinct CASE WHEN fi.id = 55 THEN vl.mean  END ) as  Ven_SKEWNESS_RADIUS_1,group_concat( distinct CASE WHEN fi.id = 56 THEN vl.mean  END ) as  Del_SKEWNESS_RADIUS_1,
                       group_concat( distinct CASE WHEN fi.id = 57 THEN vl.mean  END ) as  Pre_SKEWNESS_RADIUS_3,group_concat( distinct CASE WHEN fi.id = 58 THEN vl.mean  END ) as  Art_SKEWNESS_RADIUS_3,
                       group_concat( distinct CASE WHEN fi.id = 59 THEN vl.mean  END ) as  Ven_SKEWNESS_RADIUS_3,group_concat( distinct CASE WHEN fi.id = 60 THEN vl.mean  END ) as  Del_SKEWNESS_RADIUS_3,
                       group_concat( distinct CASE WHEN fi.id = 61 THEN vl.mean  END ) as  Pre_SKEWNESS_RADIUS_5,group_concat( distinct CASE WHEN fi.id = 62 THEN vl.mean  END ) as  Art_SKEWNESS_RADIUS_5,
                       group_concat( distinct CASE WHEN fi.id = 63 THEN vl.mean  END ) as  Ven_SKEWNESS_RADIUS_5,group_concat( distinct CASE WHEN fi.id = 64 THEN vl.mean  END ) as  Del_SKEWNESS_RADIUS_5,
                       group_concat( distinct CASE WHEN fi.id = 65 THEN vl.mean  END ) as  LEFTLUNGDISTANCE,group_concat( distinct CASE WHEN fi.id = 66 THEN vl.mean  END ) as  RIGHTLUNGDISTANCE,
                       group_concat( distinct CASE WHEN fi.id = 67 THEN vl.mean  END ) as  LANDMARKDISTANCE0,group_concat( distinct CASE WHEN fi.id = 68 THEN vl.mean  END ) as  LANDMARKDISTANCE1,
                       group_concat( distinct CASE WHEN fi.id = 69 THEN vl.mean  END ) as  LANDMARKDISTANCE2,group_concat( distinct CASE WHEN fi.id = 70 THEN vl.mean  END ) as  HESSOBJ,
                       group_concat( distinct CASE WHEN fi.id = 71 THEN vl.mean  END ) as  NORMALIZEDDISTANCE
                from  RandomForestHCCResponse.ImageFeatures fi 
                join  RandomForestHCCResponse.liverLabelKey lk on lk.labelID = 2 or lk.labelID = 3 or lk.labelID = 4
                join  RandomForestHCCResponse.lstat         vl on vl.FeatureID=fi.FeatureID  and vl.SegmentationID=@varAnalysis and lk.labelID =  vl.labelid 
                group by vl.InstanceUID, lk.labelID
              ) a on a.InstanceUID = rf.StudyUID
  group by StudyUID, labellocation
) x2 
ON x1.studyUID = x2.studyUID 
where x2.dataid like "%tace%" AND x2.LobeLocation is not null;

#Note:
###th.dataID ,th.LesionNumber from   RandomForestHCCResponse.treatmenthistory th  <--- look into  treatmenthistory table  creation.

  DROP TABLE IF EXISTS  venus_diagram.imaginguids;
  CREATE TABLE venus_diagram.imaginguids(
  id    bigint(20) NOT NULL AUTO_INCREMENT,
  mrn                         int          GENERATED ALWAYS AS (json_unquote(data->"$.mdacc")                               ) COMMENT 'PT UID'                    ,
  dataID                      int          NULL COMMENT "Kareem's TACE Cases(all has same BL_CT dates as mine) = 1, Sorafenib = 2, 20cases of volume prediction paper=3, Case# 814684, is one of my cases and one of kareems cases as well with same BL and FU CT so it = 1/3,  Qayyum's_Cases =4, 33 TACE cases liver masks manualy labeled on Ven phase with extraction of veins= 5, PNPLA3 cases= 6, anyOther=0",
  truthID                     int          NULL COMMENT "small entirely viable lesion/s= 1, small entirely necrotic lesions= 2, both small entirelly viable and entirely necrotic lesions in same liver= 1and 2, small lesions with small necrotic and viable portions together = 3, Very large uninodular lesions with area of necrosis and viable tissue (or multi nodulaer lesions clustered)= 4, very large uninodular or multinodulaar lesion contain necrotic and viable tissue, additional to small satellite entierely viable small nodules around= 5, small lesions with smal necrotic and viable portions together additional to small satellite entierely viable small nodule/s around= 6, all others non included cases= 0",
  responderID                 int          NULL COMMENT "1= lesions with Shortest TTP, 2= lesions with longest TTP, 0= any other remaining lesions ", 
  TimeID                      VARCHAR( 16) NULL COMMENT 'Baseline, Followup, Followup2 ... ' ,
  StudyDate                   DATE         NULL COMMENT 'Study Date',
  StudyUID            VARCHAR(256)         NULL  COMMENT 'study UID'              ,
  SeriesUIDPre        VARCHAR(256)         NULL  COMMENT 'series UID'             ,
  SeriesACQPre        VARCHAR(256)         NULL  COMMENT 'series acquisition time',
  SeriesUIDArt        VARCHAR(256)         NULL  COMMENT 'series UID'             ,
  SeriesACQArt        VARCHAR(256)         NULL  COMMENT 'series acquisition time',
  SeriesUIDVen        VARCHAR(256)         NULL  COMMENT 'series UID'             ,
  SeriesACQVen        VARCHAR(256)         NULL  COMMENT 'series acquisition time',
  SeriesUIDDel        VARCHAR(256)         NULL  COMMENT 'series UID'             ,
  SeriesACQDel        VARCHAR(256)         NULL  COMMENT 'series acquisition time',
  data                        JSON         NULL ,
  PRIMARY KEY (id),
  KEY `UID1` (`mrn`),
  KEY `UID2` (`StudyUID`) 
  );


##this is the base line to be inserted in to imaginguid
## data is getting from excelUpload number 55.
  insert into venus_diagram.imaginguids(TimeID,dataID,truthID,responderID,StudyUID,StudyDate,SeriesUIDPre,SeriesACQPre,SeriesUIDArt,SeriesACQArt,SeriesUIDVen,SeriesACQVen,SeriesUIDDel,SeriesACQDel,data)
  select "baseline" TimeID,     
         ceil(JSON_UNQUOTE(  eu.data->"$.""Kareem's TACE Cases(all has same BL_CT dates as mine) = 1, Sorafenib = 2, 20cases of volume prediction paper=3, Case# 814684, is one of my cases and one of kareems cases as well with same BL and FU CT so it = 1/3, Qayyum's_Cases =4, 33 TACE cases liver masks manualy labeled on Ven phase with extraction of veins= 5, PNPLA3 cases= 6, Obese subject= 7, normal weight= 8,Normal liver protocol PNPLA3=9 anyOther=0""" ) ) dataID,
         substring(JSON_UNQUOTE(eu.data->"$.""BL_Training dataset, small entirely viable lesion/s= 1, small entirely necrotic lesions= 2, small lesions with small necrotic and viable portions together = 3,   very large uninodular lesions with area of necrosis and viable tissue (or multi nodular lesions clustered together)= 4, some cases combine 3and 4 = 3and4,  very large uninodular lesion contain necrotic and viable tissue, additional to small satellite entirely viable small nodules around= 5, small lesions with smal necrotic and viable portions together additional to smal satellite entirely viable small nodule/s around= 6, all others non included cases= 0"""),1,1) truthID,
         JSON_UNQUOTE(eu.data->"$.""1= lesions with Shortest TTP, 2= lesions with longest TTP, 0= any other remaining lesions """) responderID,
                                  json_unquote(eu.data->'$."Baseline1_CT_Study UID"'),
                                  json_unquote(eu.data->'$."Baseline1_CT_date"'),
         replace(substring_index( json_unquote(eu.data->'$."Baseline1_CT_SeriesUID_Pre"'), ':', 1),'{','') ,
         replace(substring_index( json_unquote(eu.data->'$."Baseline1_CT_SeriesUID_Pre"'), ':',-1),'}','') ,
         replace(substring_index( json_unquote(eu.data->'$."Baseline1_CT_SeriesUID_Art"'), ':', 1),'{','') ,
         replace(substring_index( json_unquote(eu.data->'$."Baseline1_CT_SeriesUID_Art"'), ':',-1),'}','') ,
         replace(substring_index( json_unquote(eu.data->'$."Baseline1_CT_SeriesUID_Ven"'), ':', 1),'{','') ,
         replace(substring_index( json_unquote(eu.data->'$."Baseline1_CT_SeriesUID_Ven"'), ':',-1),'}','') ,
         replace(substring_index( json_unquote(eu.data->'$."Baseline1_CT_SeriesUID_Del"'), ':', 1),'{','') ,
         replace(substring_index( json_unquote(eu.data->'$."Baseline1_CT_SeriesUID_Del"'), ':',-1),'}','') ,
         eu.data
  from ClinicalStudies.excelUpload eu 
  where length(eu.data->'$."Baseline1_CT_SeriesUID_Pre"') > 10 and 
               eu.data->'$."Baseline1_CT_Study UID"' is not null
  and eu.uploadID=55;

##insert "followup" into imaginguid
  insert into venus_diagram.imaginguids(TimeID,dataID,truthID,responderID,StudyUID,StudyDate,SeriesUIDPre,SeriesACQPre,SeriesUIDArt,SeriesACQArt,SeriesUIDVen,SeriesACQVen,SeriesUIDDel,SeriesACQDel,data)
  select "followup" TimeID,     
         ceil(JSON_UNQUOTE(  eu.data->"$.""Kareem's TACE Cases(all has same BL_CT dates as mine) = 1, Sorafenib = 2, 20cases of volume prediction paper=3, Case# 814684, is one of my cases and one of kareems cases as well with same BL and FU CT so it = 1/3, Qayyum's_Cases =4, 33 TACE cases liver masks manualy labeled on Ven phase with extraction of veins= 5, PNPLA3 cases= 6, Obese subject= 7, normal weight= 8,Normal liver protocol PNPLA3=9 anyOther=0""" ) ) dataID,
         substring(JSON_UNQUOTE(eu.data->"$.""FU_Training dataset, small entirely viable lesion/s= 1, small entirely necrotic lesions= 2, both small entirelly viable and entirely necrotic lesions in same liver= 1and 2, small lesions with small necrotic and viable portions together = 3, Very large uninodular lesions with area of necrosis and viable tissue (or multi nodulaer lesions clustered)= 4, very large uninodular or multinodulaar  lesion contain necrotic and viable tissue, additional to small satellite entierely viable small nodules around= 5, small lesions with smal necrotic and viable portions together additional to small satellite entierely viable small nodule/s around= 6, all others non included cases= 0"""),1,1) truthID,
         JSON_UNQUOTE(eu.data->"$.""1= lesions with Shortest TTP, 2= lesions with longest TTP, 0= any other remaining lesions """) responderID,
                                  json_unquote(eu.data->'$."Followup1_CT_Study UID"'),
                                  json_unquote(eu.data->'$."Followup1_CT_date"'),
         replace(substring_index( json_unquote(eu.data->'$."Followup1_CT_SeriesUID_Pre"'), ':', 1),'{','') ,
         replace(substring_index( json_unquote(eu.data->'$."Followup1_CT_SeriesUID_Pre"'), ':',-1),'}','') ,
         replace(substring_index( json_unquote(eu.data->'$."Followup1_CT_SeriesUID_Art"'), ':', 1),'{','') ,
         replace(substring_index( json_unquote(eu.data->'$."Followup1_CT_SeriesUID_Art"'), ':',-1),'}','') ,
         replace(substring_index( json_unquote(eu.data->'$."Followup1_CT_SeriesUID_Ven"'), ':', 1),'{','') ,
         replace(substring_index( json_unquote(eu.data->'$."Followup1_CT_SeriesUID_Ven"'), ':',-1),'}','') ,
         replace(substring_index( json_unquote(eu.data->'$."Followup1_CT_SeriesUID_Del"'), ':', 1),'{','') ,
         replace(substring_index( json_unquote(eu.data->'$."Followup1_CT_SeriesUID_Del"'), ':',-1),'}','') ,
         eu.data
  from ClinicalStudies.excelUpload eu 
  where length(eu.data->'$."Followup1_CT_SeriesUID_Pre"') > 10 and 
               eu.data->'$."Followup1_CT_Study UID"' is not null
  and eu.uploadID=55 ; 

for the lesion number 37:
1.2.840.113696.347054.500.1026273.20050418125620  TACE  37
1.2.840.113696.347054.500.966342.20050302110621 TACE  37

become this: good: one baseline and one followup
37  639540  0 0 0 baseline  2005-03-02  1.2.840.113696.347054.500.966342.20050302110621
543 639540  0 0 0 followup  2005-04-18  1.2.840.113696.347054.500.1026273.20050418125620



################################
######-- treatment history  db
###################################
DROP TABLE IF EXISTS  venus_diagram.treatmenthistory;
CREATE TABLE venus_diagram.treatmenthistory(
id               bigint(20)   NOT NULL AUTO_INCREMENT,
dataID           varchar(64)  NULL     COMMENT 'TACE Cases, MVI data, PNPLA3 data' ,
LesionNumber     int          GENERATED ALWAYS AS (json_unquote(data->'$."Lesion_Number(#)"')             )     COMMENT 'May have multiple lesions per liver... each tracked separately UID' ,
mrn              int          NOT NULL COMMENT 'PT UID'                    ,
Cirrhosis        varchar(64)  GENERATED ALWAYS AS (json_unquote(data->'$."Evidence_of_cirh, Y=1, No= 0"'))        COMMENT 'Cirrhosis  '               ,
Pathology        varchar(64)  GENERATED ALWAYS AS (json_unquote(data->'$."Pathology"'))                         COMMENT 'Pathology  '               ,
Vascular         varchar(64)  GENERATED ALWAYS AS (json_unquote(data->'$."Vascular invasion, y=1 n=0"'))         COMMENT 'Vascular   '               ,
Metastasis       varchar(64)  GENERATED ALWAYS AS (json_unquote(data->'$."Metastasis, y=1 n=0"'))                COMMENT 'Metastasis '               ,
Lymphnodes       varchar(64)  GENERATED ALWAYS AS (json_unquote(data->'$."Lymphnodes, y=1 n=0"'))                COMMENT 'Lymphnodes '               ,
Thrombosis       varchar(64)  GENERATED ALWAYS AS (json_unquote(data->'$."Portal Vein Thrombosis, y=1 n=0"'))    COMMENT 'Thrombosis '               ,
AFP              REAL         GENERATED ALWAYS AS (json_unquote(data->'$."AFP"')                          )     COMMENT 'Alpha feto protein'        ,
FirstLineTherapy varchar(64)  GENERATED ALWAYS AS (json_unquote(data->'$."first_line"')                   )     COMMENT 'First line therapy '       ,
BaselineDate     DATE         NULL                                                                              COMMENT 'Baseline Date '       ,
FollowupDate     DATE         NULL                                                                              COMMENT 'Followup Date '       ,
LobeLocation     varchar(128) GENERATED ALWAYS AS (json_unquote(data->'$."Target_lobe/s _of_Treatment"')  )     COMMENT 'Location information' ,
SegmentLocation  varchar(128) GENERATED ALWAYS AS ( REPLACE( json_unquote(data->'$."Target_segment/s of treatment"') , ',', ':'))     COMMENT 'Location information' ,
ChemoUsed        varchar(64)  NULL COMMENT 'Chemo Used',
WeeksBetweenBLandTACE REAL    NULL COMMENT 'Weeks between BL CT and TACE session',
TreatmentDose    varchar(64)  GENERATED ALWAYS AS ( REPLACE( json_unquote(data->"$.""Dose at 1st TACE/sorafenib in mg""") , ',', ':')) COMMENT 'Treatment Dose',
hepatitis        varchar(64)  GENERATED ALWAYS AS (JSON_UNQUOTE(data->"$.""hepatitis""")                       ) COMMENT 'hep status' ,
age              int          GENERATED ALWAYS AS (JSON_UNQUOTE(data->"$.""age""")                             ) COMMENT 'Age ' ,
gender           varchar(64)  GENERATED ALWAYS AS (JSON_UNQUOTE(data->"$.""Sex, 1=M, 2=F""")                   ) COMMENT 'Gender ' ,
smoking          varchar(64)  GENERATED ALWAYS AS (JSON_UNQUOTE(data->"$.""Smoking, y=1 n=0""")                ) COMMENT 'Smoking ' ,
alcohol          varchar(64)  GENERATED ALWAYS AS (JSON_UNQUOTE(data->"$.""Alcohol, y=1 n=0""")                ) COMMENT 'Alcohol ' ,
BaselineStudyUID varchar(256) NULL COMMENT 'studyuid information if needed...' ,
FollowupStudyUID varchar(256) NULL COMMENT 'studyuid information if needed...' ,
MVIStatus        varchar(64)  NULL COMMENT 'micro vascular invasion data from Qayyum' ,
PNPLA3           varchar(64)  NULL COMMENT 'pnpla3 data',
PNPLA73          int          NULL COMMENT 'pnpla3 data',
pnpl2            int          NULL COMMENT 'pnpla3 data',
LabelTraining    int          GENERATED ALWAYS AS (json_unquote(data->'$."Kareems TACE cases=1 others=0"')) COMMENT 'Kareem Truth labels' ,
TTPTraining      INT          GENERATED ALWAYS AS (json_unquote(data->'$."1 = HCCs with shortest TTP 2 = HCCs with longest TTP"')              ) COMMENT 'Training Data Subset' ,
TTP              REAL         GENERATED ALWAYS AS (json_unquote(data->'$."TTP by week (from first TACE session to date of progression/Censoring)"')  ) COMMENT 'TTP ' ,
Survival         REAL         GENERATED ALWAYS AS (JSON_UNQUOTE(data->"$.""survival/week from fist TACE session to death date (1or 2)""")      ) COMMENT 'Survival ' ,
data             JSON         NULL ,
PRIMARY KEY (id) 
);


-- load treatment history 
uploadID = 58 :   3.TACE_List_master(excluded and eligible) cases UPDATED.xlsx    (donwload from MDA coundbox)
-- python ./csvtojson.py --csvfile datalocation/TreatmentHistory.csv
insert into venus_diagram.treatmenthistory(mrn,dataID,BaselineDate,FollowupDate,ChemoUsed,WeeksBetweenBLandTACE,data)
SELECT JSON_UNQUOTE(eu.data->"$.""mdacc""") mrn, JSON_UNQUOTE(eu.data->"$.""first_line""") dataID,json_unquote(eu.data->"$.""Baseline1CT_date""") BaselineDate,json_unquote(data->'$."FollowUpCT_date"') FollowupDate, REPLACE(JSON_UNQUOTE(data->"$.""Chemo Used during TACE/sorafenib, 33 cases' first TACE session chemo ."""),",",":") ChemoUsed,JSON_UNQUOTE(data->"$.""Weeks between BL CT and TACE session""") WeeksBetweenBLandTACE,eu.data
FROM ClinicalStudies.excelUpload eu where eu.uploadID = 58 and JSON_UNQUOTE(eu.data->"$.""mdacc""") is not null; 


-- load qayyum microvascular invasion data
insert into venus_diagram.treatmenthistory(mrn,dataID,MVIStatus,BaselineDate,data)
SELECT JSON_UNQUOTE(eu.data->"$.""mdacc""") mrn, "MVI" dataID, JSON_UNQUOTE(eu.data->"$.""MVI status (Yes or No)""")  MVIStatus , JSON_UNQUOTE(eu.data->"$.""QayyumCases_Preoperative_CT_Data""") BaselineDate, eu.data
FROM ClinicalStudies.excelUpload eu where eu.uploadID = 30 and JSON_UNQUOTE(eu.data->"$.""I.D.""") is not null; 

-- load pnpla3 data
insert into venus_diagram.treatmenthistory(mrn,dataID,BaselineDate,PNPLA3,PNPLA73,pnpl2,data)
SELECT JSON_UNQUOTE(eu.data->"$.""mdacc""") mrn, 
JSON_UNQUOTE(eu.data->"$.""Cases Description""") dataID, 
nullif(JSON_UNQUOTE(eu.data->"$."" First CT study with liver protocol in Clinic station_BL_CT"""),"N/A") BaselineDate, 
JSON_UNQUOTE(eu.data->"$.""rs738409(PNPLA3)""") PNPLA3,
JSON_UNQUOTE(eu.data->"$.""PNPLA_73(rs738409 categories)""") PNPLA73,
JSON_UNQUOTE(eu.data->"$.""pnpl2""") pnpl2,
eu.data
FROM ClinicalStudies.excelUpload eu where eu.uploadID = 29;

-- Update study UIDS... use manual data if available
###checking
select * from venus_diagram.treatmenthistory th
  join venus_diagram.imaginguids rf on  rf.StudyDate=th.BaselineDate  and rf.mrn=th.mrn

##update
update venus_diagram.treatmenthistory th
  join venus_diagram.imaginguids rf on  rf.StudyDate=th.BaselineDate  and rf.mrn=th.mrn
   SET th.BaselineStudyUID = coalesce(json_unquote(th.data->'$."BaselineStudyUID"'),rf.studyUID );
update venus_diagram.treatmenthistory th
  join venus_diagram.imaginguids rf on  rf.StudyDate=th.FollowupDate  and rf.mrn=th.mrn
   SET th.FollowupStudyUID = coalesce(json_unquote(th.data->'$."FollowupStudyUID"'),rf.studyUID );