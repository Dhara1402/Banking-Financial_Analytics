/*
Purpose      : Clean Bronze data into typed Silver tables
Author       : Dhara Budumuru
Created Date : 2026-06-03
*/

USE BankingFinancialDW;
GO

TRUNCATE TABLE silver.BankTransactions;
TRUNCATE TABLE silver.CreditCardTransactions;
GO

INSERT INTO silver.BankTransactions
(
    TxnID,
    TxnDate,
    TxnMonth,
    Description,
    Category,
    TransactionType,
    AmountINR,
    BalanceINR,
    VendorParty
)
SELECT
    LTRIM(RTRIM([Txn ID])) AS TxnID,
    TRY_CONVERT(DATE, [Date], 106) AS TxnDate,
    LTRIM(RTRIM([Month])) AS TxnMonth,
    LTRIM(RTRIM([Description])) AS Description,
    LTRIM(RTRIM([Category])) AS Category,
    LTRIM(RTRIM([Type])) AS TransactionType,
    TRY_CONVERT(DECIMAL(18,2), REPLACE([Amount (INR)], ',', '')) AS AmountINR,
    TRY_CONVERT(DECIMAL(18,2), REPLACE([Balance (INR)], ',', '')) AS BalanceINR,
    LTRIM(RTRIM([Vendor / Party])) AS VendorParty
FROM bronze.BankTransactions_Raw;
GO

INSERT INTO silver.CreditCardTransactions
(
    StmtID,
    TxnDate,
    PostingDate,
    TxnMonth,
    MerchantVendor,
    Category,
    CardNo,
    AmountINR,
    GSTINR,
    TotalINR,
    Status,
    StatementMonth
)
SELECT
    LTRIM(RTRIM([Stmt ID])) AS StmtID,
    TRY_CONVERT(DATE, [Txn Date], 106) AS TxnDate,
    TRY_CONVERT(DATE, [Posting Date], 106) AS PostingDate,
    LTRIM(RTRIM([Month])) AS TxnMonth,
    LTRIM(RTRIM([Merchant / Vendor])) AS MerchantVendor,
    LTRIM(RTRIM([Category])) AS Category,
    LTRIM(RTRIM([Card No.])) AS CardNo,
    TRY_CONVERT(DECIMAL(18,2), REPLACE([Amount (INR)], ',', '')) AS AmountINR,
    TRY_CONVERT(DECIMAL(18,2), REPLACE([GST (INR)], ',', '')) AS GSTINR,
    TRY_CONVERT(DECIMAL(18,2), REPLACE([Total (INR)], ',', '')) AS TotalINR,
    LTRIM(RTRIM([Status])) AS Status,
    LTRIM(RTRIM([Statement Month])) AS StatementMonth
FROM bronze.CreditCardStatements_Raw;
GO

/* Simple quality checks. Any rows returned here need review. */
SELECT 'Bank rows with bad date or amount' AS CheckName, COUNT(*) AS BadRowCount
FROM silver.BankTransactions
WHERE TxnDate IS NULL OR AmountINR IS NULL
UNION ALL
SELECT 'Credit card rows with bad date or amount', COUNT(*)
FROM silver.CreditCardTransactions
WHERE TxnDate IS NULL OR AmountINR IS NULL OR TotalINR IS NULL;
GO

SELECT 'Bank silver rows' AS CheckName, COUNT(*) AS RowCount
FROM silver.BankTransactions
UNION ALL
SELECT 'Credit card silver rows', COUNT(*)
FROM silver.CreditCardTransactions;
GO
