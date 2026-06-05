# Data Dictionary

## Bronze Tables

### bronze.BankTransactions_Raw

Raw bank CSV columns:

- Txn ID
- Date
- Month
- Description
- Category
- Type
- Amount (INR)
- Balance (INR)
- Vendor / Party

### bronze.CreditCardStatements_Raw

Raw credit-card CSV columns:

- Stmt ID
- Txn Date
- Posting Date
- Month
- Merchant / Vendor
- Category
- Card No.
- Amount (INR)
- GST (INR)
- Total (INR)
- Status
- Statement Month

## Silver Tables

### silver.BankTransactions

| Column | Meaning |
|---|---|
| BankTransactionKey | Surrogate key |
| TxnID | Bank transaction ID |
| TxnDate | Transaction date |
| TxnMonth | Month name from source |
| Description | Transaction description |
| Category | Income or expense category |
| TransactionType | Credit or Debit |
| AmountINR | Transaction amount |
| BalanceINR | Running bank balance |
| VendorParty | Vendor or party name |
| DataYear | Computed transaction year |

### silver.CreditCardTransactions

| Column | Meaning |
|---|---|
| CreditCardTransactionKey | Surrogate key |
| StmtID | Credit card statement transaction ID |
| TxnDate | Transaction date |
| PostingDate | Posting date |
| TxnMonth | Month name from source |
| MerchantVendor | Merchant or vendor name |
| Category | Expense category |
| CardNo | Masked card number |
| AmountINR | Base transaction amount |
| GSTINR | GST amount |
| TotalINR | Amount plus GST |
| Status | Posted or pending |
| StatementMonth | Statement month |
| DataYear | Computed transaction year |

## Gold Tables

### gold.FactFinancialTransaction

Main fact table for Power BI.

| Column | Meaning |
|---|---|
| SourceSystem | Bank or Credit Card |
| TransactionID | Original transaction ID |
| DateKey | Links to DimDate |
| VendorKey | Links to DimVendor |
| CategoryKey | Links to DimCategory |
| AccountKey | Links to DimAccount |
| IncomeAmountINR | Income amount |
| ExpenseAmountINR | Expense amount stored as a positive reporting value |
| GSTAmountINR | GST amount |
| TotalAmountINR | Total transaction amount |
| BalanceAfterTransactionINR | Bank balance after transaction |
| Status | Credit-card transaction status |
| Description | Transaction description |

### gold.DimDate

Date dimension with year, quarter, month, and year-month fields.

### gold.DimVendor

Vendor or merchant names.

### gold.DimCategory

Bank and credit-card transaction categories.

### gold.DimAccount

Account names:

- Operating Bank Account
- Corporate Credit Card
