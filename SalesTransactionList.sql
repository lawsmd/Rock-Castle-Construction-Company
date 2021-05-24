USE [Rock Castle Construction]
GO

CREATE PROCEDURE spSalesTransactionList --Output needed for visualizations
AS

BEGIN
	SELECT 'Invoice' AS [Transaction Type], Invoices.Date, Invoices.Customer AS Name, Invoices.Amount, 
		CustomerList.Job_Type
	FROM Invoices JOIN CustomerList ON Invoices.Customer = CustomerList.Customer

	UNION

	SELECT 'Sales Receipt' AS [Transaction Type], SalesReceipts.Date, SalesReceipts.Customer AS Name, SalesReceipts.Amount,
		CustomerList.Job_Type
	FROM SalesReceipts JOIN CustomerList ON SalesReceipts.Customer = CustomerList.Customer

	UNION

	SELECT 'Refund' AS [Transaction Type], Refunds.Date, Refunds.Customer AS Name, (Refunds.Amount * (-1)),
		CustomerList.Job_Type
	FROM Refunds JOIN CustomerList ON Refunds.Customer = CustomerList.Customer
	
	UNION

	SELECT 'Credit Memo' AS [Transaction Type], CreditMemos.Date, CreditMemos.Customer AS Name, (CreditMemos.Amount * (-1)),
		CustomerList.Job_Type
	FROM CreditMemos JOIN CustomerList ON CreditMemos.Customer = CustomerList.Customer

	ORDER BY Date
END;