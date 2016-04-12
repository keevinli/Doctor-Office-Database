CREATE DATABASE DoctorOffice

USE DoctorOffice

CREATE TABLE Person 
(
	PersonID INT PRIMARY KEY,
	FirstName VARCHAR(20) NOT NULL,
	LastName VARCHAR(20) NOT NULL,
	MiddleName VARCHAR(20),
	Street VARCHAR(50),
	City VARCHAR(20),
	States VARCHAR(20),
	ZipCode INT,
	PhoNO INT NOT NULL,
	DateOfBirth DATETIME NOT NULL,
	RoleID INT,
	RegisterDate DATE
)

CREATE TABLE RoleTable
(
	RoleID INT PRIMARY KEY,
	Role VARCHAR(20) NOT NULL
)

CREATE TABLE Doctor
(
	DoctorID INT PRIMARY KEY,
	Speciality VARCHAR(50)
)


CREATE TABLE Patient
(
	PatientID INT PRIMARY KEY,
	SecondaryPhoNo INT,
)


CREATE TABLE VisitRecord
(
	VisitDate DATETIME,
	RecordID INT PRIMARY KEY,
	DoctorID INT REFERENCES Doctor(DoctorID),
	PatientID INT REFERENCES Patient(PatientID),
	DoctorNote VARCHAR(300)
)

CREATE TABLE Prescription
(
	PrescriptionID INT PRIMARY KEY,
	RecordID INT,
)

CREATE TABLE PrescripInfo
(
	PrescriptionID INT PRIMARY KEY,
	Prescription VARCHAR(100)
)

CREATE TABLE Test
(
	TestID INT PRIMARY KEY,
	RecordID INT
)

CREATE TABLE TestInfo
(
	TestID INT PRIMARY KEY,
	Test VARCHAR(50)
)


CREATE VIEW VDocPatient
WITH ENCRYPTION
AS
SELECT (PER.FirstName + ' ' + PER.LastName) AS [Patient Name]
FROM VisitRecord as VR INNER JOIN Person AS PER
ON VR.PatientID = PER.PersonID
UNION
SELECT (PER.FirstName + ' ' + PER.LastName) AS [Doctor Name], VR.VisitDate
FROM VisitRecord as VR INNER JOIN Person AS PER
ON VR.DoctorID = PER.PersonID


CREATE VIEW vPatientPrescrip
AS
SELECT (PER.FirstName + ' ' + PER.LastName) AS [Patient Name], PRIN.Prescription
FROM VisitRecord AS VR INNER JOIN Person AS PER
ON VR.PatientID = PER.PersonID
INNER JOIN Prescription AS PRE
ON VR.RecordID = PRE.RecordID 
INNER JOIN PrescripInfo AS PRIN
ON PRE.PrescriptionID = PRIN.PrescriptionID


-- Create trigger on the prescription so that every time a prescription is updated or added a entry is made in the audit table. The audit table will have the following
-- Patient name
-- Action(indicate update or added)
-- Prescription
-- Date of modification
CREATE TABLE AuditTable
(
	FirstName VARCHAR(30),
	LastName VARCHAR(30),
	ActionInfo VARCHAR(10),
	Prescription VARCHAR(30),
	DateOfModi DATE
)

CREATE TRIGGER PrescripTrigger 
ON PrescripInfo
AFTER UPDATE, INSERT
AS
BEGIN
	DECLARE @ActionInfo VARCHAR(10),
			@Date DATE,
			@EventData XML,
			@FirstName VARCHAR(30),
			@LastName VARCHAR(30),
			@Prescription VARCHAR(30)
	SET @Date = GETDATE()
	SET @EventData = EVENTDATA()
	SET @ActionInfo = @EventData.value('(/EVENT_INSTANCE/EventType)[1]', 'varchar(30)')
	IF @ActionInfo = 'INSERT'
		SELECT @Prescription = Prescription FROM inserted
	INSERT INTO AuditTable VALUES(@FirstName, @LastName, @ActionInfo, @Prescription, @Date)

END

-- Create a stored procedure which I can execute to create a list of all patients who get prescribed medicine which is called asprin210
CREATE PROC CreatePatient 
AS
SELECT PER.FirstName, PER.LastName
FROM PrescripInfo AS PRIN INNER JOIN Prescription AS PRE
ON PRIN.PrescriptionID = PRE.PrescriptionID
INNER JOIN VisitRecord AS VR
ON PRE.RecordID = VR.RecordID
INNER JOIN Person AS PER
ON PER.PersonID = VR.PatientID
WHERE PRIN.Prescription = 'asprin210'


-- Create a stored procedure which will accept a parameter which is patient name and give me a list of
-- Patient name
-- Prescription

CREATE PROC GetPrescription
	@FirstName VARCHAR(30),
	@LastName VARCHAR(30)
AS
SELECT @FirstName, @LastName, PRIN.Prescription
FROM VisitRecord AS VR INNER JOIN Person AS PER
ON VR.PatientID = PER.PersonID
INNER JOIN Prescription AS PRE
ON VR.RecordID = PRE.RecordID 
INNER JOIN PrescripInfo AS PRIN
ON PRE.PrescriptionID = PRIN.PrescriptionID
WHERE PER.FirstName = @FirstName AND PER.LastName = @LastName


-- Extra Credit
-- A script to generate a report which lists all the New patients registered this month.
DECLARE @CurrentDate DATE
SET @CurrentDate = GETDATE()

SELECT VR.PatientID
FROM Person AS PER INNER JOIN VisitRecord AS VR
ON PER.PersonID = VR.PatientID
WHERE DATEDIFF(DAY, @CurrentDate, PER.RegisterDate) <= 31



-- A script to generate a report for all the patients who changed doctors in the same specialty.
SELECT UNIQUE VR.PatientID, Doc.Speciality
FROM VisitRecord AS VR INNER JOIN Doctor AS DOC 
ON VR.DoctorID = DOC.DoctorID
GROUP BY VR.PatientID, DOC.Speciality

