USE [Port]
GO

---------------------------------------------------------- Dirty Reads ----------------------------------------------------------
--- T1: update + delay + rollback 
CREATE OR ALTER PROCEDURE DirtyReads_T1 AS
BEGIN
	BEGIN TRAN
	BEGIN TRY
		UPDATE Corporations SET CorporationCountry='China' WHERE CorpoName='SinoTrans'
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('UPDATE', 'Corporations', CURRENT_TIMESTAMP)
		WAITFOR DELAY '00:00:10'
		ROLLBACK TRAN
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('ROLLBACK - GOOD', 'Corporations', CURRENT_TIMESTAMP)
		SELECT 'Update Corporations Transaction GOOD rollback'
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN
		SELECT 'Update Corporations Transaction BAD rollback'
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('ROLLBACK - BAD', 'Corporations', CURRENT_TIMESTAMP)
	END CATCH
END
GO

--- T2: select + delay + select
CREATE OR ALTER PROCEDURE DirtyReads_T2 AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED -- issue!
	BEGIN TRAN
	BEGIN TRY
		SELECT * FROM Corporations;
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('SELECT', 'Corporations', CURRENT_TIMESTAMP)
		WAITFOR DELAY '00:00:15'
		SELECT * FROM Corporations;
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('SELECT', 'Corporations', CURRENT_TIMESTAMP)
		COMMIT TRAN
		SELECT 'Selected all from Corporations transaction committed' 
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN
		SELECT 'Rolled back the select all from Corporations transaction' 
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE DirtyReads_T2_Solution AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED -- solution!
	BEGIN TRAN
	BEGIN TRY
		SELECT * FROM Corporations;
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('SELECT', 'Corporations', CURRENT_TIMESTAMP)
		WAITFOR DELAY '00:00:15'
		SELECT * FROM Corporations;
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('SELECT', 'Corporations', CURRENT_TIMESTAMP)
		COMMIT TRAN
		SELECT 'Selected all from Corporations transaction committed' 
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN
		SELECT 'Rolled back the select all from Corporations transaction' 
	END CATCH
END
GO

---------------------------------------------------------- Non-repeatable Reads ----------------------------------------------------------
--- T1: delay + update + commit
CREATE OR ALTER PROCEDURE NonRepeatableReads_T1 AS 
BEGIN
	BEGIN TRAN
	BEGIN TRY
		WAITFOR DELAY '00:00:05'
		UPDATE Corporations SET CorporationCountry='Romania' WHERE CorpoName='SinoTrans'
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('UPDATE', 'Corporations', CURRENT_TIMESTAMP)
		COMMIT TRAN
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('COMMIT - GOOD', 'Corporations', CURRENT_TIMESTAMP)
		SELECT 'Update Corporations Transaction GOOD commit'
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN
		SELECT 'Update Corporations Transaction BAD rollback'
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('ROLLBACK - BAD', 'Corporations', CURRENT_TIMESTAMP)
	END CATCH
END
GO

--- T2: select + delay + select
CREATE OR ALTER PROCEDURE NonRepeatableReads_T2 AS
BEGIN
SET TRANSACTION ISOLATION LEVEL READ COMMITTED -- issue!
	BEGIN TRAN
	BEGIN TRY
		SELECT * FROM Corporations;
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('SELECT', 'Corporations', CURRENT_TIMESTAMP)
		WAITFOR DELAY '00:00:10'
		SELECT * FROM Corporations;
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('SELECT', 'Corporations', CURRENT_TIMESTAMP)
		COMMIT TRAN
		SELECT 'Selected all from Corporations transaction committed' 
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN
		SELECT 'Rolled back the select all from Corporations transaction' 
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE NonRepeatableReads_T2_Solution AS
BEGIN
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ -- solution!
	BEGIN TRAN
	BEGIN TRY
		SELECT * FROM Corporations;
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('SELECT', 'Corporations', CURRENT_TIMESTAMP)
		WAITFOR DELAY '00:00:10'
		SELECT * FROM Corporations;
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('SELECT', 'Corporations', CURRENT_TIMESTAMP)
		COMMIT TRAN
		SELECT 'Selected all from Corporations transaction committed' 
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN
		SELECT 'Rolled back the select all from Corporations transaction' 
	END CATCH
END
GO

---------------------------------------------------------- Phantom Reads ----------------------------------------------------------
--- T1: delay + insert + commit
CREATE OR ALTER PROCEDURE PhantomReads_T1 AS
BEGIN
	BEGIN TRAN 
	BEGIN TRY
		WAITFOR DELAY '00:00:05'
		INSERT INTO Corporations(CorporationCountry, CorporationGoods, CorpoName) VALUES ('Ukraine', 'Steel', 'Azovstal')
		COMMIT TRAN
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('INSERT', 'Corporations', CURRENT_TIMESTAMP)
		SELECT 'Insert into Corporations committed'
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN
		SELECT 'Rolled back the insert into Corporations transaction' 
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('ROLLBACK - BAD', 'Corporations', CURRENT_TIMESTAMP)
	END CATCH
END
GO

--- T2: select + delay + select
CREATE OR ALTER PROCEDURE PhantomReads_T2 AS
BEGIN
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ -- issue!
	BEGIN TRAN
	BEGIN TRY
		SELECT * FROM Corporations;
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('SELECT', 'Corporations', CURRENT_TIMESTAMP)
		WAITFOR DELAY '00:00:10'
		SELECT * FROM Corporations;
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('SELECT', 'Corporations', CURRENT_TIMESTAMP)
		COMMIT TRAN
		SELECT 'Selected all from Corporations transaction committed' 
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN
		SELECT 'Rolled back the select all from Corporations transaction' 
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE PhantomReads_T2_Solution AS
BEGIN
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE -- solution!
	BEGIN TRAN
	BEGIN TRY
		SELECT * FROM Corporations;
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('SELECT', 'Corporations', CURRENT_TIMESTAMP)
		WAITFOR DELAY '00:00:10'
		SELECT * FROM Corporations;
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('SELECT', 'Corporations', CURRENT_TIMESTAMP)
		COMMIT TRAN
		SELECT 'Selected all from Corporations transaction committed' 
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN
		SELECT 'Rolled back the select all from Corporations transaction' 
	END CATCH
END
GO

---------------------------------------------------------- Deadlocks ----------------------------------------------------------
--- T1: update on table A + delay + update on table B
CREATE OR ALTER PROCEDURE Deadlock_T1 AS
BEGIN
	BEGIN TRAN
	BEGIN TRY
		UPDATE Corporations SET CorpoName='Azovstal Bandera' WHERE CorporationGoods='Steel'
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('UPDATE', 'Corporations', CURRENT_TIMESTAMP)
		WAITFOR DELAY '00:00:05'
		UPDATE Resources SET ResourcePrice=9995.99 WHERE ResourceName='Gravel'
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('UPDATE', 'Resources', CURRENT_TIMESTAMP)
		COMMIT TRAN
		SELECT 'Both updates committed'
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN
		SELECT 'Deadlock transaction rolled back'
	END CATCH
END
GO

--- T2: update on table B + delay + update on table A
CREATE OR ALTER PROCEDURE Deadlock_T2 AS
BEGIN
	SET DEADLOCK_PRIORITY HIGH
	--- SET DEADLOCK_PRIORITY LOW
	BEGIN TRAN
	BEGIN TRY
		UPDATE Resources SET ResourcePrice=9995.99 WHERE ResourceName='Gravel'
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('UPDATE', 'Resources', CURRENT_TIMESTAMP)
		WAITFOR DELAY '00:00:05'
		UPDATE Corporations SET CorpoName='Azovstal Bandera' WHERE CorporationGoods='Steel'
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('UPDATE', 'Corporations', CURRENT_TIMESTAMP)
		COMMIT TRAN
		SELECT 'Both updates committed'
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN
		SELECT 'Deadlock transaction rolled back'
	END CATCH
END

EXEC Deadlock_T1;
EXEC Deadlock_T2;
GO

---------------------------------------------------------- Deadlocks C# ----------------------------------------------------------
CREATE OR ALTER PROCEDURE Deadlock_T1_C# AS
BEGIN
	BEGIN TRAN 
	UPDATE Corporations SET CorpoName='TransBandera' WHERE CorporationGoods='Shells'
	INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('UPDATE', 'Corporations', CURRENT_TIMESTAMP)
	WAITFOR DELAY '00:00:05'
	UPDATE Resources SET ResourcePrice=4299.99 WHERE ResourceName='Tungsten'
	INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('UPDATE', 'Resources', CURRENT_TIMESTAMP)
	COMMIT TRAN
END
GO

CREATE OR ALTER PROCEDURE Deadlock_T2_C# AS
BEGIN
	SET DEADLOCK_PRIORITY HIGH
	--- SET DEADLOCK_PRIORITY LOW
	BEGIN TRAN
	UPDATE Resources SET ResourcePrice=4299.99 WHERE ResourceName='Tungsten'
	INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('UPDATE', 'Resources', CURRENT_TIMESTAMP)
	WAITFOR DELAY '00:00:05'
	UPDATE Corporations SET CorpoName='TransBandera' WHERE CorporationGoods='Shells'
	INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('UPDATE', 'Corporations', CURRENT_TIMESTAMP)
	COMMIT TRAN
END
