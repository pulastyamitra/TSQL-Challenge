DECLARE @T TABLE(Data VARCHAR(MAX))
INSERT INTO @T
SELECT '12' UNION ALL
SELECT 'xx' 


;WITH CTE AS 
(
	SELECT 
		T.[Data],
		CAST(1 AS BIGINT) i,
		SUBSTRING(T.[Data],1,1) C,
		SUBSTRING(T.[Data],2,LEN(T.[Data])) R
	FROM @T T
	UNION ALL
	SELECT
		U.Data,
		i+1,
		SUBSTRING(U.Data,i+1,1) C,
		SUBSTRING(U.Data,i+2,LEN(U.Data)) R
	FROM CTE U
	WHERE LEN(LTRIM(RTRIM(U.R)))>0
)
SELECT
	 X.Data,
	 X.C	AS Chars,
	 X.C+' appears ('  + CAST(COUNT(X.C) AS VARCHAR) +') times' NumberOfOccurance
FROM CTE X
GROUP BY X.Data,X.C
ORDER BY X.Data,X.C


