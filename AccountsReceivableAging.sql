USE [Rock Castle Construction]
GO

CREATE PROCEDURE spAccountsReceivableAging
@BeginDate date --Begin date only needed since QuickBooks data is from future periods (~2023-2027),
				--otherwise only today's date would be used, i.e. GETDATE()
AS

BEGIN
	SELECT SUBSTRING(Customer, 0, CHARINDEX(':', Customer, 0)) AS Customer, --Substring 'Customer:Jobs' into base Customers to GROUP BY them

		SUM(CASE --SUM Balance when parameter date is ON or BEFORE due date
				WHEN Due_Date >= @BeginDate 
				THEN Balance
				ELSE NULL
			END) AS [Current],

		SUM(CASE --SUM Balance when Due Date is before parameter date but Due Date + 30 Days is greater than parameter date
				WHEN Due_Date < @BeginDate 
					AND DATEADD(DD, 30, Due_Date) > @BeginDate 
				THEN Balance
				ELSE NULL
			END) AS [1 - 30],

		SUM(CASE --SUM Balance when Due Date is between 31 and 60 Days greater than parameter date
				WHEN DATEADD(DD, 31, Due_Date) < @BeginDate  
					AND DATEADD(DD, 60, Due_Date) > @BeginDate 
				THEN Balance
				ELSE NULL
			END) AS [31 - 60],

		SUM(CASE --SUM Balance when Due Date is between 61 and 90 Days greater than parameter date
				WHEN DATEADD(DD, 61, Due_Date) < @BeginDate 
					AND DATEADD(DD, 90, Due_Date) > @BeginDate 
				THEN Balance
				ELSE NULL
			END) AS [61 - 90],

		SUM(CASE --SUM Balance when due date is more than 91 days greater than parameter date
				WHEN DATEADD(DD, 91, Due_Date) < @BeginDate 
				THEN Balance
				ELSE NULL
			END) AS [91+]

	FROM Invoices
	WHERE Balance IS NOT NULL --Ensuring customers with no balance do not appear
	GROUP BY Customer
END;