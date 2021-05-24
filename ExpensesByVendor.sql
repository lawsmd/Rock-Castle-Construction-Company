USE [Rock Castle Construction]
GO

CREATE PROCEDURE spExpensesByVendor
--Parameters for 'From' and 'To' dates of report period
@FromDate date, 
@ToDate date
AS

BEGIN
	SELECT Vendor, SUM(Expenses) AS [Total Sales]

	--Sub-query to UNION Bills, Checks, and Credit Card Charges
	FROM (
		SELECT Bills.Vendor, SUM(Bills.Amount) AS Expenses
		FROM Bills
		WHERE Bills.Date >= @FromDate AND Bills.Date <= @ToDate
		GROUP BY Bills.Vendor

		UNION

		SELECT Checks.Vendor, SUM(Checks.Amount) AS Expenses
		FROM Checks
		WHERE Checks.Date >= @FromDate AND Checks.Date <= @ToDate
		GROUP BY Checks.Vendor

		UNION

		SELECT CreditCardCharges.Vendor, SUM(CreditCardCharges.Amount) AS Expenses
		FROM CreditCardCharges
		WHERE CreditCardCharges.Date >= @FromDate AND CreditCardCharges.Date <= @ToDate
		GROUP BY CreditCardCharges.Vendor
	) AS Total_Expenses

	GROUP BY Total_Expenses.Vendor
END;