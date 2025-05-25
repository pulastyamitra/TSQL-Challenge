WITH StringsComa(Challenge,WinnerRank,Winners, R)
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
	SUBSTRING(R,1, CHARINDEX(',', R)-1) Winners,
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
	SUBSTRING(A.Winners+'/',1, CHARINDEX('/', A.Winners+'/')-1) Winners,
	SUBSTRING(A.Winners+'/',CHARINDEX('/', A.Winners+'/')+1, len(A.Winners+'/'))  R
FROM StringsComa A
WHERE A.WinnerRank >= 1
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
WHERE 
	ISNULL(Z.Winners,'')<>''
GROUP BY 
	Z.Winners
ORDER BY 
	SUM(Z.WinnerRank) DESC,
	Z.Winners;
