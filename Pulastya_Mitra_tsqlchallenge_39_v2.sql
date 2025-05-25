/************************************************************
 * Pulastya Mitra
 * Time: 9/22/2010 3:31:32 PM
 ************************************************************/

SET STATISTICS IO ON
SET STATISTICS TIME ON

;WITH cteSalesSum
  AS (
         SELECT S.ItemNumber,
                SUM(S.Quantity) AS SoldQty,
                SUM(S.Quantity * S.Price) SalesCost
         FROM   TC39_Sales S
         GROUP BY
                S.ItemNumber
     ),
ctePurchaseSum
  AS (
         SELECT P.ItemNumber,
                P.PurchaseDate,
                P.Cost AS UnitCost,
                PC.Qty AS RollingStock,
                PC.Cost AS RollingCost,
                P.Quantity AS ThisStock
         FROM   TC39_Purchases P
                CROSS APPLY(
             SELECT SUM(Q.Quantity) Qty,
                    SUM(Q.Quantity * Q.Cost) Cost
             FROM   TC39_Purchases Q
             WHERE  Q.ItemNumber = P.ItemNumber
                    AND Q.PurchaseDate <= P.PurchaseDate
         ) PC
     ),
cteTranDetails
  AS (
         SELECT w.ItemNumber AS Item,
                LastPartialStock.TranDate,
                w.SoldQty AS Sold#,
                w.SalesCost AS Sales$,
                LastPartialStock.UnitCost,
                LastPartialStock.RollingStock,
                LastPartialStock.RollingCost,
                LastPartialStock.StockToUse AvailableStock,
                (
                   (w.SoldQty - LastPartialStock.RollingStock)
                   + LastPartialStock.StockToUse
                ) AS UseThisStock
         FROM   cteSalesSum AS w
                CROSS APPLY(
             SELECT z.PurchaseDate TranDate,
                    z.ThisStock AS StockToUse,
                    z.UnitCost,
                    z.RollingStock,
                    z.RollingCost
             FROM   ctePurchaseSum AS z
             WHERE  z.ItemNumber = w.ItemNumber
                    AND z.RollingStock >= w.SoldQty
         ) AS LastPartialStock
     )
SELECT X.Item,
       X.Sold#,
       CAST ((X.RollingCost -(X.UnitCost * (X.AvailableStock - X.UseThisStock)))AS DECIMAL(20,2)) AS Cost$,
       CAST (X.Sales$ AS DECIMAL(20,2)) AS Sales$,
       CAST ((X.Sales$ -(X.RollingCost -(X.UnitCost * (X.AvailableStock - X.UseThisStock))))AS DECIMAL(20,2)) Profit$
FROM   cteTranDetails X
WHERE  UseThisStock > 0
ORDER BY
       X.Item;