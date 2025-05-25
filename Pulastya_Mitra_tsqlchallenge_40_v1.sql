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
--UNION ALL SELECT '0001101010000100000111' 


--SELECT * FROM TC40
SET STATISTICS IO ON
SET STATISTICS TIME ON


;WITH Hex(Bin, HexValue) 
	AS (
        SELECT '1111','F' UNION ALL
        SELECT '1110','E' UNION ALL
        SELECT '1101','D' UNION ALL
        SELECT '1100','C' UNION ALL
        SELECT '1011','B' UNION ALL
        SELECT '1010','A' UNION ALL
        SELECT '1001','9' UNION ALL
        SELECT '1000','8' UNION ALL
        SELECT '0111','7' UNION ALL
        SELECT '0110','6' UNION ALL
        SELECT '0101','5' UNION ALL
        SELECT '0100','4' UNION ALL
        SELECT '0011','3' UNION ALL
        SELECT '0010','2' UNION ALL
        SELECT '0001','1' UNION ALL
        SELECT '0000','0'
	),cteBase
	AS (
		SELECT
			T.BinaryString,
			REPLICATE('0',CASE WHEN LEN(T.BinaryString)%4 >0 
							   THEN 4 - (LEN(T.BinaryString)%4) 
							   ELSE 0 END)+	T.BinaryString  AS FormatString
		FROM   TC40 T
	   ),cteSet1
	AS (		
		SELECT 
			T.BinaryString,
			T.FormatString,
			RIGHT(T.FormatString,4) BinValue,
			CAST(H.HexValue AS VARCHAR(512)) AS HexaDecimalString,
			SUBSTRING(T.FormatString,1,LEN(T.FormatString)-4) R
		FROM   cteBase T
		,Hex H
		WHERE RIGHT(T.FormatString,4)= H.Bin
		UNION ALL
		SELECT 
			X.BinaryString,
			X.FormatString,
			RIGHT(X.R,4) BinValue,
			CAST (H.HexValue + X.HexaDecimalString AS VARCHAR(512)) HexaDecimalString,
			SUBSTRING(X.R,1,LEN(X.R)-4) R
		FROM   cteSet1 X,Hex H
		WHERE RIGHT(X.R,4)= H.Bin
		AND LEN(X.R)>0
	)
	SELECT 
		F.BinaryString ,
		CASE WHEN LEFT(F.HexaDecimalString,1) = '0' 
			 THEN SUBSTRING (F.HexaDecimalString,2,510)
			 ELSE F.HexaDecimalString
		END HexaDecimalString
		--F.HexaDecimalString
	FROM   cteSet1 F
	WHERE F.R=''
	ORDER BY
	       LEN(BinaryString)
	       OPTION(MAXRECURSION 0)

