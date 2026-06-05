# Test Cases

Run these checks after each phase.

## Test Case 1: Bronze Row Counts

```SQL
SELECT COUNT(*) AS BankRows
FROM bronze.BankTransactions_Raw;

SELECT COUNT(*) AS CreditCardRows
FROM bronze.CreditCardStatements_Raw;
```

Expected:

- BankRows = 255
- CreditCardRows = 255

## Test Case 2: Silver Bad Date or Amount Check

```SQL
SELECT *
FROM silver.BankTransactions
WHERE TxnDate IS NULL OR AmountINR IS NULL;

SELECT *
FROM silver.CreditCardTransactions
WHERE TxnDate IS NULL OR AmountINR IS NULL OR TotalINR IS NULL;
```

Expected:

- No rows returned.

## Test Case 3: Gold Fact Row Count

```SQL
SELECT COUNT(*) AS GoldFactRows
FROM gold.FactFinancialTransaction;
```

Expected:

- GoldFactRows = 510

## Test Case 4: Power BI View Works

```SQL
SELECT TOP 10 *
FROM gold.vw_FinancialTransactions
ORDER BY FullDate;
```

Expected:

- Rows are returned.
- Dates, vendors, categories, income, and expense amounts are visible.

## Test Case 5: Yearly Summary

```SQL
SELECT
    [Year],
    SUM(IncomeAmountINR) AS TotalIncomeINR,
    SUM(ExpenseAmountINR) AS TotalExpenseINR,
    SUM(IncomeAmountINR - ExpenseAmountINR) AS NetBalanceINR
FROM gold.vw_FinancialTransactions
GROUP BY [Year]
ORDER BY [Year];
```

Expected:

- Two rows: 2024 and 2025.

## Test Case 6: Expense Amounts Are Positive

```SQL
SELECT *
FROM gold.FactFinancialTransaction
WHERE ExpenseAmountINR < 0;
```

Expected:

- No rows returned.

## Test Case 7: Net Balance Formula

```SQL
SELECT
    YearMonth,
    SUM(IncomeAmountINR) AS TotalIncomeINR,
    SUM(ExpenseAmountINR) AS TotalExpenseINR,
    SUM(IncomeAmountINR - ExpenseAmountINR) AS NetBalanceINR
FROM gold.vw_FinancialTransactions
GROUP BY YearMonth
ORDER BY YearMonth;
```

Expected:

- `TotalExpenseINR` should be positive.
- `NetBalanceINR` should equal income minus expense.
