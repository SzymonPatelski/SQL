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
