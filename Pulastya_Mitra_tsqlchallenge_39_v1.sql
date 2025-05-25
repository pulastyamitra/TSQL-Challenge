;WITH cteSalesSum
  AS (
         SELECT P.ItemNumber,
                SUM(P.Quantity) AS Quantity,
                SUM(P.Quantity * P.Price) SalesCost
         FROM   TC39_Sales P
         GROUP BY
                P.ItemNumber
     ),
ctePurchaseSum
  AS (
         SELECT ROW_NUMBER() OVER (PARTITION BY P.ItemNumber ORDER BY PurchaseDate) BatchID,
				P.ItemNumber,
                P.PurchaseDate,
                P.Cost		AS UnitCost,
                CA.Qty		AS RollingStock,
                CA.Cost		AS RollingCost,
                P.Quantity AS ThisStock
         FROM   TC39_Purchases P
                CROSS APPLY(
             SELECT SUM(i.Quantity) Qty,
                    SUM(i.Quantity * I.Cost) Cost
             FROM   TC39_Purchases I
             WHERE  I.ItemNumber = P.ItemNumber
                    AND I.PurchaseDate <= P.PurchaseDate
         ) CA
     ),
cteWithLastTranDate
  AS (
         SELECT w.ItemNumber,
                w.Quantity,
                LastPartialStock.BatchID,
                LastPartialStock.TranDate,
				LastPartialStock.UnitCost,
				LastPartialStock.RollingStock,
				LastPartialStock.RollingCost,
                LastPartialStock.StockToUse,
                LastPartialStock.RunningTotal,
                w.Quantity - LastPartialStock.RunningTotal
                + LastPartialStock.StockToUse AS UseThisStock
         FROM   cteSalesSum AS w
                CROSS APPLY(
             SELECT z.BatchID,
					z.PurchaseDate TranDate,
                    z.ThisStock AS StockToUse,
                    z.RollingStock AS RunningTotal,
                    z.UnitCost,
                    z.RollingStock,
                    z.RollingCost
             FROM   ctePurchaseSum AS z
             WHERE  z.ItemNumber = w.ItemNumber
                    AND z.RollingStock >= w.Quantity
         ) AS LastPartialStock
  )
  SELECT * FROM cteWithLastTranDate
  WHERE UseThisStock>0
  
  
--  ,
--cteTotalCost AS (
--SELECT y.ItemNumber AS Item,
--       y.Quantity AS Sold#,
--       CAST(SUM(y.RollingCost) +
--       SUM(
--           CAST(
--               (
--                   CASE 
--                        WHEN e.PurchaseDate = y.TranDate THEN y.UseThisStock
--                        ELSE e.Quantity
--                   END
--               ) AS DECIMAL(20, 2)
--           ) * CostPrice.Price
--       ) AS DECIMAL(20,2))AS Cost$
--FROM   cteWithLastTranDate AS y
--       INNER JOIN TC39_Purchases AS e
--            ON  e.ItemNumber = y.ItemNumber
--            AND e.PurchaseDate >= y.TranDate
--       CROSS APPLY(
--    SELECT TOP(1)
--           CAST(p.Cost AS DECIMAL(20, 2)) Price
--    FROM   TC39_Purchases AS p
--    WHERE  p.ItemNumber = e.ItemNumber
--           AND p.PurchaseDate >= e.PurchaseDate
--    ORDER BY
--           p.PurchaseDate DESC
--) AS CostPrice
--GROUP BY
--       y.ItemNumber,
--       y.Quantity
--)
--SELECT 
--	C.Item,
--	C.Sold#,
--	C.Cost$,
--	S.SalesCost	AS Sales$,
--	CAST((S.SalesCost - C.Cost$) AS DECIMAL(20,2)) AS Profit$
--FROM cteTotalCost C ,cteSalesSum S
--WHERE C.Item = S.ItemNumber
       
       
