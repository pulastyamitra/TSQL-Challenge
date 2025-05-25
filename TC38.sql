--IF OBJECT_ID('TC38','U') IS NOT NULL 
--	DROP TABLE TC38
--GO

--CREATE TABLE TC38 (
--	Challenge VARCHAR(20),
--	Winners VARCHAR(MAX)
--)
--GO

--INSERT INTO TC38 (Challenge, Winners)
--SELECT 'TSQL Challenge 25', 'leszek,lmu92/xaloc,,karinloos,Erick,,,dishdy,jobacr'
--UNION ALL
--SELECT 'TSQL Challenge 24', ',Dalibor,,lwkwok,,,,lmu92,dishdy'
--UNION ALL
--SELECT 'TSQL Challenge 23', 'Mark,Dalibor,Beakdan,,Parth,Ramireddy,lmu92,Ruby'


--truncate table tc38

--declare @winners varchar(max),@slashes1 varchar(max),@slashes2 varchar(max)
--declare @n INT=0

-- --TEST1: rows with number of names in each row very large (100)
--if 1=1 begin
--  set @n=1
--  set @winners='w1'
--  while @n<100 begin
--    set @n=@n+1
--    set @winners=@winners+',w'+convert(varchar,@n)
--  end
--  set @n=0
--  while @n<1000 begin
--    set @n=@n+1
--    insert into tc38 values('Challenge '+convert(varchar,@n),@winners)
--  end
--end


--DBCC DROPCLEANBUFFERS
--DBCC FREEPROCCACHE

--SET STATISTICS IO ON
--SET STATISTICS TIME ON

--SET STATISTICS PROFILE OFF
--SET STATISTICS TIME ON
--SET STATISTICS IO ON
--SET STATISTICS TIME ON;

;WITH StringsComa(Challenge,WinnerRank,Winners, R)
AS
(
SELECT 
	A.Challenge,
	CAST(10 AS BIGINT) WinnerRank,
	SUBSTRING(A.Winners+',',1, CHARINDEX(',', A.Winners+',')-1) Winners,
	SUBSTRING(A.Winners+',',CHARINDEX(',', A.Winners+',')+1, len(A.Winners+','))  R
FROM TC38 A
UNION ALL
SELECT 
	X.Challenge,
	(WinnerRank-1)	WinnerRank,
	SUBSTRING(R,1,CHARINDEX(',', R)-1) Winners,
	SUBSTRING(R,CHARINDEX(',', R)+1, len(R)) R
FROM StringsComa X
WHERE
	CHARINDEX(',', R) > 0	
), StringsSlash(Challenge,WinnerRank,Winners, R)
AS
(
SELECT 
	A.Challenge,
	A.WinnerRank,
	SUBSTRING(A.Winners + '/',1, CHARINDEX('/', A.Winners+'/')-1) Winners,
	SUBSTRING(A.Winners + '/',CHARINDEX('/', A.Winners+'/')+1, len(A.Winners+'/'))  R
FROM StringsComa A
WHERE A.WinnerRank >= 1
AND	  ISNULL(A.Winners,'')<>'' 
UNION ALL
SELECT 
	X.Challenge,
	X.WinnerRank,
	SUBSTRING(R,1, CHARINDEX('/', R)-1) Winners,
	SUBSTRING(R,CHARINDEX('/', R)+1, len(R)) R
FROM StringsSlash X
WHERE
	CHARINDEX('/', R) > 0
)
SELECT 
	Z.Winners,
	SUM(Z.WinnerRank) AS [SQL Stars] 
FROM StringsSlash Z
GROUP BY 
	Z.Winners
ORDER BY 
	SUM(Z.WinnerRank) DESC,
	Z.Winners
	OPTION (MAXRECURSION 0);
