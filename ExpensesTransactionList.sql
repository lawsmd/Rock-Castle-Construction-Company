USE [Rock Castle Construction]
GO

CREATE PROCEDURE spExpensesTransactionList
AS

BEGIN
	SELECT 'Bill' AS [Transaction Type], Date, Vendor AS Name, Amount, Balance
	FROM Bills

	UNION

	SELECT 'Check' AS [Transaction Type], Date, Vendor AS Name, Amount, NULL AS 'Balance'
	FROM Checks

	UNION

	SELECT 'Credit Card Charge' AS [Transaction Type], Date, Vendor AS Name, Amount, NULL AS 'Balance'
	FROM CreditCardCharges
	
	UNION

	SELECT 'Paycheck' AS [Transaction Type], Date, Employee AS Name, Amount, NULL AS 'Balance'
	FROM Paychecks
END;