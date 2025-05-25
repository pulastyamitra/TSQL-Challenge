--IF OBJECT_ID('TC40','U') IS NOT NULL BEGIN
--	DROP TABLE TC40
--END
--GO

--CREATE TABLE TC40 (
--	BinaryString VARCHAR(2048)
--)
--GO

--INSERT INTO TC40(BinaryString)
--SELECT '11110110111' UNION ALL
--SELECT '101011100101100' UNION ALL
--SELECT '1100110110000010' UNION ALL
--SELECT '1001110001000' UNION ALL
--SELECT '1010100001010001110110011' 
--UNION ALL SELECT '000010111' 
--insert into TC40 values('1'+REPLICATE('0',2047))

--insert into TC40 values(REPLICATE('0',2047)+'1')
--SET STATISTICS IO ON;
--SET STATISTICS TIME ON;
--SET SHOWPLAN_ALL OFF;



;WITH 
cteBase
	AS (
	       SELECT 
	              T.BinaryString,
	              LEN(T.BinaryString) StringLen,
	              CASE 
	                   WHEN PATINDEX('%[1]%', T.BinaryString) = 0 THEN '0000'
	                   ELSE REPLICATE(
	                            '0',
	                            CASE 
	                                 WHEN LEN(
	                                          SUBSTRING(
	                                              T.BinaryString,
	                                              LEN(LEFT(T.BinaryString, PATINDEX('%[1]%', T.BinaryString) -1))
	                                              + 1,
	                                              2048
	                                          )
	                                      )%4 > 0 THEN 4 -(
	                                          LEN(
	                                              SUBSTRING(
	                                                  T.BinaryString,
	                                                  LEN(LEFT(T.BinaryString, PATINDEX('%[1]%', T.BinaryString) -1))
	                                                  + 1,
	                                                  2048
	                                              )
	                                          )%4
	                                      )
	                                 ELSE 0
	                            END
	                        ) + SUBSTRING(
	                            T.BinaryString,
	                            LEN(LEFT(T.BinaryString, PATINDEX('%[1]%', T.BinaryString) -1))
	                            + 1,
	                            2048
	                        )
	              END AS FormatString
	       FROM   TC40 T
	   ),cteBinToHex
	AS (
	       SELECT T.BinaryString,
	              T.FormatString,
	              CAST(
	                  CASE RIGHT(T.FormatString, 4)
	                       WHEN '1111' THEN 'F'
	                       WHEN '1110' THEN 'E'
	                       WHEN '1101' THEN 'D'
	                       WHEN '1100' THEN 'C'
	                       WHEN '1011' THEN 'B'
	                       WHEN '1010' THEN 'A'
	                       WHEN '1001' THEN '9'
	                       WHEN '1000' THEN '8'
	                       WHEN '0111' THEN '7'
	                       WHEN '0110' THEN '6'
	                       WHEN '0101' THEN '5'
	                       WHEN '0100' THEN '4'
	                       WHEN '0011' THEN '3'
	                       WHEN '0010' THEN '2'
	                       WHEN '0001' THEN '1'
	                       WHEN '0000' THEN '0'
	                  END AS VARCHAR(512)
	              ) AS HexaDecimalString,
	              SUBSTRING(T.FormatString, 1, LEN(T.FormatString) -4) Remaining
	       FROM   cteBase T
	       UNION ALL
	       SELECT X.BinaryString,
	              X.FormatString,
	              CAST(
	                  (
	                      CASE RIGHT(X.Remaining, 4)
	                           WHEN '1111' THEN 'F'
	                           WHEN '1110' THEN 'E'
	                           WHEN '1101' THEN 'D'
	                           WHEN '1100' THEN 'C'
	                           WHEN '1011' THEN 'B'
	                           WHEN '1010' THEN 'A'
	                           WHEN '1001' THEN '9'
	                           WHEN '1000' THEN '8'
	                           WHEN '0111' THEN '7'
	                           WHEN '0110' THEN '6'
	                           WHEN '0101' THEN '5'
	                           WHEN '0100' THEN '4'
	                           WHEN '0011' THEN '3'
	                           WHEN '0010' THEN '2'
	                           WHEN '0001' THEN '1'
	                           WHEN '0000' THEN '0'
	                      END + X.HexaDecimalString
	                  ) AS VARCHAR(512)
	              ) AS HexaDecimalString,
	              SUBSTRING(X.Remaining, 1, LEN(X.Remaining) -4) Remaining
	       FROM   cteBinToHex X
	       WHERE  LEN(X.Remaining) > 0
	   )
	SELECT F.BinaryString,
		   F.HexaDecimalString
	FROM   cteBinToHex F
	WHERE  F.Remaining = ''
	ORDER BY
	       LEN(BinaryString)
	       OPTION(MAXRECURSION 0);
	       
	       
	       
	       
--


--SELECT PATINDEX('%[1]%', '0000'),
--LEN(LEFT('0000', PATINDEX('%[1]%', '0000'))),
--SUBSTRING(
--           '0000',
--           LEN(LEFT('0000', PATINDEX('%[1]%', '0000')-1))
--           + 1,
--           2048
--       )
--SELECT 0-1