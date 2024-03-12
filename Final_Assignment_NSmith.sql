--**********************************************************************************************--
-- Title: ITFnd130Final
-- Author: Nicholas Smith
-- Desc: This file demonstrates how to design and create; 
--       tables, views, and stored procedures
-- Change Log: When,Who,What
-- 2024-03-07, Nicholas Smith,Created File
--***********************************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'ITFnd130FinalDB_NicholasSmith')
	 Begin 
	  Alter Database [ITFnd130FinalDB_NicholasSmith] set Single_user With Rollback Immediate;
	  Drop Database ITFnd130FinalDB_NicholasSmith;
	 End
	Create Database ITFnd130FinalDB_NicholasSmith;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use ITFnd130FinalDB_NicholasSmith;
GO

-- Create Tables (Review Module 01)-- 

CREATE TABLE Courses
	([CourseID] [int] IDENTITY(1,1) NOT NULL
	,[CourseName] [nvarchar](100) NOT NULL
	,[CourseStartDate] [Date] NULL
	,[CourseEndDate] [Date] NULL
	,[CourseStartTime] [Time] NULL
	,[CourseEndTime] [Time] NULL
	,CourseDaysOfWeek [nvarchar](100) NULL
	,CourseCurrentPrice [money] NULL
	);
GO

CREATE TABLE Students
	([StudentID] [int] IDENTITY(1,1) NOT NULL
	,[StudentFirstName] [nvarchar](100) NOT NULL
	,[StudentLastName] [nvarchar](100) NOT NULL
	,[StudentNumber] [nvarchar](100) NOT NULL
	,[StudentEmail] [nvarchar](100) NOT NULL
	,[StudentPhone] [nvarchar](100) NOT NULL
	,[StudentStreet] [nvarchar](100) NOT NULL
	,[StudentCity] [nvarchar](100) NOT NULL
	,[StudentStateCode] [nchar](2) NOT NULL
	,[StudentZipcode] [nvarchar](100) NOT NULL
	);
GO

-- Logic behind NOT NULL decisions for all fields is that this information will be required to register for a class.

CREATE TABLE Enrollments
	([EnrollmentID] [int] IDENTITY(1,1) NOT NULL
	,[EnrollmentDate] [Date] NOT NULL
	,[EnrollmentPrice] [money] NOT NULL
	,[StudentID] [int] NOT NULL
	,[CourseID] [int] NOT NULL
	);
GO

-- Add Constraints (Review Module 02) -- 

BEGIN -- Courses
	ALTER TABLE Courses
		ADD CONSTRAINT pkCoursID
			PRIMARY KEY (CourseID);
	ALTER TABLE Courses
		ADD CONSTRAINT ukCourseName
			UNIQUE (CourseName);
	ALTER TABLE Courses
		ADD CONSTRAINT ckCourseStartDate
			CHECK (CourseStartDate IS NULL OR ISDATE(CONVERT(VARCHAR, CourseStartDate, 23)) = 1);
END
GO

BEGIN -- Students
	ALTER TABLE Students
		ADD CONSTRAINT pkStudentID
			PRIMARY KEY (StudentID);
	ALTER TABLE Students
		ADD CONSTRAINT ckStudentPhone
			CHECK (StudentPhone LIKE '___-___-____');
	ALTER TABLE Students
		ADD CONSTRAINT ckStudentStateCode
			CHECK (StudentStateCode LIKE '[A-Z][A-Z]');
	ALTER TABLE Students
		ADD CONSTRAINT ckStudentZipcode
			CHECK (ISNUMERIC(StudentZipcode) = 1);
END
GO

BEGIN -- Enrollments
	ALTER TABLE Enrollments
		ADD CONSTRAINT pkEnrollmentID
			PRIMARY KEY (EnrollmentID);
	ALTER TABLE Enrollments
		ADD CONSTRAINT ckEnrollmentDate
			CHECK (EnrollmentDate IS NULL OR ISDATE(CONVERT(VARCHAR, EnrollmentDate, 23)) = 1);
	ALTER TABLE Enrollments
		ADD CONSTRAINT ckEnrollmentsStudentID
			FOREIGN KEY (StudentID) REFERENCES Students(StudentID);
	ALTER TABLE Enrollments
		ADD CONSTRAINT ckEnrollmentsCourseID
			FOREIGN KEY (CourseID) REFERENCES Courses(CourseID);
END
GO

-- Add Views (Review Module 03 and 06) -- 

CREATE VIEW vCourses
	WITH SCHEMABINDING
	AS
		SELECT [CourseID]
		,[CourseName]
		,[CourseStartDate]
		,[CourseEndDate]
		,[CourseStartTime]
		,[CourseEndTime]
		,[CourseDaysOfWeek]
		,[CourseCurrentPrice]
		FROM dbo.Courses;
GO

CREATE VIEW vStudents
	WITH SCHEMABINDING
	AS
		SELECT [StudentID]
		,[StudentFirstName]
		,[StudentLastName]
		,[StudentNumber]
		,[StudentEmail]
		,[StudentPhone]
		,[StudentStreet]
		,[StudentCity]
		,[StudentStateCode]
		,[StudentZipcode]
		FROM dbo.Students;
GO

CREATE VIEW vEnrollments
	WITH SCHEMABINDING
	AS
		SELECT [EnrollmentID] 
		,[EnrollmentDate]
		,[EnrollmentPrice]
		,[StudentID]
		,[CourseID]
		FROM dbo.Enrollments;
GO

--< Test Tables by adding Sample Data >--  

	-- Sample data will be the data in the excel file. All additional data afterward will be handled by stored procedures.

BEGIN TRY
	BEGIN TRAN
		INSERT INTO Courses (CourseName
			,CourseStartDate
			,CourseEndDate
			,CourseStartTime
			,CourseEndTime
			,CourseDaysOfWeek
			,CourseCurrentPrice)
		VALUES ('SQL1 - Winter 2017', '2017-01-10', '2017-01-24', '6:00', '8:50', 'T', 399)
			,('SQL2 - Winter 2017', '2017-01-31', '2017-02-14', '6:00', '8:50', 'T', 399)
	COMMIT TRAN;
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN
		END
	PRINT ERROR_NUMBER();
	PRINT ERROR_MESSAGE();
END CATCH;
GO

BEGIN TRY
	BEGIN TRAN
		INSERT INTO Students (StudentFirstName
			,StudentLastName
			,StudentNumber
			,StudentEmail
			,StudentPhone
			,StudentStreet
			,StudentCity
			,StudentStateCode
			,StudentZipcode)
		VALUES ('Bob', 'Smith', 'B-Smith-071', 'Bsmith@HipMail.com', '206-111-2222', '123 Main St.', 'Seattle', 'WA', 98001)
			,('Sue', 'Jones', 'S-Jones-003', 'SueJones@YaYou.com', '206-231-4321', '333 1st Ave.', 'Seattle', 'WA', 98001)
	COMMIT TRAN;
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN
		END
	PRINT ERROR_NUMBER();
	PRINT ERROR_MESSAGE();
END CATCH;
GO

BEGIN TRY
	BEGIN TRAN
		INSERT INTO Enrollments (EnrollmentDate
			,EnrollmentPrice
			,StudentID
			,CourseID)
		VALUES ('2017-01-03', 399, 1, 1)
			,('2016-12-14', 349, 2, 1)
			,('2017-01-12', 399, 1, 2)
			,('2016-12-14', 349, 2, 2)
	COMMIT TRAN;
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN
		END
	PRINT ERROR_NUMBER();
	PRINT ERROR_MESSAGE();
END CATCH;
GO

-- Add Stored Procedures (Review Module 04 and 08) --

	-- Stored procedure needed for each table, Add/Alter/Delete fuctions.

	-- Add Courses Stored Procedure

CREATE PROC spAddCourses
	(@CourseName nvarchar(100)
	,@CourseStartDate DATE
	,@CourseEndDate DATE
	,@CourseStartTime TIME
	,@CourseEndTime TIME
	,@CourseDaysOfWeek nvarchar(100)
	,@CourseCurrentPrice MONEY
	)
AS
BEGIN
	DECLARE @RC INT = 0;
	BEGIN TRY
		BEGIN TRAN;
			INSERT INTO Courses (CourseName
				,CourseStartDate
				,CourseEndDate
				,CourseStartTime
				,CourseEndTime
				,CourseDaysOfWeek
				,CourseCurrentPrice
				)
			VALUES (@CourseName
				,@CourseStartDate
				,@CourseEndDate
				,@CourseStartTime
				,@CourseEndTime
				,@CourseDaysOfWeek
				,@CourseCurrentPrice
				);
		COMMIT TRAN;
		SET @RC = +1;
	END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN
		END
	PRINT ERROR_NUMBER();
	PRINT ERROR_MESSAGE();
	SET @RC = -1;
END CATCH
RETURN @RC;
END
GO

	-- Add Students Stored Procedure

CREATE PROC spAddStudents
	(@StudentFirstName nvarchar(100)
	,@StudentLastName nvarchar(100)
	,@StudentNumber nvarchar(100)
	,@StudentEmail nvarchar(100)
	,@StudentPhone nvarchar(100)
	,@StudentStreet nvarchar(100)
	,@StudentCity nvarchar(100)
	,@StudentStateCode nchar(2)
	,@StudentZipcode nvarchar(100)
	)
AS
BEGIN
	DECLARE @RC INT = 0;
	BEGIN TRY
		BEGIN TRAN;
			INSERT INTO Students (StudentFirstName
				,StudentLastName
				,StudentNumber
				,StudentEmail
				,StudentPhone
				,StudentStreet
				,StudentCity
				,StudentStateCode
				,StudentZipcode
				)
			VALUES (@StudentFirstName
				,@StudentLastName
				,@StudentNumber
				,@StudentEmail
				,@StudentPhone
				,@StudentStreet
				,@StudentCity
				,@StudentStateCode
				,@StudentZipcode
				);
		COMMIT TRAN;
		SET @RC = +1;
	END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN
		END
	PRINT ERROR_NUMBER();
	PRINT ERROR_MESSAGE();
	SET @RC = -1;
END CATCH
RETURN @RC;
END
GO

	-- Add Enrollments Stored Procedure

CREATE PROC spAddEnrollments
	(@EnrollmentDate DATE
	,@EnrollmentPrice MONEY
	,@StudentID INT
	,@CourseID INT
	)
AS
BEGIN
	DECLARE @RC INT = 0;
	BEGIN TRY
		BEGIN TRAN;
			INSERT INTO Enrollments (EnrollmentDate
				,EnrollmentPrice
				,StudentID
				,CourseID
				)
			VALUES (@EnrollmentDate
				,@EnrollmentPrice
				,@StudentID
				,@CourseID
				);
		COMMIT TRAN;
		SET @RC = +1;
	END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN
		END
	PRINT ERROR_NUMBER();
	PRINT ERROR_MESSAGE();
	SET @RC = -1;
END CATCH
RETURN @RC;
END
GO

	-- Update Courses Stored Procedure

CREATE PROC spUpdateCourses
	(@CourseID INT
	,@CourseName nvarchar(100)
	,@CourseStartDate DATE
	,@CourseEndDate DATE
	,@CourseStartTime TIME
	,@CourseEndTime TIME
	,@CourseDaysOfWeek nvarchar(100)
	,@CourseCurrentPrice MONEY
	)
AS
	BEGIN
	DECLARE @RC INT = 0;
	BEGIN TRY
		BEGIN TRAN;
			UPDATE Courses
				SET CourseName = @CourseName
					,CourseStartDate = @CourseStartDate
					,CourseEndDate = @CourseEndDate
					,CourseStartTime = @CourseStartTime
					,CourseEndTime = @CourseEndTime
					,CourseDaysOfWeek = @CourseDaysOfWeek
					,CourseCurrentPrice = @CourseCurrentPrice
				WHERE CourseID = @CourseID;
		COMMIT TRAN;
		SET @RC = +1;
	END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN
		END
	PRINT ERROR_NUMBER();
	PRINT ERROR_MESSAGE();
	SET @RC = -1;
END CATCH
RETURN @RC;
END
GO

	-- Update Students Stored Procedure

CREATE PROC spUpdateStudents
	(@StudentID INT
	,@StudentFirstName nvarchar(100)
	,@StudentLastName nvarchar(100)
	,@StudentNumber nvarchar(100)
	,@StudentEmail nvarchar(100)
	,@StudentPhone nvarchar(100)
	,@StudentStreet nvarchar(100)
	,@StudentCity nvarchar(100)
	,@StudentStateCode nchar(2)
	,@StudentZipcode nvarchar(100)
	)
AS
	BEGIN
	DECLARE @RC INT = 0;
	BEGIN TRY
		BEGIN TRAN;
			UPDATE Students
				SET StudentFirstName = @StudentFirstName
					,StudentLastName = @StudentLastName
					,StudentNumber = @StudentNumber
					,StudentEmail = @StudentEmail
					,StudentPhone = @StudentPhone
					,StudentStreet = @StudentStreet
					,StudentCity = @StudentCity
					,StudentStateCode = @StudentStateCode
					,StudentZipcode = @StudentZipcode
				WHERE StudentID = @StudentID;
		COMMIT TRAN;
		SET @RC = +1;
	END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN
		END
	PRINT ERROR_NUMBER();
	PRINT ERROR_MESSAGE();
	SET @RC = -1;
END CATCH
RETURN @RC;
END
GO

	-- Update Enrollments Stored Procedure

CREATE PROC spUpdateEnrollments
	(@EnrollmentID INT
	,@EnrollmentDate DATE
	,@EnrollmentPrice MONEY
	,@StudentID INT
	,@CourseID INT
	)
AS
	BEGIN
	DECLARE @RC INT = 0;
	BEGIN TRY
		BEGIN TRAN;
			UPDATE Enrollments
				SET EnrollmentDate = @EnrollmentDate
					,EnrollmentPrice = @EnrollmentPrice
					,StudentID = @StudentID
					,CourseID = @CourseID
				WHERE EnrollmentID = @EnrollmentID
		COMMIT TRAN;
		SET @RC = +1;
	END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN
		END
	PRINT ERROR_NUMBER();
	PRINT ERROR_MESSAGE();
	SET @RC = -1;
END CATCH
RETURN @RC;
END
GO


	-- Delete Courses Stored Procedure

CREATE PROC spDeleteCourses
	(@CourseID INT
	)
AS
	BEGIN
	DECLARE @RC INT = 0;
	BEGIN TRY
		BEGIN TRAN;
			DELETE
				FROM Courses
				WHERE CourseID = @CourseID;
		COMMIT TRAN;
		SET @RC = +1;
	END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN
		END
	PRINT ERROR_NUMBER();
	PRINT ERROR_MESSAGE();
	SET @RC = -1;
END CATCH
RETURN @RC;
END
GO

	-- Delete Students Stored Procedure

CREATE PROC spDeleteStudents
	(@StudentID INT
	)
AS
	BEGIN
	DECLARE @RC INT = 0;
	BEGIN TRY
		BEGIN TRAN;
			DELETE
				FROM Students
				WHERE StudentID = @StudentID;
		COMMIT TRAN;
		SET @RC = +1;
	END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN
		END
	PRINT ERROR_NUMBER();
	PRINT ERROR_MESSAGE();
	SET @RC = -1;
END CATCH
RETURN @RC;
END
GO

	-- Delete Enrollments Stored Procedure

CREATE PROC spDeleteEnrollments
	(@EnrollmentID INT
	)
AS
	BEGIN
	DECLARE @RC INT = 0;
	BEGIN TRY
		BEGIN TRAN;
			DELETE
				FROM Enrollments
				WHERE EnrollmentID = @EnrollmentID;
		COMMIT TRAN;
		SET @RC = +1;
	END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRAN
		END
	PRINT ERROR_NUMBER();
	PRINT ERROR_MESSAGE();
	SET @RC = -1;
END CATCH
RETURN @RC;
END
GO

-- Set Permissions --

DENY SELECT ON Courses to Public;
GO

DENY SELECT ON Students to Public;
GO

DENY SELECT ON Enrollments to Public;
GO

GRANT SELECT ON vCourses to Public;
GO

GRANT SELECT ON vStudents to Public;
GO

GRANT SELECT ON vEnrollments to Public;
GO

--< Test Sprocs >-- 

	-- SPROCs testing is commented out so that rest of code can run in one block.

	-- Test spAddCourses

/*
EXEC spAddCourses
	@CourseName = 'SQL3 - Spring 2018'
	,@CourseStartDate = '2017-03-10'
	,@CourseEndDate = '2017-03-24'
	,@CourseStartTime = '6:30'
	,@CourseEndTime = '8:30'
	,@CourseDaysOfWeek = 'W'
	,@CourseCurrentPrice = 499
	;
GO

	-- Test spAddStudents

EXEC spAddStudents
	@StudentFirstName = 'Edmond'
	,@StudentLastName = 'Dantes'
	,@StudentNumber = 'E-Dantes-034'
	,@StudentEmail = 'Ed.Dantes@chateaudif.com'
	,@StudentPhone = '206-555-1846'
	,@StudentStreet = 'No. 27 Rue du Helder'
	,@StudentCity = 'Paris'
	,@StudentStatecode = 'FR'
	,@StudentZipcode = '75009'
	;
GO


	-- Test spAddEnrollments

EXEC spAddEnrollments
	@EnrollmentDate = '2017-03-07'
	,@EnrollmentPrice = 499
	,@StudentID = 3
	,@CourseID = 3
	;
GO

	-- Test spUpdateCourses

EXEC spUpdateCourses
	@CourseID = 3
	,@CourseName = 'How to Get Revenge'
	,@CourseStartDate = '1815-02-28'
	,@CourseEndDate = '1829-02-26'
	,@CourseStartTime = '0:00'
	,@CourseEndTime = '11:59'
	,@CourseDaysOfWeek = 'M/T/W/Th/F/S/U'
	,@CourseCurrentPrice = 0
GO

	-- Test spUpdateStudents

EXEC spUpdateStudents
	@StudentID = 3
	,@StudentFirstName = 'Abbe'
	,@StudentLastName = 'Busoni'
	,@StudentNumber = 'A-Busoni-000'
	,@StudentEmail = 'ABusoni@disguise.com'
	,@StudentPhone = '206-555-1830'
	,@StudentStreet = '30 Avenue des Champs Elysees'
	,@StudentCity = 'Paris'
	,@StudentStateCode = 'FR'
	,@StudentZipCode = '75008'
GO

	-- Test spUpdateEnrollments

EXEC spUpdateEnrollments
	@EnrollmentID = 5
	,@EnrollmentDate = '1815-02-28'
	,@EnrollmentPrice = 0.00
	,@StudentID = 3
	,@CourseID = 3
GO

	-- Test spDeleteCourses

EXEC spDeleteCourses
	@CourseID = 3
GO

	-- Test spDeleteStudents

EXEC spDeleteStudents
	@StudentID = 3
GO

	-- Test spDeleteEnrollments

EXEC spDeleteEnrollments
	@EnrollmentID = 5
GO

*/

SELECT * FROM vCourses;
SELECT * FROM vStudents;
SELECT * FROM vEnrollments;

--{ IMPORTANT!!! }--

-- To get full credit, your script must run without having to highlight individual statements!!!  
/**************************************************************************************************/