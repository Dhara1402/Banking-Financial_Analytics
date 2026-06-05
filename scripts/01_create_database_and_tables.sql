/*
Purpose      : Create Banking Financial Data Warehouse tables using Bronze, Silver, Gold medallion architecture
Author       : Dhara Budumuru
Created Date : 2026-06-03
Tool         : Microsoft SQL Server
*/

IF DB_ID('BankingFinancialDW') IS NULL
BEGIN
    CREATE DATABASE BankingFinancialDW;
END;
GO

USE BankingFinancialDW;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'bronze') EXEC('CREATE SCHEMA bronze');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'silver') EXEC('CREATE SCHEMA silver');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'gold') EXEC('CREATE SCHEMA gold');
GO

/* Bronze tables: raw CSV structure. Keep all fields as NVARCHAR to avoid load failures. */
DROP TABLE IF EXISTS bronze.BankTransactions_Raw;
CREATE TABLE bronze.BankTransactions_Raw
(
    [Txn ID] NVARCHAR(50) NULL,
    [Date] NVARCHAR(50) NULL,
    [Month] NVARCHAR(30) NULL,
    [Description] NVARCHAR(255) NULL,
    [Category] NVARCHAR(100) NULL,
    [Type] NVARCHAR(20) NULL,
    [Amount (INR)] NVARCHAR(50) NULL,
    [Balance (INR)] NVARCHAR(50) NULL,
    [Vendor / Party] NVARCHAR(150) NULL
);
GO

DROP TABLE IF EXISTS bronze.CreditCardStatements_Raw;
CREATE TABLE bronze.CreditCardStatements_Raw
(
    [Stmt ID] NVARCHAR(50) NULL,
    [Txn Date] NVARCHAR(50) NULL,
    [Posting Date] NVARCHAR(50) NULL,
    [Month] NVARCHAR(30) NULL,
    [Merchant / Vendor] NVARCHAR(150) NULL,
    [Category] NVARCHAR(100) NULL,
    [Card No.] NVARCHAR(50) NULL,
    [Amount (INR)] NVARCHAR(50) NULL,
    [GST (INR)] NVARCHAR(50) NULL,
    [Total (INR)] NVARCHAR(50) NULL,
    [Status] NVARCHAR(30) NULL,
    [Statement Month] NVARCHAR(50) NULL
);
GO

/* Silver tables: cleaned and typed data. */
DROP TABLE IF EXISTS silver.BankTransactions;
CREATE TABLE silver.BankTransactions
(
    BankTransactionKey INT IDENTITY(1,1) CONSTRAINT PK_silver_BankTransactions PRIMARY KEY,
    TxnID NVARCHAR(50) NOT NULL,
    TxnDate DATE NULL,
    TxnMonth NVARCHAR(30) NULL,
    Description NVARCHAR(255) NULL,
    Category NVARCHAR(100) NULL,
    TransactionType NVARCHAR(20) NULL,
    AmountINR DECIMAL(18,2) NULL,
    BalanceINR DECIMAL(18,2) NULL,
    VendorParty NVARCHAR(150) NULL,
    DataYear AS YEAR(TxnDate)
);
GO

DROP TABLE IF EXISTS silver.CreditCardTransactions;
CREATE TABLE silver.CreditCardTransactions
(
    CreditCardTransactionKey INT IDENTITY(1,1) CONSTRAINT PK_silver_CreditCardTransactions PRIMARY KEY,
    StmtID NVARCHAR(50) NOT NULL,
    TxnDate DATE NULL,
    PostingDate DATE NULL,
    TxnMonth NVARCHAR(30) NULL,
    MerchantVendor NVARCHAR(150) NULL,
    Category NVARCHAR(100) NULL,
    CardNo NVARCHAR(50) NULL,
    AmountINR DECIMAL(18,2) NULL,
    GSTINR DECIMAL(18,2) NULL,
    TotalINR DECIMAL(18,2) NULL,
    Status NVARCHAR(30) NULL,
    StatementMonth NVARCHAR(50) NULL,
    DataYear AS YEAR(TxnDate)
);
GO

/* Gold star schema: reporting tables for Power BI. */
DROP TABLE IF EXISTS gold.FactFinancialTransaction;
DROP TABLE IF EXISTS gold.DimDate;
DROP TABLE IF EXISTS gold.DimVendor;
DROP TABLE IF EXISTS gold.DimCategory;
DROP TABLE IF EXISTS gold.DimAccount;
GO

CREATE TABLE gold.DimDate
(
    DateKey INT NOT NULL CONSTRAINT PK_gold_DimDate PRIMARY KEY,
    FullDate DATE NOT NULL,
    [Year] INT NOT NULL,
    [Quarter] VARCHAR(2) NOT NULL,
    MonthNumber INT NOT NULL,
    MonthName NVARCHAR(30) NOT NULL,
    YearMonth CHAR(7) NOT NULL
);
GO

CREATE TABLE gold.DimVendor
(
    VendorKey INT IDENTITY(1,1) CONSTRAINT PK_gold_DimVendor PRIMARY KEY,
    VendorName NVARCHAR(150) NOT NULL,
    CONSTRAINT UQ_gold_DimVendor UNIQUE (VendorName)
);
GO

CREATE TABLE gold.DimCategory
(
    CategoryKey INT IDENTITY(1,1) CONSTRAINT PK_gold_DimCategory PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL,
    SourceSystem NVARCHAR(30) NOT NULL,
    CONSTRAINT UQ_gold_DimCategory UNIQUE (CategoryName, SourceSystem)
);
GO

CREATE TABLE gold.DimAccount
(
    AccountKey INT IDENTITY(1,1) CONSTRAINT PK_gold_DimAccount PRIMARY KEY,
    AccountName NVARCHAR(100) NOT NULL,
    AccountType NVARCHAR(50) NOT NULL,
    CONSTRAINT UQ_gold_DimAccount UNIQUE (AccountName)
);
GO

CREATE TABLE gold.FactFinancialTransaction
(
    FinancialTransactionKey INT IDENTITY(1,1) CONSTRAINT PK_gold_FactFinancialTransaction PRIMARY KEY,
    SourceSystem NVARCHAR(30) NOT NULL,
    TransactionID NVARCHAR(50) NOT NULL,
    DateKey INT NOT NULL,
    VendorKey INT NOT NULL,
    CategoryKey INT NOT NULL,
    AccountKey INT NOT NULL,
    TransactionType NVARCHAR(30) NULL,
    IncomeAmountINR DECIMAL(18,2) NOT NULL DEFAULT 0,
    ExpenseAmountINR DECIMAL(18,2) NOT NULL DEFAULT 0,
    GSTAmountINR DECIMAL(18,2) NOT NULL DEFAULT 0,
    TotalAmountINR DECIMAL(18,2) NOT NULL DEFAULT 0,
    BalanceAfterTransactionINR DECIMAL(18,2) NULL,
    Status NVARCHAR(30) NULL,
    Description NVARCHAR(255) NULL,
    CONSTRAINT FK_Fact_Date FOREIGN KEY (DateKey) REFERENCES gold.DimDate(DateKey),
    CONSTRAINT FK_Fact_Vendor FOREIGN KEY (VendorKey) REFERENCES gold.DimVendor(VendorKey),
    CONSTRAINT FK_Fact_Category FOREIGN KEY (CategoryKey) REFERENCES gold.DimCategory(CategoryKey),
    CONSTRAINT FK_Fact_Account FOREIGN KEY (AccountKey) REFERENCES gold.DimAccount(AccountKey)
);
GO
