# Data Cleaning & Preparation

Issue 1: Inconsistent Product Naming**
- Problem: Same products had multiple variations due to:

  - Capitalization differences (e.g., "STAR" vs "Star")
  - Abbreviations vs full names (e.g., "G/Black" vs "Goldberg/Black")
  - Misspellings and naming inconsistencies
  - Duplicate entries for free promotional items with different product_ids

- Solution: Standardized all product names in Excel to consistent title case, full names, and merged duplicate records

- Impact: Prevented artificial data splitting across identical products, ensuring accurate sales and profit calculations

# Data Loading & Configuration

Data Quality Check:

**Issue:** Trailing blank rows in CSV files cause PostgreSQL import failures

ERROR: null value in column "product_id" violates not-null constraint
DETAIL: Failing row contains (null, null, null, null).

**Solution:** Remove malformed rows before import

sed -i '' '/^[,[:space:]]*$/d' './data/product_dim.csv'
sed -i '' '/^[,[:space:]]*$/d' './data/inventory_fact.csv'

Date Format Handling

Issue: CSV contains dates in DD/MM/YYYY format (UK standard), but PostgreSQL defaults to MDY (US format).

Solution: Configure session to match source data format

-- Set date format to match UK date convention in CSV
SET datestyle = DMY;

-- Loaded data
# SQL Analysis

1. Which drinks generate the highest total profit?

Query:
```sql
SELECT 
    product_dim.drink,
    selling_price - purchase_price AS profit_margin,
    SUM(inventory_fact.sold * (selling_price - purchase_price)) AS total_profit
FROM product_dim 
INNER JOIN inventory_fact ON product_dim.product_id = inventory_fact.product_id
WHERE purchase_price > 0  -- Exclude promotional items
GROUP BY product_dim.drink, profit_margin
ORDER BY total_profit DESC;
```

Key Insights:
- Top 3 drinks by total profit
1. Trophy (£118,035)
2. Big Ice (£32,853)
3. Hero (£32,757)
- Excluded free promotional items (£0 Purchase Price) to avoid skewing profit calculations
- Profit calculated as: (selling_price - purchase_price) × units_sold

Conclusion: Identified high-value products that drive revenue and should be prioritized in inventory management.
