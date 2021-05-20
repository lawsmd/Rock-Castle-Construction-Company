The purpose of this project is not to resolve a specific problem, but to create obstacles through which I may introduce myself to industry-valued data software solutions. I selected these skill-sets based on the frequency in which they appear in public job requirement listings. As the project continues to evolve, I'll add additional components based on the perception of their value to my professional and educational career. This process will take shape as *four distinct phases*:



1. **Extract**: Using my extensive familiarity with QuickBooks, I downloaded a free trial of the Enterprise edition and loaded the stock sample company, 'Rock Castle Construction'. From there, I exported several entity and transaction lists into Microsoft Excel, and used that data to develop an SQL Server database.
2. **Query**: I sharpened my SQL skills by emulating a handful of QuickBooks reports via complex queries, and preserved them as parameter-based Stored Procedures.
3. **Visualize**: Using the completed database, I imported the information into Power BI and Tableau to create a series of useful visualizations and interactive dashboards.
4. **Expand (Coming Soon)**: For the next step, I'll be teaching myself Python to connect with SQL Server and automate transaction creation. Furthermore, I plan to introduce crucial variables to those new transactions that were missing from the original dataset. This will greatly improve the data's reportability, allowing me to repeat *Phase 2 & 3* as many times as is necessary to achieve a truly complete analysis.



As of writing this, I have finished *Phase 3* and intend to publish the project before beginning the long and arduous process of learning Python. While there have been many hurdles along the way, often taking the form of inadequate data or steep learning curves to the respective software, I am overwhelmingly thrilled about the experience I've gained. For a time it seemed like every single query or visualization required a new syntax or methodology I had yet to learn. Still, these are vastly complex systems and I have been working with relatively simple data, so I recognize the need for continued persistence in my practice.



# **Phase 1: Extract**

Excel has always been a great option for QuickBooks users who need a little more power behind their reporting. This first step took careful consideration, as many of these lists hold pieces of the same information, creating a risk of duplicate values. Though I didn't utilize several of them, the lists I exported were:


- Customer/Vendor/Employee lists
- Transaction lists for Invoices, Sales Receipts, Credit Memos, Refunds, Bills, Checks, Item Receipts, Credit Card Charges, Paychecks, and Purchase Orders
- A couple lists only available as reports: Inventory, and the Chart of Accounts


Until this point, my only SQL experience was through homework assignments in MySQL. With that sample database in mind, I attempted to clean the Excel data in a way that could expand and simplify the querying power. Through excessive use of randomization and vlookup functions, I unknowingly created a house of cards. With each variable added, I realized how the data's pre-existing relations meant it had to be reflected throughout.

For example, the Invoice list provided only a name, date, and amount. Without the details of the Invoice (such as Products/Serviced sold), there was no way to connect them to the Income categories (via their ledger accounts) used in standard Profit/Sales reporting. Attempting to randomize the contents of the existing transactions would lead to large irregularities - like an invoice where the company sold 20 doors but only 2 hinges. Then, if doors and hinges were linked to separate income accounts, those values would be altered from the original dataset as well. An altered income value means the Balance Sheet will not balance... Every corner was a pitfall of inconsistencies and irreversible errors to the damage.


**Though I came close to giving up in frustration, I instead chose to re-download everything and start from scratch. This time, I'd import every list into SQL Server *exactly* as it came, without adding even a single column. If the project was going to be a challenge, I'd rather the challenge be the querying - not needlessly complex Excel formulas.**



# **Phase 2: Query**
