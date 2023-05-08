USE [Port]
GO

-- Corporations - Resources 

CREATE TABLE LogTable(
Lid INT IDENTITY PRIMARY KEY,
TypeOperation VARCHAR(50),
TableOperation VARCHAR(50),
ExecutionDate DATETIME
);
GO

-- Validation function for the Resources table
-- Type, Name both varchar
-- Type can only be Natural, Synthetic, Other
-- Name -> default Unspecified
-- Weight is a float, between 10 and 9999
-- Price is a float that can't be null 

-- valideaza tipul resursei
-- tipul nu poate fi diferit de Natural, Synthetic sau Other
-- tipul trebuie sa fie varchar
CREATE OR ALTER FUNCTION [dbo].validareTipResursa (@tip VARCHAR(50))
RETURNS BIT
AS
BEGIN
	DECLARE @flag BIT
	IF @tip != 'Natural' OR @tip != 'Synthetic' OR @tip != 'Other' OR ISNUMERIC(@tip) = 1
	BEGIN 
		SET @flag = 1
	END
	RETURN @flag;
END
GO

-- valideaza numele resursei
-- numele are deja valoare default dar nu poate fi nula
-- numele trebuie sa fie varchar
CREATE OR ALTER FUNCTION [dbo].validareNumeResursa (@nume VARCHAR(50))
RETURNS BIT
AS
BEGIN
	DECLARE @flag BIT
	IF LEN(@nume) < 0 OR ISNUMERIC(@nume) = 1
	BEGIN
		SET @flag = 1
	END
	RETURN @flag;
END
GO

-- valideaza greutatea resursei
-- greutatea trebuie sa fie intre 10 si 9999
-- greutatea trebuie sa fie float 
-- IF @weight NOT BETWEEN 10 AND 9999 OR ISNUMERIC(@weight) = 0

CREATE OR ALTER FUNCTION [dbo].validareGreutateResursa (@weight FLOAT)
RETURNS BIT
AS
BEGIN
	DECLARE @flag BIT
	IF @weight NOT BETWEEN 10 AND 9999 OR NOT (FLOOR(@weight) <> CEILING(@weight))
	BEGIN
		SET @flag = 1
	END
	RETURN @flag;
END
GO

-- valideaza pretul resursei
-- pretul trebuie sa fie float si not null
-- IF ISNUMERIC(@price) = 0 OR @price < 0
CREATE OR ALTER FUNCTION [dbo].validarePretResursa (@price FLOAT)
RETURNS BIT
AS
BEGIN
	DECLARE @flag BIT
	IF NOT (FLOOR(@price) <> CEILING (@price)) AND @price > 0
	BEGIN
		SET @flag = 1
	END
	RETURN @flag;
END
GO

-- functie de validare pt ResourceID
CREATE OR ALTER FUNCTION [dbo].validareResourceID (@ResoID INT)
RETURNS BIT
AS
BEGIN
	DECLARE @flag INT
	DECLARE @begin INT
	DECLARE @end INT

	SELECT TOP 1 @begin = ResourceID FROM Resources ORDER BY ResourceID ASC
	SELECT TOP 1 @end = ResourceID FROM Resources ORDER BY ResourceID DESC
	
	IF @ResoID NOT BETWEEN @begin AND @end
	BEGIN
		SET @flag = 1
	END

	RETURN @flag;
END
GO

-- Validation function for the Corporations table 
-- Corporation Country, Corporation Goods, Corporation Name
-- All varchar, Country is by default 'Multinational' and Name is by default 'Undisclosed'

-- functie de validare pt campurile Corporations
-- campurile au valori default, insa daca sunt introduse valori null atunci se returneaza eroare
CREATE OR ALTER FUNCTION [dbo].validareCampuriCorporatie (@camp VARCHAR(50))
RETURNS BIT
AS
BEGIN
	DECLARE @flag BIT
	IF LEN(@camp) < 0 OR ISNUMERIC(@camp) = 1
	BEGIN
		SET @flag = 1
	END

	RETURN @flag;
END
GO

-- functie de validare pt CorporationID
CREATE OR ALTER FUNCTION [dbo].validareCorpoID (@CorpoID INT)
RETURNS BIT
AS
BEGIN
	DECLARE @flag INT
	DECLARE @begin INT
	DECLARE @end INT
	
	SELECT TOP 1 @begin = CorporationID FROM Corporations ORDER BY CorporationID ASC
	SELECT TOP 1 @end = CorporationID FROM Corporations ORDER BY CorporationID DESC
	
	IF @CorpoID BETWEEN @begin AND @end
	BEGIN
		SET @flag = 1
	END

	RETURN @flag;
END
GO

CREATE OR ALTER PROCEDURE [dbo].verificareCorporations 
	@flag BIT OUTPUT,
	@msg VARCHAR(250) OUTPUT,
	@country VARCHAR(50),
	@goods VARCHAR(50), 
	@nume VARCHAR(50)
AS
BEGIN
	DECLARE @sumaErr INT
	SET @flag = 0
	SET @msg = ''
	SET @sumaErr = 0
	
	IF dbo.validareCampuriCorporatie(@country) = 1
	BEGIN
		SET @msg = @msg + ' tara invalida! '
	END
	
	IF dbo.validareCampuriCorporatie(@Goods) = 1
	BEGIN
		SET @msg = @msg + ' bunuri invalide! '
	END
	
	IF dbo.validareCampuriCorporatie(@nume) = 1
	BEGIN
		SET @msg = @msg + ' nume corporatie invalid! '
	END
	
	SET @sumaErr = @sumaErr + dbo.validareCampuriCorporatie(@country) + dbo.validareCampuriCorporatie(@Goods) + dbo.validareCampuriCorporatie(@nume)	
	IF @sumaErr > 0
	BEGIN
		SET @flag = 1
	END
END
GO

CREATE OR ALTER PROCEDURE [dbo].verificareResurse
	@flag BIT OUTPUT,
	@msg VARCHAR(250) OUTPUT,
	@type VARCHAR(50),
	@name VARCHAR(50),
	@weight FLOAT,
	@price FLOAT
AS
BEGIN
	DECLARE @sumaErr INT
	SET @flag = 0
	SET @msg = ''
	SET @sumaErr = 0
	
	IF dbo.validareTipResursa(@type) = 1
	BEGIN
		SET @msg = @msg + ' tip resursa invalid!'
	END
	
	IF dbo.validareNumeResursa(@name) = 1
	BEGIN
		SET @msg = @msg + ' nume resursa invalid! '
	END

	IF dbo.validareGreutateResursa(@weight) = 1
	BEGIN
		SET @msg = @msg + ' greutate resursa invalida! '
	END

	IF dbo.validarePretResursa(@price) = 1
	BEGIN 
		SET @msg = @msg + ' pret resursa invalid! '
	END

	SET @sumaErr += @sumaErr + dbo.validareTipResursa(@type) + dbo.validareNumeResursa(@name) + dbo.validareGreutateResursa(@weight) + dbo.validarePretResursa(@price)
	IF @sumaErr > 0
	BEGIN
		SET @flag = 1
	END
END
GO

CREATE OR ALTER PROCEDURE [dbo].verificareCorporationResources
	@flag BIT OUTPUT,
	@msg VARCHAR(250) OUTPUT,
	@ResourceID INT,
	@CorpoID INT
AS
BEGIN
	DECLARE @sumaErr INT
	SET @flag = 0
	SET @msg = ''
	SET @sumaErr = 0

	IF dbo.validareCorpoID(@CorpoID) = 1
	BEGIN
		SET @msg = @msg + ' resource id invalid! '
	END

	IF dbo.validareResourceID(@ResourceID) = 1
	BEGIN
		SET @msg = @msg + ' corpo id invalid! '
	END

	SET @sumaErr = @sumaErr + dbo.validareCorpoID(@CorpoID) + dbo.validareResourceID(@ResourceID)
	IF @sumaErr > 0
	BEGIN
		SET @flag = 1
	END
END
GO

CREATE PROCEDURE insertIntoCorpoResourcesV1
@cCountry VARCHAR(50), 
	@cGoods VARCHAR(50), 
	@cName VARCHAR(50), 
	@rType VARCHAR(50), 
	@rName VARCHAR(50), 
	@rWeight FLOAT, 
	@rPrice FLOAT 
AS

BEGIN
	DECLARE @msg VARCHAR(250)
	DECLARE @flag BIT

	BEGIN TRAN
	BEGIN TRY 

		EXEC dbo.verificareCorporations @flag OUTPUT, @msg OUTPUT, @cCountry, @cGoods, @cName 
		IF @flag=1
			BEGIN 
				RAISERROR (@msg, 14, 1)
			END

		INSERT INTO Corporations(CorporationCountry, CorporationGoods, CorpoName) VALUES (@cCountry, @cGoods, @cName)
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('INSERT', 'Corporations', CURRENT_TIMESTAMP)
		
		EXEC dbo.verificareResurse @flag OUTPUT, @msg OUTPUT, @rType, @rName, @rWeight, @rPrice
		IF @flag=1
			BEGIN 
				RAISERROR (@msg, 14, 1)
			END

		INSERT INTO Resources(ResourceType, ResourceName, ResourceWeight, ResourcePrice) VALUES (@rType, @rName, @rWeight, @rPrice)
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('INSERT', 'Resources', CURRENT_TIMESTAMP)

		DECLARE @ResourceID INT, @CorpoID INT
		SET @ResourceID=(SELECT MAX(ResourceID) FROM Resources)
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('SELECT', 'Resources', CURRENT_TIMESTAMP)
		SET @CorpoID=(SELECT MAX(CorporationID) FROM Corporations)
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('SELECT', 'Corporations', CURRENT_TIMESTAMP)

		EXEC dbo.verificareCorporationResources @flag OUTPUT, @msg OUTPUT, @ResourceID, @CorpoID 
		IF @flag=1
			BEGIN 
				RAISERROR (@msg, 14, 1)
			END

		INSERT INTO CorporationResources(CorporationID, ResourceID) VALUES (@CorpoID, @ResourceID)
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('INSERT', 'CorporationResources', CURRENT_TIMESTAMP)

		COMMIT TRAN
		SELECT 'Insert V1 Transaction Committed'

	END TRY

	BEGIN CATCH
		ROLLBACK TRAN
		SELECT 'Insert V1 Transaction rollback'
	END CATCH
END
GO

--successful
EXEC insertIntoCorpoResourcesV1 'Romania','TV', 'SinoTrans', 'Other', 'Copper', 5822, 199999
SELECT * FROM Corporations 
SELECT * FROM Resources
SELECT * FROM CorporationResources
SELECT * FROM LogTable
--unsuccessful
EXEC insertIntoCorpoResourcesV1 'Romania', 'TV', 'FakeName', 'Nush', 'Copper', 5, 199999
SELECT * FROM Corporations 
SELECT * FROM Resources
SELECT * FROM CorporationResources
SELECT * FROM LogTable
GO

CREATE OR ALTER PROCEDURE insertIntoCorpoResourcesV2 
	@cCountry VARCHAR(50), 
	@cGoods VARCHAR(50), 
	@cName VARCHAR(50), 
	@rType VARCHAR(50), 
	@rName VARCHAR(50), 
	@rWeight FLOAT, 
	@rPrice FLOAT 
AS
BEGIN
	DECLARE @msg VARCHAR(250)
	DECLARE @flag BIT

	BEGIN TRAN
	BEGIN TRY
		EXEC dbo.verificareCorporations @flag OUTPUT, @msg OUTPUT, @cCountry, @cGoods, @cName 
		IF @flag=1
			BEGIN 
				RAISERROR (@msg, 14, 1)
			END

		INSERT INTO Corporations(CorporationCountry, CorporationGoods, CorpoName) VALUES (@cCountry, @cGoods, @cName)
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('INSERT', 'Corporations', CURRENT_TIMESTAMP)

	COMMIT TRAN 
	SELECT 'Insert into Corporations Transaction committed'
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN
		SELECT 'Insert into Corporations Transaction rolled back'
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('ROLLBACK', 'Corporations', CURRENT_TIMESTAMP)
	END CATCH

	BEGIN TRAN
	BEGIN TRY
		EXEC dbo.verificareResurse @flag OUTPUT, @msg OUTPUT, @rType, @rName, @rWeight, @rPrice
		IF @flag=1
			BEGIN 
				RAISERROR (@msg, 14, 1)
			END

		INSERT INTO Resources(ResourceType, ResourceName, ResourceWeight, ResourcePrice) VALUES (@rType, @rName, @rWeight, @rPrice)
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('INSERT', 'Resources', CURRENT_TIMESTAMP)

	COMMIT TRAN 
	SELECT 'Insert into Resources Transaction committed'
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN
		SELECT 'Insert into Resources Transaction rolled back'
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('ROLLBACK', 'Resources', CURRENT_TIMESTAMP)
	END CATCH

	BEGIN TRAN
	BEGIN TRY
		DECLARE @ResourceID INT, @CorpoID INT
		SET @ResourceID=(SELECT MAX(ResourceID) FROM Resources)
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('SELECT', 'Resources', CURRENT_TIMESTAMP)
		SET @CorpoID=(SELECT MAX(CorporationID) FROM Corporations)
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('SELECT', 'Corporations', CURRENT_TIMESTAMP)
		EXEC dbo.verificareCorporationResources @flag OUTPUT, @msg OUTPUT, @ResourceID, @CorpoID 
		IF @flag=1
			BEGIN 
				RAISERROR (@msg, 14, 1)
			END

		INSERT INTO Resources(ResourceType, ResourceName, ResourceWeight, ResourcePrice) VALUES (@rType, @rName, @rWeight, @rPrice)
		INSERT INTO LogTable(TypeOperation, TableOperation, ExecutionDate) VALUES ('INSERT', 'CorporationResources', CURRENT_TIMESTAMP)

	COMMIT TRAN 
	SELECT 'Insert into CorporationResources Transaction committed'
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN
		SELECT 'Insert into CorporationResources Transaction rolled back'
	END CATCH
END

--successful
EXEC insertIntoCorpoResourcesV2 'Ukraine', 'Shells', 'Bandera', 'Other', 'Copper', 5999, 399999
SELECT * FROM Corporations 
SELECT * FROM Resources
SELECT * FROM CorporationResources
SELECT * FROM LogTable
--unsuccessful
EXEC insertIntoCorpoResourcesV2 'Ukraine', 'TV', 'FakeName', 'Nush', 'Copper', 5, 199999
SELECT * FROM Corporations 
SELECT * FROM Resources
SELECT * FROM CorporationResources
SELECT * FROM LogTable
GO