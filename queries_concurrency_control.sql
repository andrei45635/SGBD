USE [Port]
GO

SELECT * FROM LogTable;
SELECT * FROM Corporations;
SELECT * FROM Resources;
SELECT * FROM CorporationResources;

-- Dirty Reads
UPDATE Corporations SET CorporationCountry='China' WHERE CorpoName='SinoTrans';
EXEC DirtyReads_T1;
EXEC DirtyReads_T2;
EXEC DirtyReads_T2_Solution;

-- Non-repeatable Reads
UPDATE Corporations SET CorporationCountry='Romania' WHERE CorpoName='SinoTrans';
EXEC NonRepeatableReads_T1;
EXEC NonRepeatableReads_T2;
EXEC NonRepeatableReads_T2_Solution;


-- Phantom Reads
INSERT INTO Corporations(CorporationCountry, CorporationGoods, CorpoName) VALUES ('Ukraine', 'Steel', 'Azovstal');
EXEC PhantomReads_T1;
EXEC PhantomReads_T2;
EXEC PhantomReads_T2_Solution;

-- Deadlocks
UPDATE Corporations SET CorpoName='Azovstal Bandera' WHERE CorporationGoods='Steel';
UPDATE Resources SET ResourcePrice=9995.99 WHERE ResourceName='Gravel';
EXEC Deadlock_T1;
EXEC Deadlock_T2;
