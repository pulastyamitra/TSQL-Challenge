--Pulastya Mitra

DECLARE @Sentence TABLE(ID INT IDENTITY, Sentence VARCHAR(1000))
INSERT INTO @Sentence(Sentence)
SELECT 'Hello Madam! how are you Madam?' UNION ALL 
SELECT 'She peep through the window' UNION ALL 
SELECT 'This is without any Palindrome'


DECLARE @Noise TABLE(ID INT IDENTITY, Noise VARCHAR(10))
INSERT INTO @Noise(Noise)
SELECT '?' UNION ALL 
SELECT '!'



;WITH Base(ID, OriginalSentence, FormatedSentence) AS 
(
    SELECT S.ID,
           S.Sentence,
           LTRIM(RTRIM(REPLACE(S.Sentence, ' ', '|')))
    FROM   @Sentence S
),
StringsComa(ID, WordPosition, Word, R)
AS
(
    SELECT A.ID,
           CAST(1 AS BIGINT) WordPosition,
           SUBSTRING(A.FormatedSentence + '|',1,CHARINDEX('|', A.FormatedSentence + '|') -1) Word,
           SUBSTRING(A.FormatedSentence + '|',CHARINDEX('|', A.FormatedSentence + '|') + 1,LEN(A.FormatedSentence + '|')) R
    FROM   Base A
    UNION ALL
    SELECT B.ID,
           WordPosition + 1,
           SUBSTRING(R,	1,CHARINDEX('|', R) -1) Word,
           SUBSTRING(R,	CHARINDEX('|', R) + 1, LEN(R)) R
    FROM   StringsComa B
    WHERE  CHARINDEX('|', R) > 0
),
RemoveNoiseNchkPalindrome AS
(
    SELECT M.ID,
           ISNULL(REPLACE(M.Word, N.Noise, ''), M.Word) Word,
           M.WordPosition,
           (
			   CASE 
					WHEN UPPER(ISNULL(REPLACE(M.Word, N.Noise, ''), M.Word)) = REVERSE(UPPER(ISNULL(REPLACE(M.Word, N.Noise, ''), M.Word))) THEN 1
					ELSE 0
			   END
           ) PalindromeFound
    FROM   StringsComa M
           LEFT OUTER JOIN @Noise N
                ON  CHARINDEX(N.Noise, M.Word, 0) > 0
)
,FinalSet AS
(
    SELECT G.ID,
           G.Word,
           SUM(G.PalindromeFound) PalindromeFound,
           'Position : ' + STUFF(
               (
                   SELECT ',' + CAST(F.WordPosition AS VARCHAR(10))
                   FROM   RemoveNoiseNchkPalindrome F
                   WHERE  F.ID = G.ID
                          AND F.PalindromeFound > 0 FOR XML PATH('')
               ),
               1,
               1,
               ''
           ) FoundAt
    FROM   RemoveNoiseNchkPalindrome G
    WHERE  PalindromeFound > 0
    GROUP BY
           ID,
           Word
)
SELECT 
	X.ID,
	X.OriginalSentence AS Sentence,
	ISNULL(Y.PalindromeFound,0) AS PalindromeFound,
	Y.Word	AS PalandromicWords,
	Y.FoundAt
FROM   Base X LEFT OUTER JOIN FinalSet Y
			ON X.ID=Y.ID;

