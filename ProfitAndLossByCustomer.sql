USE [Rock Castle Construction]
GO

CREATE PROCEDURE spProfitAndLossByCustomer
--Parameters for 'From' and 'To' dates of report period
@FromDate date, 
@ToDate date,
--Customer name, to be used with wildcard search '%'
@Customer nvarchar(255)
AS

BEGIN
	WITH GrossTotals AS --CTE (Common Table Expression) so that each sub-query's alias can be used in the gross calculations below
		(
		SELECT
			--Income Data, nulls converted to 0
			(SELECT ISNULL(SUM(Amount), 0) FROM Invoices WHERE Date >= @FromDate AND Date <= @ToDate AND Customer LIKE '%' + @Customer + '%') AS Invoice_Totals,
			(SELECT ISNULL(SUM(Amount), 0) FROM SalesReceipts WHERE Date >= @FromDate AND Date <= @ToDate AND Customer LIKE '%' + @Customer + '%') AS Sales_Receipt_Totals,
			(SELECT ISNULL(SUM(Amount), 0) FROM CreditMemos WHERE Date >= @FromDate AND Date <= @ToDate AND Customer LIKE '%' + @Customer + '%') AS Credit_Memo_Totals,
			(SELECT ISNULL(SUM(Amount), 0) FROM Refunds WHERE Date >= @FromDate AND Date <= @ToDate AND Customer LIKE '%' + @Customer + '%') AS Refund_Totals,

			--Expense Data, nulls converted to 0
			(SELECT ISNULL(SUM(Amount), 0) FROM Bills WHERE Date >= @FromDate AND Date <= @ToDate AND Vendor LIKE '%' + @Customer + '%') AS Bill_Totals,
			(SELECT ISNULL(SUM(Amount), 0) FROM Checks WHERE Date >= @FromDate AND Date <= @ToDate AND Vendor LIKE '%' + @Customer + '%') AS Check_Totals,
			(SELECT ISNULL(SUM(Amount), 0) FROM CreditCardCharges WHERE Date >= @FromDate AND Date <= @ToDate AND Vendor LIKE '%' + @Customer + '%') AS Credit_Card_Charge_Totals,
			(SELECT ISNULL(SUM(Amount), 0) FROM Paychecks WHERE Date >= @FromDate AND Date <= @ToDate AND Employee LIKE '%' + @Customer + '%') AS Paycheck_Totals,
			(SELECT ISNULL(SUM(Amount), 0) FROM PurchaseOrders WHERE Date >= @FromDate AND Date <= @ToDate AND Vendor LIKE '%' + @Customer + '%') AS Purchase_Order_Totals
		)

	SELECT
		(Invoice_Totals + Sales_Receipt_Totals - Credit_Memo_Totals - Refund_Totals) AS Gross_Income,

		(Bill_Totals + Check_Totals + Credit_Card_Charge_Totals + Paycheck_Totals + Purchase_Order_Totals) AS Gross_Expenses,

		((Invoice_Totals + Sales_Receipt_Totals - Credit_Memo_Totals - Refund_Totals) - 
		(Bill_Totals + Check_Totals + Credit_Card_Charge_Totals + Paycheck_Totals + Purchase_Order_Totals)) AS Net_Income

	FROM GrossTotals --Referencing the CTE
END;