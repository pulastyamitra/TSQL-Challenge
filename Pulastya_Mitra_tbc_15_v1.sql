DECLARE @t TABLE(ID INT IDENTITY, Sentence VARCHAR(1000))
INSERT INTO @t(Sentence)
SELECT 'This is T-SQL Beginners Challenge #15' UNION ALL
SELECT 'I am a challenge competitor'




;WITH Base AS
(
    SELECT T.ID,
           T.Sentence OriginalSentence,
           REPLACE(LTRIM(RTRIM(T.Sentence)), ' ', '|') + '|' Sentence
    FROM   @t T
),SplitSentence(ID, RowID, Word, R) AS
(
    SELECT B.ID,
           CAST(1 AS BIGINT) RowID,
           SUBSTRING(B.Sentence, 1, CHARINDEX('|', B.Sentence) -1) Word,
           SUBSTRING(B.Sentence,CHARINDEX('|', B.Sentence) + 1,LEN(B.Sentence)) R
    FROM   Base B
    UNION ALL
    SELECT C.ID,
           C.RowID + 1 AS RowID,
           SUBSTRING(C.R, 1, CHARINDEX('|', C.R) -1) Word,
           SUBSTRING(C.R, CHARINDEX('|', C.R) + 1, LEN(C.R)) R
    FROM   SplitSentence C
    WHERE  CHARINDEX('|', C.R) > 0
)
SELECT X.ID,
       X.OriginalSentence AS [Original Sentence],
       REPLACE(
           STUFF(
               (
                   SELECT '|' + Y.Word
                   FROM   SplitSentence Y
                   WHERE  Y.ID = X.ID
                   ORDER BY
                          Y.RowID DESC FOR XML PATH('')
               ),
               1,
               1,
               ''
           ),
           '|',
           ' '
       ) AS [Reversed Sentence]
FROM   Base X


