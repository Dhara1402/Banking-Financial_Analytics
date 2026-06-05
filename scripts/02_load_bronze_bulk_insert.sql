/*
Purpose      : Load raw CSV files into Bronze tables
Author       : Dhara Budumuru
Created Date : 2026-06-03
Important    : Run this in SSMS on the SQL Server machine that can access C:\BankingDW\RawData
*/

USE BankingFinancialDW;
GO

TRUNCATE TABLE bronze.BankTransactions_Raw;
TRUNCATE TABLE bronze.CreditCardStatements_Raw;
GO

/* Bank transactions 2024 */
BULK INSERT bronze.BankTransactions_Raw
FROM 'C:\BankingDW\RawData\Bank_transactions_2024.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);
GO

/* Bank transactions 2025 */
BULK INSERT bronze.BankTransactions_Raw
FROM 'C:\BankingDW\RawData\Bank_transactions_2025.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);
GO

/* Credit card statements 2024
   File name has a typo in the source folder: CC_statemenst_2024.csv */
BULK INSERT bronze.CreditCardStatements_Raw
FROM 'C:\BankingDW\RawData\CC_statemenst_2024.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);
GO

/* Credit card statements 2025 */
BULK INSERT bronze.CreditCardStatements_Raw
FROM 'C:\BankingDW\RawData\CC_statements_2025.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);
GO

SELECT 'Bank bronze rows' AS CheckName, COUNT(*) AS RowCount
FROM bronze.BankTransactions_Raw
UNION ALL
SELECT 'Credit card bronze rows', COUNT(*)
FROM bronze.CreditCardStatements_Raw;
GO
