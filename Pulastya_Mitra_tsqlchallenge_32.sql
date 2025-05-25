--IF OBJECT_ID('TC32_Data','U') IS NOT NULL BEGIN
--	DROP TABLE TC32_Data
--END;

--CREATE TABLE TC32_Data(
--	ID INT IDENTITY PRIMARY KEY,
--	Phrase VARCHAR(1000)
--);

--IF OBJECT_ID('TC32_Noise','U') IS NOT NULL BEGIN
--	DROP TABLE TC32_Noise
--END;
 
--CREATE TABLE TC32_Noise (
--	WordID INT IDENTITY PRIMARY KEY,
--	Word VARCHAR(30)
--);

--INSERT INTO TC32_Data (Phrase)
--SELECT 'All people are born equal'
--UNION ALL
--SELECT 'And the longest day was today'
--UNION ALL
--SELECT 'From mother accept this precious gift'
--UNION ALL
--SELECT 'Going forward to'
--UNION ALL
--SELECT 'Go back home';

--INSERT INTO TC32_Noise(Word)
--SELECT 'and'
--UNION ALL
--SELECT 'from'
--UNION ALL
--SELECT 'to'
--UNION ALL
--SELECT 'the'
--UNION ALL 
--SELECT 'back'
--UNION ALL
--SELECT 'go';


;WITH BaseData(ID, OriginalSentence, FormatedSentence) AS 
(
    SELECT D.ID,
           D.Phrase,
           REPLACE(LTRIM(RTRIM(D.Phrase)), ' ', '|') FormatedSentence
    FROM   TC32_Data D
),
SplitSentenct(ID, WordPosition, Word, R)
AS
(
    SELECT A.ID,
           CAST(1 AS BIGINT) WordPosition,
           SUBSTRING(A.FormatedSentence + '|',1,CHARINDEX('|', A.FormatedSentence + '|') -1) Word,
           SUBSTRING(A.FormatedSentence + '|',CHARINDEX('|', A.FormatedSentence + '|') + 1,LEN(A.FormatedSentence + '|')) R
    FROM   BaseData A
    UNION ALL
    SELECT B.ID,
           WordPosition + 1,
           SUBSTRING(R,	1,CHARINDEX('|', R) -1) Word,
           SUBSTRING(R,	CHARINDEX('|', R) + 1, LEN(R)) R
    FROM   SplitSentenct B
    WHERE  CHARINDEX('|', R) > 0
),
RemoveNoise AS
(
    SELECT
		M.ID,
		M.WordPosition,
       (CASE WHEN UPPER(LTRIM(RTRIM(M.Word))) = UPPER(LTRIM(RTRIM(N.Word)))THEN '' ELSE M.Word END) Word
    FROM   SplitSentenct M LEFT OUTER JOIN TC32_Noise N
    ON M.Word = N.Word
)
SELECT 
	X.ID,
	X.OriginalSentence	AS Phras,
	LTRIM(RTRIM(CleanPhras)) CleanPhras
FROM BaseData X
CROSS APPLY 
	(SELECT ' '+ Y.Word FROM RemoveNoise Y WHERE X.ID = Y.ID AND Y.Word<>'' ORDER BY Y.WordPosition FOR XML PATH(''))
	D(CleanPhras)
ORDER BY X.ID	
OPTION (MAXRECURSION 0)
