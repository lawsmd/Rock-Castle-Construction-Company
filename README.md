The purpose of this project is not to resolve a specific problem, but to create obstacles through which I may introduce myself to industry-valued data software solutions. I selected these skill-sets based on the frequency in which they appear in public job requirement listings. As the project continues to evolve, I'll add additional components based on the perception of their value to my professional and educational careers. This process will include *four distinct phases*:



1. **Extract**: Using my extensive familiarity with QuickBooks, I downloaded a free trial of the Enterprise edition and opened the stock sample company, 'Rock Castle Construction'. From there, I exported several entity and transaction lists into Microsoft Excel, and used that data to develop an SQL Server database.
2. **Query**: I sharpened my SQL skills by emulating a handful of QuickBooks reports via complex queries, and preserved them as parameter-based Stored Procedures.
3. **Visualize**: Using the completed database, I imported the information into Power BI and Tableau to create a series of useful visualizations and interactive dashboards.
4. **Expand (Coming Soon)**: For the next step, I'll be teaching myself Python from scratch to connect with SQL Server and automate transaction creation. Furthermore, I plan to introduce crucial variables to those transactions that were missing from the original dataset. This will greatly improve the data's reportability, allowing me to repeat *Phase 2 & 3* as many times as is necessary to achieve a truly complete analysis.



As of writing this, I have finished *Phase 3* and intend to publish the project before beginning the long and arduous process of learning Python. While there have been many hurdles along the way, often taking the form of inadequate data or steep learning curves to the respective software, I am overwhelmingly thrilled about the experience I've gained. For a time it seemed like every single query or visualization required a new syntax or methodology I had yet to learn. Still, these are vastly complex systems and I have been working with relatively simple data, so I recognize the need for continued persistence in my practice.



# **Phase 1: Extract**

Excel has always been a great option for QuickBooks users who need a little more power behind their reporting. This first step took careful consideration, as many of these lists hold pieces of the same information, which creates the risk of duplicate values. Though I didn't utilize several of them, the lists I exported were:


- *Customer/Vendor/Employee lists*
- *Transaction lists for Invoices, Sales Receipts, Credit Memos, Refunds, Bills, Checks, Item Receipts, Credit Card Charges, Paychecks, and Purchase Orders*
- *A couple lists only available as reports: Inventory, and the Chart of Accounts*


Until this point, my only SQL experience was through homework assignments in MySQL. With that sample database in mind, I attempted to clean the Excel data in a way that could expand and simplify the querying power. Through excessive use of randomization and vlookup functions, I unknowingly created a house of cards. With each variable added, I realized how the data's pre-existing relations meant it had to be reflected throughout.

For example, the Invoice list provided only a name, date, and amount. Without the details of the Invoice (such as Products/Serviced sold), there was no way to connect them to the Income categories (via their ledger accounts) used in standard Profit/Sales reporting. Attempting to randomize the contents of the existing transactions would lead to large irregularities - like an invoice where the company sold 20 doors but only 2 hinges. Then, if doors and hinges were linked to separate income accounts, those values would be altered from the original dataset as well. An altered income value means the Balance Sheet will not balance... Every corner was a pitfall of inconsistencies and irreversible errors to the damage.


**Though I came close to giving up in frustration, instead I chose to re-download everything and start from scratch. This time, I'd import every list into SQL Server *exactly* as it came, without adding even a single column. If the project was going to be a challenge, I'd rather the challenge be in querying subpar data - not writing needlessly complex Excel formulas.**



# **Phase 2: Query**

For each of these queries, I'll discuss only the inputs, outputs, and respective 'obstacles' that served as valuable learning opportunities when writing them. To see the full code for each procedure, follow the project repository link at the top of the page.



### ***Profit and Loss***

Those familiar with a typical *Profit and Loss* report might have already been concerned about the lack of a relationship between the sales transactions and their income categories. Until I can expand the data and create that relationship, the P&L is limited to the totals of Revenue transactions, Expense transactions, and their difference stated as 'Net Income'. For every report where it is helpful, there are 'From' and 'To' date parameters accepted as input variables.
  
The first obstacle arose when totaling Revenue and Expenses, which involved 8 different transaction types combined into two aliases with 4 SUM statements each. However, calculating Net Income using those aliases isn't possible within the same SELECT statement. For this, a **Common Table Expression** was used. This function creates a temporary result table which can be referenced only within the immediately proceeding statement.

```
{
WITH Totals AS --CTE (Common Table Expression) so that each sub-query's alias can be used in the gross calculations below
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
}
```

Thanks to this, I could calculate total Revenue and Expenses using simple arithmetic around the aliases. While these new totaled aliases could not be resued for the final et calculation, it's still much simpler than adding the SUM of 8 sub-queries.

---
### ***Profit and Loss By Customer***

Not much changes here, only an input customer parameter searched for in each transaction list using the LIKE statement. As with many of these reports, their current usefulness is limited until data expansion. Even though it is quite capable of it, and a frequently used feature at that, QuickBooks did not have any Expenses tied to their Customers/Jobs - only Vendors. Therefore, each customer carries only Revenue at present time.

```
{
@Customer nvarchar(255)
AS

BEGIN
	WITH GrossTotals AS --CTE (Common Table Expression) so that each sub-query's alias can be used in the gross calculations below
		(
		SELECT
			--Income Data, nulls converted to 0
			(SELECT ISNULL(SUM(Amount), 0) FROM Invoices WHERE Date >= @FromDate AND Date <= @ToDate AND Customer LIKE '%' + @Customer + '%') AS Invoice_Totals,
			(SELECT ISNULL(SUM(Amount), 0) FROM SalesReceipts WHERE Date >= @FromDate AND Date <= @ToDate AND Customer LIKE '%' + @Customer + '%') AS Sales_Receipt_Totals,
			(SELECT ISNULL(SUM(Amount), 0) FROM CreditMemos WHERE Date >= @FromDate AND Date <= @ToDate AND Customer LIKE '%' + @Customer + '%') AS Credit_Memo_Totals,
			(SELECT ISNULL(SUM(Amount), 0) FROM Refunds WHERE Date >= @FromDate AND Date <= @ToDate AND Customer LIKE '%' + @Customer + '%') AS Refund_Totals,

			--Expense Data, nulls converted to 0
			(SELECT ISNULL(SUM(Amount), 0) FROM Bills WHERE Date >= @FromDate AND Date <= @ToDate AND Vendor LIKE '%' + @Customer + '%') AS Bill_Totals,
			(SELECT ISNULL(SUM(Amount), 0) FROM Checks WHERE Date >= @FromDate AND Date <= @ToDate AND Vendor LIKE '%' + @Customer + '%') AS Check_Totals,
			(SELECT ISNULL(SUM(Amount), 0) FROM CreditCardCharges WHERE Date >= @FromDate AND Date <= @ToDate AND Vendor LIKE '%' + @Customer + '%') AS Credit_Card_Charge_Totals,
			(SELECT ISNULL(SUM(Amount), 0) FROM Paychecks WHERE Date >= @FromDate AND Date <= @ToDate AND Employee LIKE '%' + @Customer + '%') AS Paycheck_Totals
		)
}
```

---
### ***Profit and Loss Comparison***

This report compares the Profit and Loss of two separate periods. While I could have simply doubled the entirety of the original *Profit and Loss* procedure, I chose instead to learn about passing **Output Parameters** from Stored Procedures. To do this, I first had to create a 'Profit and Loss Output' procedure, which had several key differences to the report's base form:

1. Declare the output parameters and their data types.
2. Declare these parameters as variables within the statement itself.
3. Calculate the totals into the variables instead of the aliases.
4. SET the output parameters equal to those variables.

Everything else about the P&L stays the same.

```
{
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
}
```


```
{
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
}
```

With that output available, I needed only to declare 6 variables to receive it (3 for each period) and then execute the procedure twice. Then, the entire report is just a SELECT statement aliasing the variables.

```
{
BEGIN
	--Declaring variables to receive output from P&L Output Procedure
	DECLARE @p1gR FLOAT --'Period 1, Gross Revenue' and so on...
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
}
```

---
### ***Sales by Job***

One of the biggest consequences to the 'no changes' approach of importing QuickBooks data was the format in which Customers and Jobs were received. By default, it was 'Customer:Job', without any spaces. While Excel could have made quick work of this with *Find and Replace*, I still foresaw lots of those aforementioned pitfalls down the road. 

Since all sales transactions were assigned to Jobs and never the base entity ('Customer' vs. 'Customer:Job'), I started with *Sales by Job* since I assumed it would be easier. As it turned out, the GROUP BY statement is quite limited when aggregrating multiple tables. Since I needed the totals from Invoices **and** Sales Receipts, I had to UNION their tables through a sub-query in the FROM statement. Furthermore, I had to alias the SUMS of both joined tables to be allowed to SUM them in the parent SELECT statement, and then separately alias the entire sub-query to reference it in the proceeding GROUP BY.

```
{
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
}
```

---
### ***Sales by Customer***

With that hurdle out of the way, a report on accumulative customer sales needed only one further trick: breaking 'Customer:Job' into base form. To begin, I used a **Temporary Table** to run and store the *Sales by Job* results. Using CHARINDEX, I could return the position of the ':' to a SUBSTRING function in the **Length** parameter. Since the string starts at position 0 but the value passed into Length must be positive, the *SUBSTRING* will always end one character short of the colon's position - providing the base customer every time.

```
{
BEGIN
	CREATE TABLE #TempSalesByJob (Customer nvarchar(255), Sales money) --Create a temp table (#) to hold Sales By Job
	INSERT #TempSalesByJob EXECUTE spSalesByJob @FromDate, @ToDate --Insert procedure results into temp table

	SELECT SUBSTRING(Customer, 0, CHARINDEX(':', Customer, 0)) AS Customer, --Substring to reduce Customer:Job(s) into just Customers
		SUM(Sales) AS Sales 
	FROM #TempSalesByJob
	GROUP BY SUBSTRING(Customer, 0, CHARINDEX(':', Customer, 0))

	DROP TABLE #TempSalesByJob --Always drop your temp tables!
END;
}
```

---
### ***Expenses by Vendor***

Nothing new here. The FROM statement sub-query can hold as many joined tables as is needed, assuming they are the same format.

```
{
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
}
```

---
### ***Accounts Receivable/Payable Aging***

The Aging report was another that seemed simple in concept, but turned out particularly challenging. I felt certain that sub-queries were necessary to group any Invoices with an open balance into the standard 30-60-90 day periods. However, this created the same issue as the Sales reports: you can't always **GROUP BY** with sub-query results. Instead, the **CASE** function could be used within a **SUM** to collect values '**WHEN**' the Due Date fell in a certain range.

The original dataset was primarily dated between 2023 and 2027 - I assume this was to remove the need for constantly updating a sample company. Since today's date (via **GETDATE()**) wouldn't yield any overdue transactions, it was necessary to **DATEADD()** to an arbitrarily chosen date. For both the *Receivable and Payable Aging* reports, the best option turned out to be '2027-01-01' - a coincidence which almost guarantees that QuickBooks Developers entered the sample data around that date. Converting these procedures to use the current date is as simple as swapping out a single parameter.

```
{
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
}
```

Nothing changes for the Payable version of this report, it's simply *Bills* instead of *Invoices*.

---
### ***Inventory Valuation Detail***

At last, a short and simple query. Item 'Bundles' share the same naming scheme as *Customers and Jobs*, but a simple LIKE statement paired with wildcard searching ('%') will drop the extra weight here. As previously discussed, Inventory is the key to expanding the data's reportability. This procedure will surely be revisited once *Phase 4* is complete.


```
{
BEGIN
	SELECT Item, Quantity, (Quantity * Cost) AS [Asset Value]
	FROM ItemList
	WHERE Type = 'Inventory Part' AND Item LIKE '%:%' --LIKE to exclude Bundle Names
END;
}
```

---
### ***Other***

For the time being, only some simple Transaction Lists reside in the remaining procedures. They aren't worth discussing, as they were simply a large collection of various UNION statements. I wrote these while working on visualizations in *Phase 3* after gaining a better understanding of how Power BI and Tableau utilize data.

---
# **Phase 3: Visualize**

For this phase, I'll be sharing an overview of the interactive dashboards I created in either product, as well as links to their respective host's websites. I'll also be providing a brief comparison of the two in terms of learning curve, usability, flexibility, and depth. While my MySQL experience gave me a huge lead on learning SQL Server, I had no prior visualization exposure outside of trivial Excel charting. Thankfully, solutions like Power BI and Tableau require little to no prerequisite skills. 

As before, the notable lack of this data's reportability limited the types of reports available for providing valuable analysis. However, this did not prevent me from learning the core concepts necessary to understanding a typical workflow in either solution. For example, **Expenses** reported by 'Transaction Type' (Bill, Check, Credit Card Charge) might seem irrelevant to decreasing a business's costs - but replacing that visual's 'Transaction Type' axis with something more valuable, like *Expense Categories* (Fuel, Insurance, COGS), requires no more than a couple clicks.

---
### ***Power BI***

I started with Power BI because it was, in my experience, the outright industry leader in business intelligence visualization software. Seeing as how Microsoft played the lead role in both of the previous phases (Excel and SQL Server), this solution held my clear preference and interest going into the project.

Aside from the ceaseless learning curve obstacles, persisting mostly of countless Google and YouTube searches with 'How Do I' questions, there was only one major obstacle present in *both* applications. In order to ensure seamless **filtering** capabilities by date or name (customer/vendor), a relationship must be specified between the imported data sources. While this (like so many obstacles before it) seemed simple in concept, it created many strange and unanswered issues in practice.

To make a long story short, this was due to what I learned was the data's **Cardinality**, which has 3 distinct types: One-to-one, one-to-many, or many-to-many. To simplify this, the issue was that any variable selected to create a relationship between the *Sales and Expenses tables*, such as *Date*, might contain duplicates in the opposing table with no correlation between those transactions. This means that all of the QuickBooks data was related through **many-to-many cardinality**.

This particular cardinality creates barriers when slicing or filtering by the variable which holds the relationship. To resolve this, a third table - simply named *Combined* - was imported with all of the existing data aggregated together. Visualizations throughout the dashboard would only reference ***either*** the *Sales* or *Expenses* tables, but use the *Combined* table's **Date** relationship for their filtering purposes.

However, as a result, any visualization which used Sales ***and*** Expenses together (i.e. *Profit and Loss*) would need special input filtering via programming code. Power BI uses **DAX**, which Microsoft defines as:

> "a collection of functions, operators, and constants that can be used in a formula, or expression, to calculate and return one or more values. Stated more simply, DAX helps you create new information from data already in your model."

In this sample, I needed to re-calculate *Gross Revenue* by summing only the items with a 'Type' matching a Sales transaction. This formula is repeated for Expense transaction types, and then the two measures are combined to calculate *Net Income*.

```
{
	Gross Revenue = 
		CALCULATE(SUM('Combined'[Amount]), 'Combined'[Transaction Type] = "Invoice") + 
		CALCULATE(SUM('Combined'[Amount]), 'Combined'[Transaction Type] = "Sales Receipt") + 
		CALCULATE(SUM('Combined'[Amount]), 'Combined'[Transaction Type] = "Refund") + 
		CALCULATE(SUM('Combined'[Amount]), 'Combined'[Transaction Type] = "Credit Memo")
}
```

```
{
	Net Income = 
		(('Combined'[Gross Revenue]) - ('Combined'[Total Expenses]))
}
```
---

The capabilities of Power BI's buttons, which can be used to navigate between the various 'pages' of a report, inspired me to create a simple P&L dashboard which can drill down to obtain further details about either Sales or Expenses. [Here's a public link to the interactive dashboard.](https://app.powerbi.com/groups/d5a31c77-3fc7-41ae-a57b-34910c8d3a83/reports/715d1880-b34d-475f-8e68-55aca5bc8399/ReportSection)

![Rock Castle Construction - Power BI P&L](https://i.imgur.com/eDn4TAJ.png)

![Rock Castle Construction - Power BI Sales](https://i.imgur.com/6J0vJTf.png)

![Rock Castle Construction - Power BI Expenses](https://i.imgur.com/n2Vahw3.png)

---

My final thoughts on **Power BI** are as follows:

- At face value, this is the kind of curated experience I would expect from Microsoft. Finding a new function or preference was made easy by the carefully arranged interface, and each setting was properly labeled.
- I was bit surprised to find a *lack* of customizations compared to what I'm accustomed to in Excel. Something like giving the bars in your graph an outline to accentuate them against their background might seem trivial to the analysis at hand, but this application isn't marketed as a limited solution for the average consumer.
- Despite the studying needed regarding *Cardinality*, the process of importing, creating relationships between, and utilizing data was shockingly simple and intuitive.
- The public or community-based resources for learning the application or circumnavigating issues are both abundant and helpful.

---
### ***Tableau***

Any preconceived notions that I had about BI solutions being different flavors of the same scoop were melted away by Tableau. At first glance, the only remotely similar function was the menu for managing imported data. Unfortunately, the free version ('Tableau Public') had extremely limited import options compared to its paid or enterprise alternatives. Since SQL Server was off the table, I simply exported the transactions lists (including *Combined*, for the same reason as before) into Excel and pulled them into Tableau from there.

As opposed to *DAX*, Tableau uses its own proprietary language for additional data manipulation. The code needed to parse the **Combined** table here was a bit harder to learn, but easier to understand. Same idea as before: SUM the Sales and Expense transactions repsectively, then SUM the two measures to calculate *Net Income*.


`
	SUM( 
    		IF[Type] = "Invoice"
   		OR [Type] = "Sales Receipt"
    		OR [Type] = "Refund"
   		OR [Type] = "Credit Memo"
    		THEN [Amount] 
		END
	)
`

---

I was quite the fan of Tableau's workflow: design one visualization per 'Workheet', then pick-and-choose worksheets to create a dashboard. This time I went for an all-in-one report - a little less depth for the convenience of quick conveyance. [Here's a public link to the interactive dashboard.](https://public.tableau.com/profile/michael.laws5772#!/vizhome/RockCastleConstruction/ProfitandLoss)

![Rock Castle Construction - Tableau P&L](https://i.imgur.com/WF8dZDs.png)

---

My final thoughts on **Tableau** are as follows:

- The learning curve is sharply steeper. The excessive requirement of drag-and-drop seems valuable to a veteran user, but is far from intuitive to a beginner like myself.
- Menus are unclear, vaguely labeled, and a little scattered at times.
- I had become spoiled on Power BI's seamless alignment grid-lines. Arranging worksheets free-hand is a nightmare, and there's no chance of making adjacent visualizations of even size. The vertical and horizontal worksheet 'containers' are a nice touch, but I wish they weren't a requirement for symmetry in your finished product.
- Limitations in the free version seem a little unreasonable. I was unable to import from SQL Server, I couldn't export the final product to an image file, and I was made to sign up for a trial account to publish the dashboard publicly.
- Creating data relationships was only available to worksheets that were within the same Excel workbook.
- All of this negativity aside, I finally started to 'feel' the program's depth towards the end of my work. If it were my full-time job to create visualizations, I can see how the drag-and-drop system could make for an extremely efficient workflow.

---
# **Phase 4: Expand (Coming Soon)**

The goal of this phase is to finally start tearing down some of the project's aforementioned limitations. Furthermore, I'll use this goal to learn what is arguably the most valuable skill-set for my employability: **Python**. I have a fairly complete understanding of C++, so I'm going to find a resource that specializes in teaching Python as a *second language* to ensure an efficient curriculum.

My plan is to develop scripts capable of automatically creating more complex transactions and adding them to SQL Server via the official integration library. Some examples are:

- **Sales Transaction Details**: Using the existing table as a 'parent' source, each Invoice will have its individual line items, each one containing a Product/Service item that can be traced to the *Item List* table to determine which Income category the sale feeds to. I'll also look into recording *Sales Tax* for tracking its liability.
- **Exepense Transaction Details**: Same concept, except these transactions skip straight to their Expense categories (ledger accounts).
- **Inventory Management**: Fleshing out the details of *Purchase Orders* to track inventory's *quantity-on-hand*, as well as obtain a detailed breakdown of the *Cost of Goods Sold*.
- **Reporting Variables**: Any combination of these transactions can be assigned a **Class** or **Location** to further increase their reportability. Examples from QuickBooks include Sales Representatives or Pricing Levels as *Classes*, and Departments or Divisions as *Locations* (i.e. Sales by Sales Rep, Expenses by Department, etc.)

---

### Thank you for taking the time to read about this project. Follow the GitHub link at the top of the page to see my work in its entirety.
