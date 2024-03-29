USE [Rock Castle Construction]
GO

CREATE PROCEDURE spInventoryValuation
AS

BEGIN
	SELECT Item, Quantity, (Quantity * Cost) AS [Asset Value]
	FROM ItemList
	WHERE Type = 'Inventory Part' AND Item LIKE '%:%' --LIKE to exclude Bundle Names
END;