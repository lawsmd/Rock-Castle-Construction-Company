USE [Rock Castle Construction]
GO

CREATE PROCEDURE spTransactionListByDate
--Parameters for 'From' and 'To' dates of report period
@FromDate date, 
@ToDate date 
AS

BEGIN
	--A simple collection of UNIONs to show all transactions between FromDate and ToDate
	SELECT 'Invoice' AS [Transaction Type], Date, Customer AS Name, Amount
	FROM Invoices
	WHERE Date >= @FromDate AND Date <= @ToDate

	UNION

	SELECT 'Sales Receipt' AS [Transaction Type], Date, Customer AS Name, Amount
	FROM SalesReceipts
	WHERE Date >= @FromDate AND Date <= @ToDate

	UNION

	SELECT 'Credit Memo' AS [Transaction Type], Date, Customer AS Name, (Amount * (-1))
	FROM CreditMemos
	WHERE Date >= @FromDate AND Date <= @ToDate

	UNION

	SELECT 'Refund' AS [Transaction Type], Date, Customer AS Name, (Amount * (-1))
	FROM Refunds
	WHERE Date >= @FromDate AND Date <= @ToDate

	UNION

	SELECT 'Bill' AS [Transaction Type], Date, Vendor AS Name, Amount
	FROM Bills
	WHERE Date >= @FromDate AND Date <= @ToDate

	UNION

	SELECT 'Check' AS [Transaction Type], Date, Vendor AS Name, Amount
	FROM Checks
	WHERE Date >= @FromDate AND Date <= @ToDate

	UNION

	SELECT 'Credit Card Charge' AS [Transaction Type], Date, Vendor AS Name, Amount
	FROM CreditCardCharges
	WHERE Date >= @FromDate AND Date <= @ToDate

	UNION

	SELECT 'Paycheck' AS [Transaction Type], Date, Employee AS Name, Amount
	FROM Paychecks
	WHERE Date >= @FromDate AND Date <= @ToDate

	ORDER BY Date
END;