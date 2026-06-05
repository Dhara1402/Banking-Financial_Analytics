    # 🏦 Banking Financial Analytics — SQL Server & Power BI

![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen?style=for-the-badge)
![Architecture](https://img.shields.io/badge/Architecture-Medallion-blue?style=for-the-badge)

Welcome to the **Banking Financial Analytics** repository! 🚀  
This project demonstrates a complete **personal finance data warehouse** built with SQL Server and Power BI — covering FY 2024–2025 bank transactions and credit card statements. Designed as a portfolio project, it highlights industry best practices in **data engineering, data modelling, and business intelligence reporting**.

---

## 🚀 Project Requirements

### 🔧 Building the Data Warehouse (Data Engineering)

#### 🎯 Objective
Develop a modern data warehouse using **SQL Server** to consolidate banking and credit card financial data, enabling analytical reporting and informed personal finance decision-making.

#### 📌 Specifications
- **Data Sources**: Import data from two source systems (Bank transactions and Credit Card statements) provided as CSV files
- **Data Quality**: Cleanse and resolve data quality issues prior to analysis — including INR comma formatting, non-standard dates, blank vendor names, and negative expense values
- **Integration**: Combine both sources into a single star schema data model designed for analytical queries
- **Architecture**: Medallion architecture — Bronze (raw) → Silver (cleaned) → Gold (star schema)
- **Scope**: FY 2024 and FY 2025 data; historization not required
- **Documentation**: Full data dictionary, runbook, test cases, and troubleshooting guide provided

---

### 📊 BI: Analytics & Reporting (Data Analytics)

#### 🎯 Objective
Develop SQL-based analytics and Power BI dashboards to deliver detailed insights into:

- 💰 **Income vs Expenditure** — monthly, quarterly, and yearly P&L
- 🏪 **Vendor Spend Analysis** — top vendors by spend, frequency, and category
- 💳 **Credit Card Behaviour** — category breakdown, GST tracking, posted vs pending status
- 📈 **Balance Trends** — running bank balance over time
- 🔄 **Period-over-Period Changes** — MoM, QoQ, and YoY comparisons

These insights empower stakeholders with key financial metrics, enabling strategic personal finance decisions.

---

## 🗂️ Repository Structure

```
banking-financial-analytics/
│
├── 📁 sql_scripts/
│   ├── 01_create_database_and_tables.sql   — Database, schemas, Bronze/Silver/Gold tables
│   ├── 02_load_bronze_bulk_insert.sql       — BULK INSERT all four CSV files into Bronze
│   ├── 03_transform_silver.sql              — Clean, type-cast, and load Silver tables
│   ├── 04_build_gold_star_schema.sql        — Build star schema and load fact + dim tables
│   ├── 05_create_powerbi_views.sql          — Summary views for Power BI validation
│   └── 06_simple_analysis_queries.sql       — Ad-hoc SQL analysis queries
│
├── 📁 documentation/
│   ├── project_runbook.md                   — Step-by-step execution guide
│   ├── data_dictionary.md                   — Column definitions for all layers
│   ├── test_cases.md                        — 7 test cases covering all layers
│   └── bulk_insert_troubleshooting.md       — Fixes for common BULK INSERT errors
│
├── 📁 power_bi/
│   └── dax_measures.md                      — All DAX measures with explanations
│
└── README.md
```

---

## 🏗️ Data Architecture

This project implements the **Medallion Architecture** across three layers:

```
  CSV Files                                         Power BI
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│  Raw CSV │───▶│  BRONZE  │───▶│  SILVER  │───▶│   GOLD   │───▶ Dashboards
│  Files   │    │  (Raw)   │    │(Cleaned) │    │  (Star   │
└──────────┘    └──────────┘    └──────────┘    │  Schema) │
                                                 └──────────┘
```

| Layer | Purpose | Key Technique |
|---|---|---|
| 🥉 **Bronze** | Load raw CSV data exactly as-is | `BULK INSERT` with all columns as `NVARCHAR` |
| 🥈 **Silver** | Clean, type-cast, standardise | `TRY_CONVERT`, `REPLACE`, `LTRIM/RTRIM`, `COALESCE` |
| 🥇 **Gold** | Star schema for Power BI | Recursive CTE, `CASE WHEN`, `ABS()`, surrogate keys |

---

## 📂 Data Sources

| File | Rows | Content |
|---|---:|---|
| `Bank_transactions_2024.csv` | 131 | Bank income, expenses, running balance |
| `Bank_transactions_2025.csv` | 124 | Bank income, expenses, running balance |
| `CC_statemenst_2024.csv` | 121 | Credit card spend, GST, merchant details |
| `CC_statements_2025.csv` | 134 | Credit card spend, GST, merchant details |
| **Total** | **510** | **Rows in Gold fact table** |

> ⚠️ **Note:** Raw CSV files are not included in this repository as they contain personal financial data. `CC_statemenst_2024.csv` contains a typo in the source filename — the SQL script intentionally references the misspelled name to match the actual file.

---

## 🌟 Gold Star Schema

```
                     ┌─────────────┐
                     │   DimDate   │
                     └──────┬──────┘
                            │
┌────────────┐    ┌─────────┴──────────┐    ┌─────────────┐
│ DimAccount │────│ FactFinancial      │────│  DimVendor  │
└────────────┘    │ Transaction        │    └─────────────┘
                  └─────────┬──────────┘
                            │
                     ┌──────┴──────┐
                     │ DimCategory │
                     └─────────────┘
```

### Fact Table — `gold.FactFinancialTransaction`

| Column | Description |
|---|---|
| `SourceSystem` | `Bank` or `Credit Card` |
| `TransactionID` | Original ID from source |
| `DateKey` | FK → DimDate |
| `VendorKey` | FK → DimVendor |
| `CategoryKey` | FK → DimCategory |
| `AccountKey` | FK → DimAccount |
| `IncomeAmountINR` | Income amount (positive) |
| `ExpenseAmountINR` | Expense amount (always positive via `ABS()`) |
| `GSTAmountINR` | GST component (credit card rows) |
| `TotalAmountINR` | Total transaction amount |
| `BalanceAfterTransactionINR` | Running bank balance (bank rows only) |
| `Status` | `Posted` or `Pending` (credit card) |

---

## ▶️ How to Run

### Prerequisites
- Microsoft SQL Server (any edition including Express)
- SQL Server Management Studio (SSMS)
- CSV source files placed in `C:\BankingDW\RawData\`

### Execution Order

Run the scripts inside `/sql_scripts/` **in this exact order** from SSMS:

```
Step 1 → 01_create_database_and_tables.sql   Create BankingFinancialDW database and all tables
Step 2 → 02_load_bronze_bulk_insert.sql       Load all four CSV files into Bronze layer
Step 3 → 03_transform_silver.sql              Clean and type-cast data into Silver layer
Step 4 → 04_build_gold_star_schema.sql        Build star schema dimensions and fact table
Step 5 → 05_create_powerbi_views.sql          Create summary views for validation
Step 6 → 06_simple_analysis_queries.sql       Run ad-hoc analysis queries
```

> 💡 If `BULK INSERT` fails, see [`documentation/bulk_insert_troubleshooting.md`](documentation/bulk_insert_troubleshooting.md)

---

## 🔍 Data Quality Issues Resolved

| # | Issue | Fix Applied |
|---|---|---|
| 1 | INR amounts contain commas — e.g. `7,06,162.87` | `REPLACE(col, ',', '')` before `TRY_CONVERT` |
| 2 | Non-standard date format — `04-Jan-2024` | `TRY_CONVERT(DATE, col, 106)` |
| 3 | Blank or null vendor / category names | `COALESCE(NULLIF(col, ''), 'Unknown')` |
| 4 | Bank debits stored as negative numbers | `ABS()` applied; split into income and expense columns |
| 5 | Leading / trailing whitespace in text fields | `LTRIM(RTRIM(col))` on all text columns |
| 6 | Source CSV filename contains a typo | Script references the misspelled filename exactly |
| 7 | Recursive CTE exceeds SQL Server default 100-level limit | `OPTION (MAXRECURSION 1000)` on DimDate insert |

---

## 📊 Power BI Report Pages

| Page | Purpose | Visuals Used |
|---|---|---|
| 📅 Monthly Financial Summary | Month-wise income, expenditure, net balance | Clustered bar chart, line chart |
| 📆 Quarterly Performance | Q1–Q4 comparison with KPI cards | Grouped bar chart, 4 KPI cards |
| 🗓️ Yearly Overview 2024–2025 | Annual P&L and YoY comparison | Waterfall chart, ribbon chart |
| 💳 Credit Card Transactions | CC spend by category, vendor, and GST | Pie/donut chart, transaction table |
| 🏦 Deposits & Withdrawals | Inflow, outflow, running balance | Area chart, matrix |
| 🏪 Vendor Analysis | Top vendors by spend share and frequency | Treemap, ranked horizontal bar chart |

### Slicers on Every Page
`Year` · `Quarter` · `MonthName` · `CategoryName` · `SourceSystem` · `VendorName`

---

## 📐 DAX Measures

```dax
-- Basic aggregations
Total Income         = SUM('FactFinancialTransaction'[IncomeAmountINR])
Total Expenditure    = SUM('FactFinancialTransaction'[ExpenseAmountINR])
Net Balance          = [Total Income] - [Total Expenditure]
Total GST            = SUM('FactFinancialTransaction'[GSTAmountINR])
Transaction Count    = COUNTROWS('FactFinancialTransaction')

-- Time intelligence
MoM % Change = DIVIDE(
    [Net Balance] - CALCULATE([Net Balance], DATEADD('DimDate'[FullDate], -1, MONTH)),
    CALCULATE([Net Balance], DATEADD('DimDate'[FullDate], -1, MONTH)))

QoQ % Change = DIVIDE(
    [Net Balance] - CALCULATE([Net Balance], DATEADD('DimDate'[FullDate], -1, QUARTER)),
    CALCULATE([Net Balance], DATEADD('DimDate'[FullDate], -1, QUARTER)))

YoY % Change = DIVIDE(
    [Net Balance] - CALCULATE([Net Balance], DATEADD('DimDate'[FullDate], -1, YEAR)),
    CALCULATE([Net Balance], DATEADD('DimDate'[FullDate], -1, YEAR)))

-- Running balance (bank only)
Latest Running Balance = CALCULATE(
    MAX('FactFinancialTransaction'[BalanceAfterTransactionINR]),
    'FactFinancialTransaction'[SourceSystem] = "Bank")
```

---

## 🛠️ Key SQL Concepts Used

| Concept | Where Used |
|---|---|
| `BULK INSERT` with `FORMAT='CSV'`, `FIELDQUOTE`, `CODEPAGE` | Script 02 — loading CSVs into Bronze |
| `TRY_CONVERT` with format style 106 | Script 03 — parsing DD-Mon-YYYY dates safely |
| `REPLACE` to strip commas before decimal conversion | Script 03 — handling Indian INR formatting |
| Recursive CTE + `OPTION (MAXRECURSION 1000)` | Script 04 — generating the continuous DimDate series |
| `COALESCE(NULLIF(col, ''), 'Unknown')` | Script 04 — defaulting blank vendor/category names |
| `CASE WHEN` + `ABS()` | Script 04 — splitting and sign-correcting income vs expense |
| `IDENTITY(1,1)` surrogate keys | Silver and Gold tables — auto-generated row IDs |
| `PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE` constraints | Gold star schema — enforcing referential integrity |
| `CREATE OR ALTER VIEW` | Script 05 — idempotent view creation |
| `UNION` / `UNION ALL` | Script 04 — merging vendor lists and date ranges |
| Computed column `DataYear AS YEAR(TxnDate)` | Silver tables — auto-derived year |

---

## 📄 Documentation

| File | Contents |
|---|---|
| [`project_runbook.md`](documentation/project_runbook.md) | Full step-by-step execution guide |
| [`data_dictionary.md`](documentation/data_dictionary.md) | Column definitions for all Bronze, Silver, and Gold tables |
| [`test_cases.md`](documentation/test_cases.md) | 7 test cases covering row counts, data quality, and Power BI output |
| [`bulk_insert_troubleshooting.md`](documentation/bulk_insert_troubleshooting.md) | Fixes for the most common BULK INSERT errors |
| [`dax_measures.md`](power_bi/dax_measures.md) | All DAX measures with explanations |

---

## 📜 License

This project is licensed under the [MIT License](LICENSE).  
You are free to use, modify, and share this project with proper attribution.

---

## 🌟 About Me

Hi there! I'm **Somadhara Budumuru** with hands-on experience in **SQL Server, Power BI, and data analysis**.  
I enjoy transforming raw financial data into meaningful insights and building interactive dashboards that support data-driven decision-making.

Through projects like this data warehouse — covering ETL pipeline design, medallion architecture, star schema modelling, and Power BI reporting — I'm continuously strengthening my skills in data engineering and business intelligence.

I'm actively seeking opportunities to grow as a **Data Analyst** and contribute to data-driven organisations.

📫 Connect with me on [[LinkedIn](http://www.linkedin.com/in/somadharabudumuru)] <!-- update this link -->

    
