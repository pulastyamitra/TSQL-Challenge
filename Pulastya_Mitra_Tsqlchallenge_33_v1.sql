--TSQL Challenge 33 - Calculate list of bookings fully paid on the booking date
-- PULASTYA MITRA

;WITH cteA AS (
                  SELECT A.BookingId,
                         CONVERT(VARCHAR(10), A.TransactionDateTime, 112)
                         TransactionDateTime,
                         SUM(
                             CASE 
                                  WHEN A.TransactionType = 'S' THEN A.TransactionValue
                                  ELSE -1 * A.TransactionValue
                             END
                         ) TransactionValue
                  FROM   TC33_AuditTrial A
                  GROUP BY
                         A.BookingId,
                         CONVERT(VARCHAR(10), A.TransactionDateTime, 112)
              ) 
SELECT BookingId,
       TransactionDateTime
FROM   cteA
WHERE  TransactionValue = 0        