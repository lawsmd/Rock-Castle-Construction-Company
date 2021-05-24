USE [Rock Castle Construction]
GO

CREATE PROCEDURE spSalesByCustomer
--Parameters for 'From' and 'To' dates of report period
@FromDate date, 
@ToDate date
AS

BEGIN
	CREATE TABLE #TempSalesByJob (Customer nvarchar(255), Sales money) --Create a temp table (#) to hold Sales By Job
	INSERT #TempSalesByJob EXECUTE spSalesByJob @FromDate, @ToDate --Insert procedure results into temp table

	SELECT SUBSTRING(Customer, 0, CHARINDEX(':', Customer, 0)) AS Customer, --Substring to reduce Customer:Job(s) into just Customers
		SUM(Sales) AS Sales 
	FROM #TempSalesByJob
	GROUP BY SUBSTRING(Customer, 0, CHARINDEX(':', Customer, 0))

	DROP TABLE #TempSalesByJob --Always drop your temp tables!
END;