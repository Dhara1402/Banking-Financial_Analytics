/*
Purpose      : Simple analysis queries for practice and Power BI validation
Author       : Dhara Budumuru
Created Date : 2026-06-03
*/

USE BankingFinancialDW;
GO

/* 1. Total income, expense, and net balance by year */
SELECT
    [Year],
    SUM(IncomeAmountINR) AS TotalIncomeINR,
    SUM(ExpenseAmountINR) AS TotalExpenseINR,
    SUM(IncomeAmountINR - ExpenseAmountINR) AS NetBalanceINR
FROM gold.vw_FinancialTransactions
GROUP BY [Year]
ORDER BY [Year];

/* 2. Monthly profit and loss summary */
SELECT
    [Year],
    MonthNumber,
    MonthName,
    SUM(IncomeAmountINR) AS TotalIncomeINR,
    SUM(ExpenseAmountINR) AS TotalExpenseINR,
    SUM(IncomeAmountINR - ExpenseAmountINR) AS NetBalanceINR
FROM gold.vw_FinancialTransactions
GROUP BY [Year], MonthNumber, MonthName
ORDER BY [Year], MonthNumber;

/* 3. Top 10 vendors by spending */
SELECT TOP 10
    VendorName,
    SUM(ExpenseAmountINR) AS TotalSpendINR,
    COUNT(*) AS TransactionCount
FROM gold.vw_FinancialTransactions
WHERE ExpenseAmountINR > 0
GROUP BY VendorName
ORDER BY TotalSpendINR DESC;

/* 4. Credit card spend by status */
SELECT
    Status,
    SUM(ExpenseAmountINR) AS TotalCreditCardSpendINR,
    COUNT(*) AS TransactionCount
FROM gold.vw_FinancialTransactions
WHERE SourceSystem = 'Credit Card'
GROUP BY Status
ORDER BY TotalCreditCardSpendINR DESC;

/* 5. Category-wise income and expense */
SELECT
    CategoryName,
    SourceSystem,
    SUM(IncomeAmountINR) AS TotalIncomeINR,
    SUM(ExpenseAmountINR) AS TotalExpenseINR
FROM gold.vw_FinancialTransactions
GROUP BY CategoryName, SourceSystem
ORDER BY TotalExpenseINR DESC, TotalIncomeINR DESC;

/* 6. Quarter-over-quarter summary */
SELECT
    [Year],
    [Quarter],
    SUM(IncomeAmountINR) AS TotalIncomeINR,
    SUM(ExpenseAmountINR) AS TotalExpenseINR,
    SUM(IncomeAmountINR - ExpenseAmountINR) AS NetBalanceINR
FROM gold.vw_FinancialTransactions
GROUP BY [Year], [Quarter]
ORDER BY [Year], [Quarter];
GO
