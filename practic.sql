create database S9
go
use S9
go

create table TipuriInghetate(
Tid int primary key identity,
Tip varchar(50),
Descriere varchar(50),
NrSortimente int)

create table Inghetate(
Iid int primary key identity,
Denumire varchar(50),
Pret int,
Gramaj int,
Tid int foreign key references TipuriInghetate(Tid))

create table InghetatePreferate(
IPid int primary key identity,
Denumire varchar(50),
Categorie varchar(50),
NrStele int)

create table Copii(
Cid int primary key identity,
Nume varchar(50),
Prenume varchar(50),
Gen varchar(20),
Varsta int,
IPid int foreign key references InghetatePreferate(IPid))

insert into Copii values('Lupea', 'Maria', 'F', 6, 1), 
('Cristea', 'Dan', 'M', 8, 2)

create table Serviri(
Iid int foreign key references Inghetate(Iid),
Cid int foreign key references Copii(Cid),
DataServire date,
Cantitate int,
constraint pk_Serviri primary key(Iid, Cid))

-- 1-n: InghetatePreferate-Copii

select * from TipuriInghetate
select * from Inghetate
select * from InghetatePreferate
select * from Copii
select * from Serviri

insert into TipuriInghetate values('La cutie', 'in cutie de plastic la diverse gramaje', 20),
('La cornet', 'glazurate si neglazurate', 30)

insert into Inghetate values('Panda', 4, 150, 2),('Scufita Rosie', 6, 100, 2)

insert into InghetatePreferate values('Alpin', 'vafa napolitana', 10), 
('Tort de ciocolata', 'ciocolate asortate cu vanilie', 6 )

insert into Copii values('Lupea', 'Maria', 'F', 6, 1), 
('Cristea', 'Dan', 'M', 8, 2)

insert into Serviri values(1, 1, '07/05/2022', 1),
(1, 2, '11/05/2023', 2)
GO

---------------------------------------------------------- Dirty Reads ----------------------------------------------------------
--- T1: update + delay + rollback 
CREATE OR ALTER PROCEDURE DirtyReads_T1_Practic AS
BEGIN
	BEGIN TRAN
	BEGIN TRY
		UPDATE Copii SET Nume='Festar' WHERE Prenume='Robert'
		WAITFOR DELAY '00:00:10'
		ROLLBACK TRAN
		SELECT 'Update Copii Transaction GOOD rollback'
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN
		SELECT 'Update Copii Transaction BAD rollback'
	END CATCH
END
GO

--- T2: select + delay + select
CREATE OR ALTER PROCEDURE DirtyReads_T2_Practic AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED -- issue!
	BEGIN TRAN
	BEGIN TRY
		SELECT * FROM Copii;
		WAITFOR DELAY '00:00:15'
		SELECT * FROM Copii;
		COMMIT TRAN
		SELECT 'Selected all from Copii transaction committed' 
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN
		SELECT 'Rolled back the select all from Copii transaction' 
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE DirtyReads_T2_Solution_Practic AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED -- solution!
	BEGIN TRAN
	BEGIN TRY
		SELECT * FROM Copii;
		WAITFOR DELAY '00:00:15'
		SELECT * FROM Copii;
		COMMIT TRAN
		SELECT 'Selected all from Copii transaction committed' 
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN
		SELECT 'Rolled back the select all from Copii transaction' 
	END CATCH
END
GO

EXEC DirtyReads_T1_Practic;
GO

SELECT Nume, Prenume, Gen FROM Copii WHERE IPid = 2;

CREATE INDEX IX_Copii_asc_Inghetate_Preferate_asc ON Copii(Nume ASC, Prenume ASC, Gen ASC) INCLUDE (IPid);
GO