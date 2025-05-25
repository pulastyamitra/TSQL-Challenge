--IF OBJECT_ID('TC42', 'U') IS NOT NULL BEGIN
--	DROP TABLE TC42 
--END
--GO

--CREATE TABLE TC42(
--	EmployeeID VARCHAR(5),
--	PayType CHAR(1),
--	PayHours CHAR(5)
--)
--INSERT INTO TC42 (EmployeeID, PayType, PayHours)
--SELECT '10001', 'R', '01:30' UNION ALL
--SELECT '10001', 'R', '05:15' UNION ALL
--SELECT '10001', 'O', '01:00' UNION ALL
--SELECT '10001', 'H', '01:30' UNION ALL
--SELECT '10002', 'R', '08:00' UNION ALL
--SELECT '10002', 'I', '01:00' UNION ALL
--SELECT '10002', 'I', '01:30' UNION ALL
--SELECT '10003', 'R', '00:30' UNION ALL
--SELECT '10003', 'R', '00:45' UNION ALL
--SELECT '10003', 'O', '01:00' UNION ALL
--SELECT '10003', 'I', '00:30' UNION ALL
--SELECT '10003', 'I', '00:15' UNION ALL
--SELECT '10003', 'H', '01:30' UNION ALL
--SELECT '10003', 'H', '09:30' 
--SELECT * FROM TC42
SET STATISTICS IO ON
SET STATISTICS TIME ON

;WITH TypeWiseWorkHour AS (
	SELECT
	   ROW_NUMBER() OVER(	-- Create row order of paytype weight
							PARTITION BY A.EmployeeID ORDER BY
								CASE 
									 WHEN A.PayType = 'R' THEN 1
									 WHEN A.PayType = 'O' THEN 2
									 WHEN A.PayType = 'I' THEN 3
									 WHEN A.PayType = 'H' THEN 4
								END
	                    ) RowOrder,
	   A.EmployeeID,
       A.PayType,
		   CAST((
   				SUM(CAST(SUBSTRING(A.PayHours,1,2) AS INT)) 
				+ (SUM(CAST(SUBSTRING(A.PayHours,4,2) AS INT))/60
				)) AS VARCHAR(12))+ ':' +
		RIGHT('00'+
			CAST((
		   		(SUM(CAST(SUBSTRING(A.PayHours,4,2) AS INT))%60)
				+ (10 *((SUM(CAST(SUBSTRING(A.PayHours,4,2) AS INT))%60)/15))
					) AS VARCHAR(12)),2) PayHours

	FROM   TC42 A
	GROUP BY
		A.EmployeeID,
		A.PayType
)
SELECT --Create columns pay types and their hours in the order of their weight
	EmployeeID,
	MAX(CASE WHEN RowOrder = 1 THEN PayType
		 ELSE ''
		END) Code1,
	MAX(CASE WHEN RowOrder = 1 THEN PayHours
		 ELSE '0.00'
		END) Pay1, 
	MAX(CASE WHEN RowOrder = 2 THEN PayType
		 ELSE ''
		END) Code2,
	MAX(CASE WHEN RowOrder = 2 THEN PayHours
		 ELSE '0.00'
		END) Pay2, 
	MAX(CASE WHEN RowOrder = 3 THEN PayType
		 ELSE ''
		END) Code3,
	MAX(CASE WHEN RowOrder = 3 THEN PayHours
		 ELSE '0.00'
		END) Pay3, 
	MAX(CASE WHEN RowOrder = 4 THEN PayType
		 ELSE ''
		END) Code4,
	MAX(CASE WHEN RowOrder = 4 THEN PayHours
		 ELSE '0.00'
		END) Pay4 
FROM   TypeWiseWorkHour
GROUP BY EmployeeID
ORDER BY EmployeeID;


