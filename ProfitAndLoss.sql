USE [Rock Castle Construction]
GO

CREATE PROCEDURE spProfitAndLoss
--Parameters for 'From' and 'To' dates of report period
@FromDate date, 
@ToDate date 
AS

BEGIN
	WITH Totals AS --CTE (Common Table Expression) so that each sub-query's alias can be used in the gross calculations below
		(
		SELECT
			--Income Data, nulls converted to 0
			(SELECT ISNULL(SUM(Amount), 0) FROM Invoices WHERE Date >= @FromDate AND Date <= @ToDate) AS Invoice_Totals,
			(SELECT ISNULL(SUM(Amount), 0) FROM SalesReceipts WHERE Date >= @FromDate AND Date <= @ToDate) AS Sales_Receipt_Totals,
			(SELECT ISNULL(SUM(Amount), 0) FROM CreditMemos WHERE Date >= @FromDate AND Date <= @ToDate) AS Credit_Memo_Totals,
			(SELECT ISNULL(SUM(Amount), 0) FROM Refunds WHERE Date >= @FromDate AND Date <= @ToDate) AS Refund_Totals,

			--Expense Data, nulls converted to 0
			(SELECT ISNULL(SUM(Amount), 0) FROM Bills WHERE Date >= @FromDate AND Date <= @ToDate) AS Bill_Totals,
			(SELECT ISNULL(SUM(Amount), 0) FROM Checks WHERE Date >= @FromDate AND Date <= @ToDate) AS Check_Totals,
			(SELECT ISNULL(SUM(Amount), 0) FROM CreditCardCharges WHERE Date >= @FromDate AND Date <= @ToDate) AS Credit_Card_Charge_Totals,
			(SELECT ISNULL(SUM(Amount), 0) FROM Paychecks WHERE Date >= @FromDate AND Date <= @ToDate) AS Paycheck_Totals
		)

	SELECT
		(Invoice_Totals + Sales_Receipt_Totals - Credit_Memo_Totals - Refund_Totals) AS [Gross Revenue],

		(Bill_Totals + Check_Totals + Credit_Card_Charge_Totals + Paycheck_Totals) AS [Total Expenses],

		((Invoice_Totals + Sales_Receipt_Totals - Credit_Memo_Totals - Refund_Totals) - 
		(Bill_Totals + Check_Totals + Credit_Card_Charge_Totals + Paycheck_Totals)) AS [Net Income]

	FROM Totals --Referencing the CTE
END;