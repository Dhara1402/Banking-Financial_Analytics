/*
Purpose      : Create reusable Gold views for Power BI reporting
Author       : Dhara Budumuru
Created Date : 2026-06-03
*/

USE BankingFinancialDW;
GO

CREATE OR ALTER VIEW gold.vw_FinancialTransactions
AS
SELECT
    f.FinancialTransactionKey,
    f.SourceSystem,
    f.TransactionID,
    d.FullDate,
    d.[Year],
    d.[Quarter],
    d.MonthNumber,
    d.MonthName,
    d.YearMonth,
    v.VendorName,
    c.CategoryName,
    a.AccountName,
    a.AccountType,
    f.TransactionType,
    f.IncomeAmountINR,
    f.ExpenseAmountINR,
    f.GSTAmountINR,
    f.TotalAmountINR,
    f.BalanceAfterTransactionINR,
    f.Status,
    f.Description
FROM gold.FactFinancialTransaction f
JOIN gold.DimDate d ON d.DateKey = f.DateKey
JOIN gold.DimVendor v ON v.VendorKey = f.VendorKey
JOIN gold.DimCategory c ON c.CategoryKey = f.CategoryKey
JOIN gold.DimAccount a ON a.AccountKey = f.AccountKey;
GO

CREATE OR ALTER VIEW gold.vw_MonthlySummary
AS
SELECT
    [Year],
    MonthNumber,
    MonthName,
    YearMonth,
    SUM(IncomeAmountINR) AS TotalIncomeINR,
    SUM(ExpenseAmountINR) AS TotalExpenseINR,
    SUM(IncomeAmountINR - ExpenseAmountINR) AS NetBalanceINR
FROM gold.vw_FinancialTransactions
GROUP BY [Year], MonthNumber, MonthName, YearMonth;
GO

CREATE OR ALTER VIEW gold.vw_QuarterlySummary
AS
SELECT
    [Year],
    [Quarter],
    SUM(IncomeAmountINR) AS TotalIncomeINR,
    SUM(ExpenseAmountINR) AS TotalExpenseINR,
    SUM(IncomeAmountINR - ExpenseAmountINR) AS NetBalanceINR
FROM gold.vw_FinancialTransactions
GROUP BY [Year], [Quarter];
GO

CREATE OR ALTER VIEW gold.vw_VendorSpend
AS
SELECT
    VendorName,
    CategoryName,
    SourceSystem,
    COUNT(*) AS TransactionCount,
    SUM(ExpenseAmountINR) AS TotalSpendINR
FROM gold.vw_FinancialTransactions
WHERE ExpenseAmountINR > 0
GROUP BY VendorName, CategoryName, SourceSystem;
GO

CREATE OR ALTER VIEW gold.vw_CategorySummary
AS
SELECT
    [Year],
    [Quarter],
    MonthName,
    CategoryName,
    SourceSystem,
    SUM(IncomeAmountINR) AS TotalIncomeINR,
    SUM(ExpenseAmountINR) AS TotalExpenseINR
FROM gold.vw_FinancialTransactions
GROUP BY [Year], [Quarter], MonthName, CategoryName, SourceSystem;
GO
