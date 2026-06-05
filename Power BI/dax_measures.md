# Power BI DAX Measures

Create these measures in Power BI after loading the Gold star schema tables:

- `gold.FactFinancialTransaction`
- `gold.DimDate`
- `gold.DimVendor`
- `gold.DimCategory`
- `gold.DimAccount`

Create relationships:

- `FactFinancialTransaction[DateKey]` to `DimDate[DateKey]`
- `FactFinancialTransaction[VendorKey]` to `DimVendor[VendorKey]`
- `FactFinancialTransaction[CategoryKey]` to `DimCategory[CategoryKey]`
- `FactFinancialTransaction[AccountKey]` to `DimAccount[AccountKey]`

Mark `DimDate` as the date table using `DimDate[FullDate]`.

```DAX
Total Income = SUM('FactFinancialTransaction'[IncomeAmountINR])
```

```DAX
Total Expenditure = SUM('FactFinancialTransaction'[ExpenseAmountINR])
```

```DAX
Net Balance = [Total Income] - [Total Expenditure]
```

```DAX
Total GST = SUM('FactFinancialTransaction'[GSTAmountINR])
```

```DAX
Transaction Count = COUNTROWS('FactFinancialTransaction')
```

```DAX
MoM % Change =
VAR PreviousMonthValue =
    CALCULATE(
        [Net Balance],
        DATEADD('DimDate'[FullDate], -1, MONTH)
    )
RETURN
    DIVIDE([Net Balance] - PreviousMonthValue, PreviousMonthValue)
```

```DAX
QoQ % Change =
VAR PreviousQuarterValue =
    CALCULATE(
        [Net Balance],
        DATEADD('DimDate'[FullDate], -1, QUARTER)
    )
RETURN
    DIVIDE([Net Balance] - PreviousQuarterValue, PreviousQuarterValue)
```

```DAX
YoY % Change =
VAR PreviousYearValue =
    CALCULATE(
        [Net Balance],
        DATEADD('DimDate'[FullDate], -1, YEAR)
    )
RETURN
    DIVIDE([Net Balance] - PreviousYearValue, PreviousYearValue)
```

## Suggested Report Pages

1. Executive Summary
   - Cards: Total Income, Total Expenditure, Net Balance, Transaction Count
   - Line chart: Net Balance by YearMonth
   - Bar chart: Income vs Expenditure by Year

2. Monthly and Quarterly P&L
   - Matrix: Year, Quarter, MonthName
   - Values: Total Income, Total Expenditure, Net Balance

3. Vendor Spend Analysis
   - Bar chart: Top vendors by Total Expenditure
   - Table: VendorName, CategoryName, Transaction Count, Total Expenditure

4. Category Analysis
   - Donut or bar chart: Expense by CategoryName
   - Slicer: SourceSystem

5. Credit Card Analysis
   - Bar chart: Spend by Status
   - Table: Merchant/Vendor, Category, Total GST, Total Expenditure

## Required Slicers

Add slicers from the dimension tables:

- `DimDate[Year]`
- `DimDate[Quarter]`
- `DimDate[MonthName]`
- `DimCategory[CategoryName]`
- `FactFinancialTransaction[SourceSystem]`
