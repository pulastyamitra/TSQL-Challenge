--IF OBJECT_ID('TC41','U') IS NOT NULL BEGIN
--	DROP TABLE TC41
--END
--GO

--CREATE TABLE TC41 (
--	ContentID INT IDENTITY PRIMARY KEY,
--	Content VARCHAR(MAX)
--)
--GO

--INSERT INTO TC41 (Content)
--SELECT '..for more information, write to tc@beyondrelational.com or ..'
--UNION ALL
--SELECT '.. and jacob-sebastian@beyondrelational.com and tc@beyondrelational.com ...'
--UNION ALL
--SELECT '.. michael.dishdy@dishdy.co.uk and dave-ballantyne@dave are very active..'
--UNION ALL
--SELECT 'Is jacob-sebastian@beyondrelational.com a valid email address?'
--UNION ALL
--SELECT 'Is jacob-sebastian@beyondrelational.1com a valid email address?'
--UNION ALL
--SELECT 'Is jacob-sebastian@beyondrelational.co.in.au a valid email address?'
--UNION ALL
--SELECT 'Is jacob-sebastian@beyondrelational.co.6in a valid email address?'
--UNION ALL
--SELECT 'pulastyamitra@gmail.com'

--SELECT * FROM TC41

SET STATISTICS IO ON
SET STATISTICS TIME ON



;WITH BaseData AS
(
	SELECT
		A.ContentID, 
		' '+LTRIM(RTRIM(A.[Content]))+' ' AS Content
	FROM TC41 A
),
SplitIntoWords as (
	SELECT ContentID,
	       n,
	       word,
        (CASE WHEN  
				PATINDEX('%[~,`,!,#,$,%,^,&,*,(,),=,+,\,/,?,<,>,:,|,{,},'']%',Word) = 0    
				AND  (LEN(SUBSTRING(Word,1,LEN(LEFT(Word, CHARINDEX('@', Word) -1)))) - LEN(REPLACE(SUBSTRING(Word,1,LEN(LEFT(Word, CHARINDEX('@', Word) -1))),'-',''))) < = 1
				AND  (LEN(SUBSTRING(Word,1,LEN(LEFT(Word, CHARINDEX('@', Word) -1)))) - LEN(REPLACE(SUBSTRING(Word,1,LEN(LEFT(Word, CHARINDEX('@', Word) -1))),'_',''))) < = 1
				AND  (LEN(SUBSTRING(Word,1,LEN(LEFT(Word, CHARINDEX('@', Word) -1)))) - LEN(REPLACE(SUBSTRING(Word,1,LEN(LEFT(Word, CHARINDEX('@', Word) -1))),'.',''))) < = 1
				AND  LEFT(LTRIM(Word),1) <> '@' 
				AND  RIGHT(RTRIM(Word),1) <> '.' 
				AND  CHARINDEX('.',Word ,CHARINDEX('@',Word)) - CHARINDEX('@',Word ) > 1 
				AND  LEN(LTRIM(RTRIM(Word ))) - LEN(REPLACE(LTRIM(RTRIM(Word)),'@','')) = 1 
				AND  CHARINDEX('.',REVERSE(LTRIM(RTRIM(Word)))) >= 3 
				AND  (
						CHARINDEX('.@',Word ) = 0 
					AND	CHARINDEX('-@',Word ) = 0 
					AND	CHARINDEX('_@',Word ) = 0 
					AND CHARINDEX('..',Word ) = 0
					 )
				AND  PATINDEX('%[0-9]%',SUBSTRING(Word, CHARINDEX('.',Word ,CHARINDEX('@',Word)) - CHARINDEX('@',Word ) + LEN(LEFT(Word, CHARINDEX('@', Word)+1)),LEN(Word)))= 0    
				AND  (	LEN(SUBSTRING(Word, CHARINDEX('.',Word ,CHARINDEX('@',Word)) - CHARINDEX('@',Word ) + LEN(LEFT(Word, CHARINDEX('@', Word)+1)),LEN(Word)))
						-LEN(REPLACE(SUBSTRING(Word, CHARINDEX('.',Word ,CHARINDEX('@',Word)) - CHARINDEX('@',Word ) + LEN(LEFT(Word, CHARINDEX('@', Word)+1)),LEN(Word)),'.',''))
					 )< = 1 
			THEN 1
			ELSE 0
       END) AS Occurrences
	FROM   BaseData
	       CROSS APPLY(
	    SELECT n,
	           SUBSTRING(CONTENT, n + 1, CHARINDEX(' ', CONTENT, n + 1) -n -1) AS word
	    FROM   tsqlc_tally
	    WHERE  SUBSTRING(CONTENT, n, 1) = ' '
	           AND (n >= 1 AND n < LEN(CONTENT))
	           AND CHARINDEX('@',SUBSTRING(CONTENT, n + 1, CHARINDEX(' ', CONTENT, n + 1) -n -1))>0
	) X
), 
CountOccurrences AS (
	SELECT 
		S.word		AS Email,
		SUM(S.Occurrences) Occurrences
	FROM   SplitIntoWords S
	GROUP BY S.word
)
SELECT 
	Email,
	Occurrences
FROM   CountOccurrences
WHERE  Occurrences > 0
ORDER BY 
	Occurrences DESC,
	Email
OPTION(MAXRECURSION 0);