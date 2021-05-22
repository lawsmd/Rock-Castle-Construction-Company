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

Thanks to this, I could calculate total Revenue and Expenses using simple arithmetic around the aliases. While these new totaled aliases could not be resued for the final Net calculation, it's still much cleaner code than adding the SUM of 8 sub-queries.

### ***Profit and Loss By Customer***
