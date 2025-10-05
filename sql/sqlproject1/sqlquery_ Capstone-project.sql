-- Part 1: Customer Overview & Aggregations
-- List all customers with their total number of accounts and total combined balance (across all account types).
-- Find the average transaction amount for each transaction_type.
-- Identify the top 5 customers by their total combined balance.
-- Count how many accounts are 'Active', 'Closed', or 'Suspended' for each customer_id.


use BankDB;
-- 1. List all customers with their total number of accounts and total combined balance (across all account types).

SELECT * FROM Customers;
Select * from Accounts;
SELECT 
    c.customer_id, --sellecting custemer id from customers table
    c.first_name, --sellecting first name from customers table
    c.last_name,  --sellecting last name from customers table
    COUNT(a.account_id) AS total_accounts,--counting total accounts from accounts table
    SUM(a.balance) AS total_balance --sum of balance from accounts table
FROM Customers c --
LEFT JOIN Accounts a --
    ON c.customer_id = a.customer_id --joining both tables on customer id column
GROUP BY c.customer_id, c.first_name, c.last_name; --grouping by customer id, first name and last name


-- 2. Find the average transaction amount for each transaction_type.

SELECT 
    t.transaction_type, --sellecting transaction type from transactions table
    AVG(amount) AS average_amount from Transactions t
    GROUP BY t.transaction_type; --finding average of amount from transactions table--grouping by transaction type

-- 3. Identify the top 5 customers by their total combined balance.

SELECT TOP 5
    c.customer_id, --selecting customer id from customers table
    c.first_name, --selecting first name from customers table
    c.last_name, --selecting last name from customers table
    COUNT(a.account_id) AS total_accounts, --counting total accounts from accounts table
    SUM(a.balance) AS total_combined_balance --sum of balance from accounts table
FROM Customers c -- selecting from customers table
JOIN Accounts a  --joining accounts table to customers table
    ON c.customer_id = a.customer_id --joining both tables on customer id column
GROUP BY c.customer_id, c.first_name, c.last_name --grouping by customer id, first name and last name
ORDER BY total_combined_balance DESC; --ordering by total balance in descending order

-- 4. Count how many accounts are 'Active', 'Closed', or 'Suspended' for each customer_id.

SELECT 
    c.customer_id,
    --firstname and lastname not necessary but added for better understanding of output
    c.first_name, --selecting first name from customers table
    c.last_name, --selecting last name from customers table
    SUM(CASE WHEN a.status = 'Active' THEN 1 ELSE 0 END) AS active_accounts, --counting active accounts from accounts table
    SUM(CASE WHEN a.status = 'Closed' THEN 1 ELSE 0 END) AS closed_accounts, --counting closed accounts from accounts table
    SUM(CASE WHEN a.status = 'Suspended' THEN 1 ELSE 0 END) AS suspended_accounts --counting suspended accounts from accounts table
FROM Customers c -- selecting from customers table
LEFT JOIN Accounts a -- joining accounts table to customers table
    ON c.customer_id = a.customer_id -- joining both tables on customer id column
GROUP BY c.customer_id,c.first_name,c.last_name-- grouping by customer id
ORDER BY c.customer_id; --ordering by customer id




--Part 2: Transaction Analysis & Trends
--Calculate the total deposit amount and total withdrawal amount per month across all accounts.
--Find the average number of transactions per customer.
--Identify accounts that have had no transactions in the last 6 months (assume current date is '2023-07-01').
--For each customer, find their most recent transaction date.

-- 1. Calculate the total deposit amount and total withdrawal amount per month across all accounts.


Select * from Transactions;
SELECT
   -- t.account_id, --selecting transaction id and account id from transactions table,this is optional but added for better understanding of output
    FORMAT(t.transaction_date, 'MMM') AS month, --formatting transaction date to month
    SUM(CASE WHEN t.transaction_type = 'Deposit' THEN t.amount ELSE 0 END) AS total_deposit, --summing deposit amount from transactions table
    SUM(CASE WHEN t.transaction_type = 'Withdrawal' THEN t.amount ELSE 0 END) AS total_withdrawal --summing withdrawal amount from transactions table
FROM Transactions t --selecting from transactions table
GROUP BY FORMAT(T.transaction_date, 'MMM') --grouping by month
ORDER BY month desc; --ordering by month

-- 2. Find the average number of transactions per customer.

Select * from Customers;
Select * from Accounts;
Select * from Transactions;


SELECT 
    c.customer_id, --selecting customer id from customers table
    c.first_name, --selecting first name from customers table
    c.last_name, --selecting last name from customers table
    COUNT(t.transaction_id) AS total_transactions, --counting total transactions from transactions table
    COUNT(t.transaction_id) * 1 / NULLIF(COUNT(DISTINCT c.customer_id), 0) AS avg_transactions_for_this_customer --finding average of transactions per customer
FROM Customers c --selecting from customers table
LEFT JOIN Accounts a ON c.customer_id = a.customer_id --joining accounts table to customers table on customer id column
LEFT JOIN Transactions t ON a.account_id = t.account_id --joining transactions table to accounts table on account id column
GROUP BY c.customer_id, c.first_name, c.last_name --grouping by customer id, first name and last name
ORDER BY total_transactions DESC; --ordering by total transactions in descending order

-- 3. Identify accounts that have had no transactions in the last 6 months (assume current date is '2023-07-01').


SELECT 
    a.account_id, --selecting account id from accounts table
    a.account_type, --selecting account type from accounts table
    c.customer_id, --selecting customer id from customers table
    -- firstname and lastname not necessary but added for better understanding of output
    c.first_name, --selecting first name from customers table
    c.last_name, --selecting last name from customers table
    MAX(t.transaction_date) AS last_transaction_date --finding maximum transaction date from transactions table
FROM Accounts a --selecting from accounts table
JOIN Customers c ON a.customer_id = c.customer_id --joining customers table to accounts table on customer id column
LEFT JOIN Transactions t ON a.account_id = t.account_id --joining transactions table to accounts table on account id column
GROUP BY a.account_id, c.customer_id, c.first_name, c.last_name,a.account_type --grouping by account id and customer id
HAVING MAX(t.transaction_date) IS NULL --checking for null values in transaction date
   OR MAX(t.transaction_date) < '2023-01-01' --checking for transaction date less than 6 months from current date
ORDER BY c.last_name, c.first_name; --ordering by last name and first name

-- 4. For each customer, find their most recent transaction date.


SELECT 
    c.customer_id, --selecting customer id from customers table
    -- firstname and lastname not necessary but added for better understanding of output
    c.first_name, --selecting first name from customers table
    c.last_name, --selecting last name from customers table
    MAX(t.transaction_date) AS most_recent_transaction --finding maximum transaction date from transactions table
FROM Customers c --selecting from customers table
LEFT JOIN Accounts a ON c.customer_id = a.customer_id --joining accounts table to customers table on customer id column
LEFT JOIN Transactions t ON a.account_id = t.account_id --joining transactions table to accounts table on account id column
GROUP BY c.customer_id, c.first_name, c.last_name --grouping by customer id, first name and last name
ORDER BY most_recent_transaction DESC; --ordering by most recent transaction in descending order

--Part 3: Customer Segmentation & Profitability (Advanced)
--Customer Profitability Score: Create a query that calculates a simplified "profitability score" for each customer. This could be (Total Deposits - Total Withdrawals - Total Fees) from their transactions.
--Rank Customers by Profitability: Rank customers based on this profitability score.
--High-Value Customers: Identify customers who have both a 'Savings' account with a balance over $5,000 AND have made at least 5 'Deposit' transactions.
--Loan Portfolio Overview: Summarize the total loan_amount and average interest_rate for all 'Active' loans.

-- 1. Customer Profitability Score: Create a query that calculates a simplified "profitability score" for each customer. This could be (Total Deposits - Total Withdrawals - Total Fees) from their transactions.

SELECT 
    c.customer_id, --selecting customer id from customers table
    -- firstname and lastname not necessary but added for better understanding of output
    c.first_name,
    c.last_name,
    COALESCE(SUM(CASE WHEN t.transaction_type = 'Deposit' THEN t.amount ELSE 0 END), 0) AS total_deposits, --summing deposit amount from transactions table
    COALESCE(SUM(CASE WHEN t.transaction_type = 'Withdrawal' THEN ABS(t.amount) ELSE 0 END), 0) AS total_withdrawals, --summing withdrawal amount from transactions table
    COALESCE(SUM(CASE WHEN t.transaction_type = 'Fee' THEN ABS(t.amount) ELSE 0 END), 0) AS total_fees, --summing fee amount from transactions table
    --calculating profitability score by subtracting total withdrawals and total fees from total deposits
    COALESCE(SUM(CASE WHEN t.transaction_type = 'Deposit' THEN t.amount ELSE 0 END), 0) -- total deposits
    - COALESCE(SUM(CASE WHEN t.transaction_type = 'Withdrawal' THEN ABS(t.amount) ELSE 0 END), 0) -- total withdrawals
    - COALESCE(SUM(CASE WHEN t.transaction_type = 'Fee' THEN ABS(t.amount) ELSE 0 END), 0) AS profitability_score --profitability score
FROM Customers c --selecting from customers table
LEFT JOIN Accounts a ON c.customer_id = a.customer_id --joining accounts table to customers table on customer id column
LEFT JOIN Transactions t ON a.account_id = t.account_id --joining transactions table to accounts table on account id column
GROUP BY c.customer_id, c.first_name, c.last_name --grouping by customer id, first name and last name
ORDER BY profitability_score DESC; --ordering by profitability score in descending order

-- 2. Rank Customers by Profitability: Rank customers based on this profitability score.
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    COALESCE(SUM(CASE WHEN t.transaction_type = 'Deposit' THEN t.amount ELSE 0 END), 0) AS total_deposits, --summing deposit amount from transactions table
    COALESCE(SUM(CASE WHEN t.transaction_type = 'Withdrawal' THEN ABS(t.amount) ELSE 0 END), 0) AS total_withdrawals, --summing withdrawal amount from transactions table
    COALESCE(SUM(CASE WHEN t.transaction_type = 'Fee' THEN ABS(t.amount) ELSE 0 END), 0) AS total_fees, --summing fee amount from transactions table
    
     --calculating profitability score by subtracting total withdrawals and total fees from total deposits
    COALESCE(SUM(CASE WHEN t.transaction_type = 'Deposit' THEN t.amount ELSE 0 END), 0) -- total deposits
    - COALESCE(SUM(CASE WHEN t.transaction_type = 'Withdrawal' THEN ABS(t.amount) ELSE 0 END), 0) -- total withdrawals
    - COALESCE(SUM(CASE WHEN t.transaction_type = 'Fee' THEN ABS(t.amount) ELSE 0 END), 0) AS profitability_score, --profitability score
    --ranking customers based on profitability score using RANK() function
    DENSE_RANK() OVER (ORDER BY 
        COALESCE(SUM(CASE WHEN t.transaction_type = 'Deposit' THEN t.amount ELSE 0 END), 0)
      - COALESCE(SUM(CASE WHEN t.transaction_type = 'Withdrawal' THEN ABS(t.amount ) ELSE 0 END), 0) 
      - COALESCE(SUM(CASE WHEN t.transaction_type = 'Fee' THEN ABS(t.amount) ELSE 0 END), 0) DESC
    ) AS profitability_rank
FROM Customers c --selecting from customers table
LEFT JOIN Accounts a ON c.customer_id = a.customer_id --joining accounts table to customers table on customer id column
LEFT JOIN Transactions t ON a.account_id = t.account_id --joining transactions table to accounts table on account id column
GROUP BY c.customer_id, c.first_name, c.last_name --grouping by customer id, first name and last name
ORDER BY profitability_rank; --ordering by profitability rank

-- 3. High-Value Customers: Identify customers who have both a 'Savings' account with a balance over $5,000 AND have made at least 5 'Deposit' transactions.


Select * from Customers;
Select * from Accounts;
Select * from Transactions;


SELECT 
    c.customer_id, --selecting customer id from customers table 
    c.first_name,
    c.last_name,
    a.account_id, --selecting account id from accounts table
    a.balance, --selecting balance from accounts table
     --counting number of deposit transactions from transactions table
    COUNT(t.transaction_id) AS deposit_count -- counting deposit transactions
FROM Customers c --selecting from customers table
JOIN Accounts a ON c.customer_id = a.customer_id --joining accounts table to customers table on customer id column
LEFT JOIN Transactions t -- joining transactions table to accounts table on account id column
    ON a.account_id = t.account_id  -- joining on account id column
    AND t.transaction_type = 'Deposit' -- filtering for deposit transactions
WHERE a.account_type = 'Savings' -- filtering for savings account type
  AND a.balance > 50 -- filtering for balance greater than 5000
GROUP BY c.customer_id, c.first_name, c.last_name, a.account_id, a.balance --grouping by customer id, first name, last name, account id and balance
--WHEN YOU RUN THE QUERY FROM HERE IT GIVES YOU THE COUNT OF CUSTOMERS WITH SAVINGS BALANCES GREATER THAN $500

HAVING COUNT(t.transaction_id) >= 5 --having deposit count greater than or equal to 5
--ORDER BY c.customer_id; --ordering by customer id
ORDER BY a.balance DESC; --ordering by balance in descending order


-- 4. Loan Portfolio Overview: Summarize the total loan_amount and average interest_rate for all 'Active' loans.

Select * from Loans;
--bringing loan details with customer details for better understanding of output
SELECT 
    l.loan_id, --selecting loan id from loans table
    l.account_id, --selecting account id from loans table
    a.customer_id, --selecting customer id from accounts table
    c.first_name, --selecting first name from customers table
    c.last_name, --selecting last name from customers table
    l.loan_amount, --selecting loan amount from loans table
    l.interest_rate --selecting interest rate from loans table
FROM Loans l 
JOIN Accounts a ON l.account_id = a.account_id --joining accounts table to loans table on account id column
JOIN Customers c ON a.customer_id = c.customer_id --joining customers table to accounts table on customer id column
WHERE l.loan_status = 'Active' --filtering for active loans
ORDER BY l.loan_amount DESC; 

--Loan Portfolio Summary
-- Summarizing total active loans, total loan amount and average interest rate for active loans
SELECT 
    COUNT(*) AS total_active_loans, --counting total active loans from loans table
    SUM(loan_amount) AS total_loan_amount, --summing loan amount from loans table
    AVG(interest_rate) AS avg_interest_rate --finding average interest rate from loans table
FROM Loans --selecting from loans table
WHERE loan_status = 'Active'; --filtering for active loans

--Part 4: Database Objects for Reporting
--Create a View: Create a view named vw_CustomerFinancialOverview that combines customer names, their total balance, and their total number of transactions.
--Create a View: Create a view named vw_MonthlyTransactionSummary that shows total deposits and withdrawals per month.

GO
--Using go command to separate batches of sql statements which is specific to SQL Server that indicates the end of a batch of sql statements which is useful when creating views or stored procedures


CREATE VIEW vw_CustomerFinancialOverview AS ---creating view named vw_CustomerFinancialOverview
SELECT 
    c.customer_id,--selecting customer id from customers table
    c.first_name,
    c.last_name,
    COALESCE(SUM(a.balance), 0) AS total_balance, --summing balance from accounts table
     --counting total transactions from transactions table
    COALESCE(COUNT(t.transaction_id), 0) AS total_transactions --counting total transactions from transactions table
FROM Customers c --selecting from customers table
LEFT JOIN Accounts a ON c.customer_id = a.customer_id --joining accounts table to customers table on customer id column
LEFT JOIN Transactions t ON a.account_id = t.account_id --joining transactions table to accounts table on account id column
GROUP BY c.customer_id, c.first_name, c.last_name; --grouping by customer id, first name and last name

GO

select * from vw_CustomerFinancialOverview;


---Create a View: Create a view named vw_MonthlyTransactionSummary that shows total deposits and withdrawals per month.


DROP VIEW IF EXISTS vw_MonthlyTransactionSummary;
GO

CREATE VIEW vw_MonthlyTransactionSummary AS ---creating view named vw_MonthlyTransactionSummary
SELECT  
    FORMAT(transaction_date, 'yyyy-MM') AS year_month, --formatting transaction date to year and month
    SUM(CASE WHEN transaction_type = 'Deposit' THEN amount ELSE 0 END) AS total_deposits, --summing deposit amount from transactions table
    SUM(CASE WHEN transaction_type = 'Withdrawal' THEN amount ELSE 0 END) AS total_withdrawals --summing withdrawal amount from transactions table
FROM Transactions --selecting from transactions table
GROUP BY FORMAT(transaction_date, 'yyyy-MM'); --grouping by year and month


GO 
select * from vw_MonthlyTransactionSummary; 