/*
Purpose      : Build Gold star schema dimensions and fact table for Power BI
Author       : Dhara Budumuru
Created Date : 2026-06-03
*/

USE BankingFinancialDW;
GO

DELETE FROM gold.FactFinancialTransaction;
DELETE FROM gold.DimDate;
DELETE FROM gold.DimVendor;
DELETE FROM gold.DimCategory;
DELETE FROM gold.DimAccount;
GO

DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT
    @StartDate = MIN(TxnDate),
    @EndDate = MAX(TxnDate)
FROM
(
    SELECT TxnDate FROM silver.BankTransactions
    UNION ALL
    SELECT TxnDate FROM silver.CreditCardTransactions
) d
WHERE TxnDate IS NOT NULL;

;WITH DateSeries AS
(
    SELECT @StartDate AS FullDate
    UNION ALL
    SELECT DATEADD(DAY, 1, FullDate)
    FROM DateSeries
    WHERE FullDate < @EndDate
)
INSERT INTO gold.DimDate
(
    DateKey,
    FullDate,
    [Year],
    [Quarter],
    MonthNumber,
    MonthName,
    YearMonth
)
SELECT
    CONVERT(INT, FORMAT(FullDate, 'yyyyMMdd')) AS DateKey,
    FullDate,
    YEAR(FullDate) AS [Year],
    CONCAT('Q', DATEPART(QUARTER, FullDate)) AS [Quarter],
    MONTH(FullDate) AS MonthNumber,
    DATENAME(MONTH, FullDate) AS MonthName,
    CONVERT(CHAR(7), FullDate, 120) AS YearMonth
FROM DateSeries
OPTION (MAXRECURSION 1000);
GO

INSERT INTO gold.DimVendor (VendorName)
SELECT DISTINCT VendorName
FROM
(
    SELECT COALESCE(NULLIF(VendorParty, ''), 'Unknown') AS VendorName
    FROM silver.BankTransactions
    UNION
    SELECT COALESCE(NULLIF(MerchantVendor, ''), 'Unknown') AS VendorName
    FROM silver.CreditCardTransactions
) v;
GO

INSERT INTO gold.DimCategory (CategoryName, SourceSystem)
SELECT DISTINCT CategoryName, SourceSystem
FROM
(
    SELECT COALESCE(NULLIF(Category, ''), 'Uncategorized') AS CategoryName, 'Bank' AS SourceSystem
    FROM silver.BankTransactions
    UNION
    SELECT COALESCE(NULLIF(Category, ''), 'Uncategorized') AS CategoryName, 'Credit Card' AS SourceSystem
    FROM silver.CreditCardTransactions
) c;
GO

INSERT INTO gold.DimAccount (AccountName, AccountType)
VALUES
    ('Operating Bank Account', 'Bank'),
    ('Corporate Credit Card', 'Credit Card');
GO

INSERT INTO gold.FactFinancialTransaction
(
    SourceSystem,
    TransactionID,
    DateKey,
    VendorKey,
    CategoryKey,
    AccountKey,
    TransactionType,
    IncomeAmountINR,
    ExpenseAmountINR,
    GSTAmountINR,
    TotalAmountINR,
    BalanceAfterTransactionINR,
    Status,
    Description
)
SELECT
    'Bank' AS SourceSystem,
    b.TxnID AS TransactionID,
    d.DateKey,
    v.VendorKey,
    c.CategoryKey,
    a.AccountKey,
    b.TransactionType,
    CASE WHEN b.TransactionType = 'Credit' THEN ABS(b.AmountINR) ELSE 0 END AS IncomeAmountINR,
    CASE WHEN b.TransactionType = 'Debit' THEN ABS(b.AmountINR) ELSE 0 END AS ExpenseAmountINR,
    0 AS GSTAmountINR,
    ABS(b.AmountINR) AS TotalAmountINR,
    b.BalanceINR AS BalanceAfterTransactionINR,
    NULL AS Status,
    b.Description
FROM silver.BankTransactions b
JOIN gold.DimDate d
    ON d.FullDate = b.TxnDate
JOIN gold.DimVendor v
    ON v.VendorName = COALESCE(NULLIF(b.VendorParty, ''), 'Unknown')
JOIN gold.DimCategory c
    ON c.CategoryName = COALESCE(NULLIF(b.Category, ''), 'Uncategorized')
   AND c.SourceSystem = 'Bank'
JOIN gold.DimAccount a
    ON a.AccountName = 'Operating Bank Account';
GO

INSERT INTO gold.FactFinancialTransaction
(
    SourceSystem,
    TransactionID,
    DateKey,
    VendorKey,
    CategoryKey,
    AccountKey,
    TransactionType,
    IncomeAmountINR,
    ExpenseAmountINR,
    GSTAmountINR,
    TotalAmountINR,
    BalanceAfterTransactionINR,
    Status,
    Description
)
SELECT
    'Credit Card' AS SourceSystem,
    cc.StmtID AS TransactionID,
    d.DateKey,
    v.VendorKey,
    c.CategoryKey,
    a.AccountKey,
    'Card Expense' AS TransactionType,
    0 AS IncomeAmountINR,
    ABS(cc.TotalINR) AS ExpenseAmountINR,
    ABS(cc.GSTINR) AS GSTAmountINR,
    ABS(cc.TotalINR) AS TotalAmountINR,
    NULL AS BalanceAfterTransactionINR,
    cc.Status,
    CONCAT('Credit card spend - ', cc.Category) AS Description
FROM silver.CreditCardTransactions cc
JOIN gold.DimDate d
    ON d.FullDate = cc.TxnDate
JOIN gold.DimVendor v
    ON v.VendorName = COALESCE(NULLIF(cc.MerchantVendor, ''), 'Unknown')
JOIN gold.DimCategory c
    ON c.CategoryName = COALESCE(NULLIF(cc.Category, ''), 'Uncategorized')
   AND c.SourceSystem = 'Credit Card'
JOIN gold.DimAccount a
    ON a.AccountName = 'Corporate Credit Card';
GO

SELECT 'Gold fact rows' AS CheckName, COUNT(*) AS RowCount
FROM gold.FactFinancialTransaction;
GO
