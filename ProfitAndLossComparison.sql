USE [Rock Castle Construction]
GO

CREATE PROCEDURE spProfitAndLossComparison
--Parameters for 'From' and 'To' dates of two periods to be compared
@FromDate1 date, 
@ToDate1 date,
@FromDate2 date, 
@ToDate2 date
AS

BEGIN
	--Declaring variables to receive output from P&L Output Procedure
	DECLARE @p1gR FLOAT --'Period 1, Gross Income' and so on...
	DECLARE @p1tE FLOAT
	DECLARE @p1nI FLOAT
	DECLARE @p2gR FLOAT
	DECLARE @p2tE FLOAT
	DECLARE @p2nI FLOAT

	EXECUTE spProfitAndLossOutput --Executing P&L Output Procedure for Period 1
		@FromDate = @FromDate1,
		@ToDate = @ToDate1,
		@Gross_Income = @p1gR OUTPUT,
		@Total_Expenses = @p1tE OUTPUT,
		@Net_Income = @p1nI OUTPUT

	EXECUTE spProfitAndLossOutput --Executing P&L Output Procedure for Period 2
		@FromDate = @FromDate2,
		@ToDate = @ToDate2,
		@Gross_Income = @p2gR OUTPUT,
		@Total_Expenses = @p2tE OUTPUT,
		@Net_Income = @p2nI OUTPUT

	SELECT @p1gR AS [Period 1 - Gross Income], @p1tE AS [Period 1 - Total Expenses], @p1nI AS [Period 1 - Net Income],
			@p2gR AS [Period 2 - Gross Income], @p2tE AS [Period 2 - Total Expenses], @p2nI AS [Period 2 - Net Income]
END;