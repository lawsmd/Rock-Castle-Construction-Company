USE [Rock Castle Construction]
GO

CREATE PROCEDURE spProfitAndLossOutput --This procedure is only for outputting to other procedures which need the pre-calculated data (i.e. P&L Comparison)
--Parameters for 'From' and 'To' dates of report period
@FromDate date, 
@ToDate date,
--Output parameters to be passed into other procedures
@Gross_Revenue FLOAT OUTPUT,
@Total_Expenses FLOAT OUTPUT,
@Net_Income FLOAT OUTPUT
AS

BEGIN
	--Declaring variables for holding calculations to be passed to output parameters
	DECLARE @gRevenue FLOAT;
	DECLARE @tExpenses FLOAT;
	DECLARE @nIncome FLOAT;

	WITH GrossTotals AS --CTE (Common Table Expression) so that each sub-query's alias can be used in the gross calculations below
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

	--Three separate queries for passing calculations to output parameters
	SELECT @gRevenue = (Invoice_Totals + Sales_Receipt_Totals - Credit_Memo_Totals - Refund_Totals),
			@tExpenses = (Bill_Totals + Check_Totals + Credit_Card_Charge_Totals + Paycheck_Totals),
			@nIncome = ((Invoice_Totals + Sales_Receipt_Totals - Credit_Memo_Totals - Refund_Totals) - 
						(Bill_Totals + Check_Totals + Credit_Card_Charge_Totals + Paycheck_Totals))
	 FROM GrossTotals;

	--Setting the final calculations to the output parameters
	SET @Gross_Revenue = @gRevenue;
	SET @Total_Expenses = @tExpenses;
	SET @Net_Income = @nIncome;
END;