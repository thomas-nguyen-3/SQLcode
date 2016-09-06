#--------------****************************************--------------------------
#--------- Query Title: TRANSFER DATA FROM SCRDEP1 TO SCRDEP2 USING FEDERATED TABLE
#                    or (grabbing data from WPACS and inserting into DICOMHeaders)
# TABLE INVOLVED: 
# SCRDEP1: 	redmine_default.external_meta_info
# SCRDEP2: 	DICOMHeaders.external_meta_info (THIS IS FEDERATED TABLE)
#			      DICOMHeaders.exmi_selected (THIS IS A TABLE VIEW)
#   		    DICOMHeaders.patients, studies, series, images (these are tables which receives transfered data)
#
# issue: 	If querry takes too long, consider create a real table instead of a view.
#   		  Extended some CHAR limit for certain fields, new transfer data may contain longer value
#
# other note: consider putting these into a store procedure after a few run.
# date: 09/04/2016
#--------------****************************************--------------------------


#First, Create federated table in scrdep2 : external_meta_info
#make sure the federated table can pull data from scrdept1

#############################
#data preparation: create table view  exmi_selected 
#
#enter the filter condition for the select statment here.
#If the data is too large, consider create a real table instead of a view.
#############################

USE `DICOMHeaders`;
CREATE  OR REPLACE VIEW `exmi_selected` AS
SELECT mi.* FROM DICOMHeaders.external_meta_info mi
JOIN 
(
SELECT * FROM DICOMHeaders.external_meta_info
where name = 'Institution Name'  and (value like '%RobertWood%' or value like '%JHNMR%') and uname = 'dicomstore' 
) t1
WHERE  mi.file_id = t1.file_id;


#############################
#Insert into patients table:
#############################
insert into DICOMHeaders.patients (mrn, findStudiesCMD, outside) 
#patients
SELECT * FROM
(
              #extract all studiesUID including duplicate then filter distinct later
              SELECT 
              MAX( IF( name = 'Patient ID', IF (CAST(exmi_selected.value AS UNSIGNED) >0 , CAST(exmi_selected.value AS UNSIGNED) , exmi_selected.value ), NULL) ) AS mrn,
              NULL AS findStudiesCMD,
              1 AS outside
              FROM DICOMHeaders.exmi_selected
              GROUP BY file_id
) t1
#filter distinct 
GROUP BY t1.mrn


####################################################
#insert for DICOMHeaders.studies table:

#note: there are missing field data. make appropriate adjustment ^_^
#assign NULL for current missing fields: studyTime, numberOfImagesInSeries, findSeriesCMD
####################################################

insert into DICOMHeaders.studies (studyDate, studyTime, accessionNumber, studyDescription, name, dob, gender, studyInstanceUID, numberOfImagesInSeries, patientsID, findSeriesCMD, outside) 
#query for studies Table
SELECT t2.studyDate, t2.studyTime, t2.accessionNumber, t2.studyDescription, t2.name, t2.dob, t2.gender, t2.studyInstanceUID, t2.numberOfImagesInSeries, pa.patientsID, t2.findSeriesCMD, t2.outside
FROM
(
       SELECT * FROM
       (
              #extract all studiesUID including duplicate then filter distinct later
              SELECT '#number_id' as studiesId,
              #MAX( IF( name = 'Study Date', value, NULL) ) AS studyDate,
              MAX( IF( name = 'Study Date', date_format(str_to_date(value, '%Y%m%d'),'%Y-%m-%d'), NULL) ) AS studyDate,
              NULL AS studyTime,
              MAX( IF( name = 'Accession Number', value, NULL) ) AS accessionNumber,
              MAX( IF( name = 'Study Description', value, NULL) ) AS studyDescription,
              MAX( IF( name = 'Patient\'s Name', value, NULL) ) AS name,
              MAX( IF( name = 'Patient\'s Birth Date', date_format(str_to_date(value, '%Y%m%d'),'%Y-%m-%d'), NULL) ) AS dob,
              MAX( IF( name = 'Patient\'s Sex', value, NULL) ) AS gender,
              MAX( IF( name = 'Study Instance UID', value, NULL) ) AS studyInstanceUID,
              NULL AS numberOfImagesInSeries,
              #'**ToBeInserted**' AS patientsID,
              NULL AS findSeriesCMD,
              1 AS outside,
              MAX( IF( name = 'Patient ID', CAST(exmi_selected.value AS UNSIGNED), NULL) ) AS mrn
              FROM DICOMHeaders.exmi_selected
              GROUP BY file_id
       ) t1
       #filter distinct studyUID
       GROUP BY t1.studyInstanceUID
) t2
JOIN DICOMHeaders.patients pa
on pa.mrn = t2.mrn

####################################################
#insert for DICOMHeaders.series

#NOTE: there are missing field data. make appropriate adjustment ^_^
#assign NULL for current missing fields:  seriesTime, alternateSeriesDescription, otherPatientIDs, age, numberOfImages,
#findImageCMD, moveSeries, moveSeriesCMD, movedSeries, MRTISeriesID,
####################################################

insert into DICOMHeaders.series (seriesInstanceUID, studiesID, seriesDate, seriesTime, modality,  manufacturer, institutionName,  stationName, seriesDescription, alternateSeriesDescription, otherPatientIDs,
age, weight, scanningSequence, sequenceVariant, scanOptions, mrAcquisitionType, magneticFieldStrength, echoTrainLength, protocolName, seriesNumber,
numberOfImages, findImageCMD, moveSeries, moveSeriesCMD, movedSeries, MRTISeriesID, outside) 
#query for series data
SELECT t2.seriesInstanceUID, st.studiesID, t2.seriesDate, t2.seriesTime, t2.modality,  t2.manufacturer, t2.institutionName,  t2.stationName, t2.seriesDescription, t2.alternateSeriesDescription, t2.otherPatientIDs,
t2.age, t2.weight, t2.scanningSequence, t2.sequenceVariant, t2.scanOptions, t2.mrAcquisitionType, t2.magneticFieldStrength, t2.echoTrainLength, t2.protocolName, t2.seriesNumber,
t2.numberOfImages, t2.findImageCMD, t2.moveSeries, t2.moveSeriesCMD, t2.movedSeries, t2.MRTISeriesID, t2.outside
FROM
(
SELECT * FROM 
(
       #get all - including duplicate since data is in nosql structure
       SELECT '#number_id' as seriesID,
       MAX( IF( name = 'Series Instance UID', value, NULL) ) AS seriesInstanceUID,
       #'**ToBeInserted**' as studiesID,
       MAX( IF( name = 'Series Date', date_format(str_to_date(value, '%Y%m%d'),'%Y-%m-%d'), NULL) ) AS seriesDate,
       NULL AS seriesTime,
       MAX( IF( name = 'Modality', value, NULL) ) AS modality,
       MAX( IF( name = 'Manufacturer', value, NULL) ) AS manufacturer,
       MAX( IF( name = 'Institution Name', value, NULL) ) AS institutionName,
       MAX( IF( name = 'Station Name', value, NULL) ) AS stationName,
       MAX( IF( name = 'Series Description', value, NULL) ) AS seriesDescription,
       NULL AS alternateSeriesDescription,
       NULL AS otherPatientIDs,
       NULL AS age,
       MAX( IF( name = 'Patient\'s Weight', value, NULL) ) AS weight,
       MAX( IF( name = 'Scanning Sequence', value, NULL) ) AS scanningSequence,
       MAX( IF( name = 'Sequence Variant', value, NULL) ) AS sequenceVariant,
       MAX( IF( name = 'Scan Options', value, NULL) ) AS scanOptions,
       MAX( IF( name = 'MR Acquisition Type', value, NULL) ) AS mrAcquisitionType,
       MAX( IF( name = 'Magnetic Field Strength', value, NULL) ) AS magneticFieldStrength,
       MAX( IF( name = 'Echo Train Length', value, NULL) ) AS echoTrainLength,
       MAX( IF( name = 'Protocol Name', value, NULL) ) AS protocolName,
       MAX( IF( name = 'Series Number', value, NULL) ) AS seriesNumber,
       NULL AS numberOfImages,
       NULL AS findImageCMD,
       NULL AS moveSeries,
       NULL AS moveSeriesCMD,
       NULL AS movedSeries,
       NULL AS MRTISeriesID,
       1 AS outside,
       MAX( IF( name = 'Study Instance UID', value, NULL) ) AS studyInstanceUID
       FROM DICOMHeaders.exmi_selected
       GROUP BY file_id
) t1
#filter distinct 
GROUP BY t1.seriesInstanceUID
) t2
JOIN DICOMHeaders.studies st
on t2.studyInstanceUID = st.studyInstanceUID


####################################################
#insert for DICOMHeaders.images

#NOTE: there are missing field data. make appropriate adjustment ^_^
#assign NULL for current missing fields:  kvp, fieldStrength, exposureTime, xRayTubeCurrent, filterType,
# imagesInAcquisition, inversionTime,

####################################################
insert into DICOMHeaders.images (imageType, sopInstanceUID, acquisitionDate, contentDate, acquisitionTime, contentTime, scanningSequence, sequenceVariant, mrAcquisitionType, sequenceName,
sliceThickness, kvp, repetitionTime, echoTime, numberOfAvgs, echoNumbers, fieldStrength, spacingBetweenSlices, numberOfPhaseEncodingSteps,
exposureTime, xRayTubeCurrent, filterType, transmitCoilName, acquisitionMatrix, flipAngle, instanceNumber, imagePositionPatient, imageOrientationPatient, frameOfReferenceUID,
imagesInAcquisition, sliceLocation, rows, columns, pixelSpacing, bitsAllocated, bitsStored, inversionTime,
seriesID, outside)

SELECT t2.imageType, t2.sopInstanceUID, t2.acquisitionDate, t2.contentDate, t2.acquisitionTime, t2.contentTime, t2.scanningSequence, t2.sequenceVariant, t2.mrAcquisitionType, t2.sequenceName,
t2.sliceThickness, t2.kvp, t2.repetitionTime, t2.echoTime, t2.numberOfAvgs, t2.echoNumbers, t2.fieldStrength, t2.spacingBetweenSlices, t2.numberOfPhaseEncodingSteps,
t2.exposureTime, t2.xRayTubeCurrent, t2.filterType, t2.transmitCoilName, t2.acquisitionMatrix, t2.flipAngle, t2.instanceNumber, t2.imagePositionPatient, t2.imageOrientationPatient, t2.frameOfReferenceUID,
t2.imagesInAcquisition, t2.sliceLocation, t2.rows, t2.columns, t2.pixelSpacing, t2.bitsAllocated, t2.bitsStored, t2.inversionTime,
se.seriesID, t2.outside
FROM
(
   SELECT * FROM 
   (
      SELECT '#number_id' as imageID,
      MAX( IF( name = 'Image Type', value, NULL) ) AS imageType,
      MAX( IF( name = 'SOP Instance UID', value, NULL) ) AS sopInstanceUID,
      MAX( IF( name = 'Acquisition Date', date_format(str_to_date(value, '%Y%m%d'),'%Y-%m-%d'), NULL) ) AS acquisitionDate,
      MAX( IF( name = 'Content Date', date_format(str_to_date(value, '%Y%m%d'),'%Y-%m-%d'), NULL) ) AS contentDate,
      MAX( IF( name = 'Acquisition Time', value, NULL) ) AS acquisitionTime,
      MAX( IF( name = 'Content Time', value, NULL) ) AS contentTime,
      MAX( IF( name = 'Scanning Sequence', value, NULL) ) AS scanningSequence,
      MAX( IF( name = 'Sequence Variant', value, NULL) ) AS sequenceVariant,
      MAX( IF( name = 'MR Acquisition Type', value, NULL) ) AS mrAcquisitionType,
      MAX( IF( name = 'Sequence Name', value, NULL) ) AS sequenceName,
      MAX( IF( name = 'Slice Thickness', value, NULL) ) AS sliceThickness,
      NULL AS kvp,
      MAX( IF( name = 'Repetition Time', value, NULL) ) AS repetitionTime,
      MAX( IF( name = 'Echo Time', value, NULL) ) AS echoTime,
      MAX( IF( name = 'Number of Averages', value, NULL) ) AS numberOfAvgs,
      MAX( IF( name = 'Echo Number(s)', value, NULL) ) AS echoNumbers,
      NULL AS fieldStrength,
      MAX( IF( name = 'Spacing Between Slices', value, NULL) ) AS spacingBetweenSlices,
      MAX( IF( name = 'Number of Phase Encoding Steps', value, NULL) ) AS numberOfPhaseEncodingSteps,
      NULL AS exposureTime,
      NULL AS xRayTubeCurrent,
      NULL AS filterType,
      MAX( IF( name = 'Transmit Coil Name', value, NULL) ) AS transmitCoilName,
      MAX( IF( name = 'Acquisition Matrix', value, NULL) ) AS acquisitionMatrix,
      MAX( IF( name = 'Flip Angle', value, NULL) ) AS flipAngle,
      MAX( IF( name = 'Instance Number', value, NULL) ) AS instanceNumber,
      MAX( IF( name = 'Image Position (Patient)', value, NULL) ) AS imagePositionPatient,
      MAX( IF( name = 'Image Orientation (Patient)', value, NULL) ) AS imageOrientationPatient,
      MAX( IF( name = 'Frame of Reference UID', value, NULL) ) AS frameOfReferenceUID,
      NULL AS imagesInAcquisition,
      MAX( IF( name = 'Slice Location', value, NULL) ) AS sliceLocation,
      MAX( IF( name = 'Rows', value, NULL) ) AS rows,
      MAX( IF( name = 'Columns', value, NULL) ) AS columns,
      MAX( IF( name = 'Pixel Spacing', value, NULL) ) AS pixelSpacing,
      MAX( IF( name = 'Bits Allocated', value, NULL) ) AS bitsAllocated,
      MAX( IF( name = 'Bits Stored', value, NULL) ) AS bitsStored,
      NULL AS inversionTime,
      '**ToBeInserted**' as seriesID,
      1 AS outside,
      MAX( IF( name = 'Series Instance UID', value, NULL) ) AS seriesInstanceUID
      FROM DICOMHeaders.exmi_selected
      GROUP BY file_id
   ) t1
               #filter distinct 
               GROUP BY t1.sopInstanceUID
)t2
JOIN DICOMHeaders.series se
on t2.seriesInstanceUID = se.seriesInstanceUID

