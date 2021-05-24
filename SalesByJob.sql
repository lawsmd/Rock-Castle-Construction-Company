USE [Rock Castle Construction]
GO

CREATE PROCEDURE spSalesByJob
--Parameters for 'From' and 'To' dates of report period
@FromDate date, 
@ToDate date
AS

BEGIN
	SELECT Customer, SUM(Sales) AS [Total Sales]

	--Sub-query to UNION Invoices and Sales Receipt Amounts
	FROM (
		SELECT Invoices.Customer, SUM(Invoices.Amount) AS Sales
		FROM Invoices
		WHERE Invoices.Date >= @FromDate AND Invoices.Date <= @ToDate
		GROUP BY Invoices.Customer

		UNION

		SELECT SalesReceipts.Customer, SUM(SalesReceipts.Amount) AS Sales
		FROM SalesReceipts
		WHERE SalesReceipts.Date >= @FromDate AND SalesReceipts.Date <= @ToDate
		GROUP BY SalesReceipts.Customer
	) AS Total_Sales

	GROUP BY Total_Sales.Customer
END;