# Key Results

Trophy: 24% of sales and profit → core product; maintain stock and pricing

Malt: High volume, low margin → price increase to £5 could boost profitability by ~215% per unit

Star: Greatly overstocked relative to low sales → reduce stock to free capacity

Flying Fish: Near-zero sales → consider temporary removal or minimal stocking

Sales timing: Sunday is peak → adjust staffing, stock, and promotions accordingly

# Project Overview

This project analyses drinks sales, profitability, and inventory to uncover key business insights. Using SQL for data extraction, Excel for data cleaning and preparation, and Tableau for visualisation, it identifies high-profit products, pricing optimisation opportunities, inventory inefficiencies, and day-of-week sales trends, providing actionable recommendations for operations and strategy.

# Business Questions

This analysis addresses the following key business questions:

Which drinks generate the highest total profit?
Identify products that are the biggest contributors to overall profitability to prioritise stock and pricing strategy.

Which drinks have high sales volume but low profit margins?
Determine popular products that underperform in profit per unit to uncover opportunities for pricing optimisation.

Which drinks are over-supplied relative to sales?
Highlight inventory inefficiencies where stock levels exceed demand, enabling better allocation and reduced waste.

How does the day of the week affect sales?
Analyse temporal sales patterns to inform staffing, stock replenishment, and promotional planning.

Which low-activity products might be removed or reprioritised?
Identify drinks with negligible sales that tie up stock or operational resources, to support menu rationalisation or clearance decisions.

# Data Cleaning & Preparation

Issue 1: Inconsistent Product Naming
- Problem: Same products had multiple variations due to:

  - Capitalization differences (e.g., "STAR" vs "Star")
  - Abbreviations vs full names (e.g., "G/Black" vs "Goldberg/Black")
  - Misspellings and naming inconsistencies
  - Duplicate entries for free promotional items with different product_ids

- Solution: Standardized all product names in Excel to consistent title case, full names, and merged duplicate records

- Impact: Prevented artificial data splitting across identical products, ensuring accurate sales and profit calculations

Issue 2: Negative Sales Value
- Problem: One record showed -1 units sold for Star beer

- Investigation: Contacted stakeholders - Was told its unclear, said possibly refund. Contacted again saying there was no sold the day before, where they then said might have been refund for same price item. Asked to exclude the single instance.

- Solution: - Excluded records with negative sales from analysis using `WHERE sold >= 0` as these represent possibly false data

- Impact: Ensures sales trends reflect actual purchasing behavior rather than accounting mistakes

- Recommendation: Suggested system improvement to track refunds separately from sales for clearer reporting

# Data Loading & Configuration

Data Quality Check:

Issue: Trailing blank rows in CSV files cause PostgreSQL import failures

ERROR: null value in column "product_id" violates not-null constraint
DETAIL: Failing row contains (null, null, null, null).

Solution: Remove malformed rows before import

sed -i '' '/^[,[:space:]]*$/d' './data/product_dim.csv'
sed -i '' '/^[,[:space:]]*$/d' './data/inventory_fact.csv'

Date Format Handling

Issue: CSV contains dates in DD/MM/YYYY format (UK standard), but PostgreSQL defaults to MDY (US format).

Solution: Configure session to match source data format

-- Set date format to match UK date convention in CSV
SET datestyle = DMY;

-- Loaded data

# SQL Analysis

**QUESTION 1. Which drinks generate the highest total profit?**

Query:
```sql
SELECT product_dim.drink,
selling_price - purchase_price AS profit_margin,
sum (inventory_fact.sold * (selling_price - purchase_price)) AS total_profit
FROM product_dim 
INNER JOIN inventory_fact ON product_dim.product_id = inventory_fact.product_id
WHERE purchase_price > 0 AND sold >= 0  -- Exclude promotional items and invalid sales data
group by product_dim.drink, profit_margin
order by total_profit DESC
```

Key Insights:
- Top 3 drinks by total profit
1. Trophy (£118,035)
2. Big Ice (£32,853)
3. Hero (£32,757)
- Excluded free promotional items (£0 Purchase Price) to avoid skewing profit calculations
- Profit calculated as: (selling_price - purchase_price) × units_sold


**QUESTION 2. Which drinks have high sales volume but low profit margins?**

Query:
```sql
with low_margin_drinks AS (
SELECT 
(((selling_price/purchase_price)*100)-100) AS profit_margin,
drink,
product_id
from product_dim
where purchase_price > 0 -- excluding promotional item
and (((selling_price/purchase_price)*100)-100) < 30
order by profit_margin DESC)

SELECT 
sum(sold) AS total_sold,
drink,
low_margin_drinks.profit_margin
from inventory_fact
INNER JOIN low_margin_drinks ON inventory_fact.product_id = low_margin_drinks.product_id
where sold >= 0  -- Exclude invalid sales data
group by low_margin_drinks.profit_margin, low_margin_drinks.drink
order BY total_sold DESC
```

Key Insight:
- 'Malt' is the clear winner with 449 units sold but only 20% profit margin

**QUESTION 3. Where is stock being over-supplied relative to sales?**

Query:
```sql
with inventory_average as (
SELECT 
round(avg(total_old_stock),2) AS avg_total_old_stock,
round(avg(sold),2) AS average_sold,
product_id
 FROM inventory_fact
 WHERE sold >= 0
 GROUP BY product_id
)
SELECT 
 drink,
avg_total_old_stock,
average_sold,
round(avg_total_old_stock/average_sold,2) AS avg_stock_excess_ratio
 from inventory_average
  inner join product_dim on inventory_average.product_id = product_dim.product_id
 where avg_total_old_stock > (2 * average_sold)
 order by avg_stock_excess_ratio DESC;
```

Key Insights:
- Flying Fish has highest ratio (4 stock ÷ 0.07 daily sales) but low inventory, meaning it isnt high impact, could be rare use case
- Star is the biggest concern: 10 units average stock with only 0.45 daily sales. Thats an average of 22 days of inventory

**Question 4. How does the day of the week effect sales?**

Query:
```sql
WITH daily_sales AS (
    SELECT
        recorded_date,
        SUM(sold) AS total_sold
    FROM inventory_fact
    GROUP BY recorded_date
)
SELECT 
    TO_CHAR(inventory_fact.recorded_date, 'Day') AS day_of_week,
    ROUND(AVG(daily_sales.total_sold), 2) AS avg_sales,
    SUM(sold) AS total_sales
FROM inventory_fact
INNER JOIN daily_sales ON inventory_fact.recorded_date = daily_sales.recorded_date
WHERE sold >= 0 
GROUP BY day_of_week
ORDER BY avg_sales DESC;
```

Key Insight:
- Sunday is the clear winner with 110 average sales - nearly double second place (62 avg sales)

# TABLEU CREATION

This Tableau dashboard visualises sales, profit, and inventory data for a drinks business. The dashboard is designed to help identify high-performing products, inefficiencies in pricing and inventory allocation, and temporal sales patterns that can inform purchasing and staffing decisions.

**Highest total profit contributors**

VISUALISATION:

A ranked horizontal bar chart was used to display total profit by drink, sorted in descending order. This format allows the most profitable products to be identified immediately and makes relative differences between drinks clear.

INSIGHT:

Trophy beer is the leading profit contributor, accounting for 24% of total sales volume and 24% of total profit (excluding free items). This indicates that Trophy’s profitability is proportional to its popularity, showing neither margin dilution nor over-reliance on price discounting.

BUSINESS IMPLICATION :

Trophy beer is a core product, driving both sales and profit in equal proportion

Maintaining consistent availability is critical, as understocking would have a direct and material impact on overall profitability

Trophy should be protected from heavy discounting, as its current pricing already delivers efficient profit conversion

The product is well-suited for bundling or cross-selling rather than price-led promotions

**High Sales,Low Profit Margin**

VISUALISATION:
A bar chart was used to compare sales volume and profit margin by drink, making it easy to identify products with strong demand but weak profitability. This format supports clear, side-by-side comparison across the full product range.

INSIGHT:

Malt is a high-volume product with structurally weak profitability. Despite strong demand, averaging 10 sales per day (449 units in the period), its low selling price relative to cost results in a thin margin, limiting its contribution to total profit. Unlike Trophy, Malt’s share of sales is not matched by an equivalent share of profit, indicating a clear pricing inefficiency rather than a demand issue.

BUSINESS IMPLICATION:

Malt currently sells at £4 with a unit cost of £3.33, generating £0.67 profit per drink at an average volume of 10 drinks per day

Increasing the price to £5 raises per-unit profit to £1.67, a 149% increase, improving daily profit.

Even with a 60% drop in sales volume, the £5 price point would still match current profit levels, indicating low downside risk

The £5 price fills an existing pricing gap in the drinks range and leverages Malt’s strong demand

This makes Malt a strong candidate for a controlled pricing test, with post-change sales closely monitored for demand sensitivity


**Which stick is oversuplied in compared to sales**

VISUALISATION:

A bar chart compares average stock levels against average daily sales by drink. Flying Fish was excluded from the visualisation as it is an extreme outlier driven by very low sales volume and minimal stock levels, which compressed the scale and reduced readability for the remaining products.

INSIGHT:

After excluding extreme low-activity items, Star emerges as the most over-supplied drink, holding an average stock of 10.12 units while selling only 0.42 drinks per day. This indicates sustained overstocking relative to demand rather than short-term fluctuation.

BUSINESS IMPACT:

Reduce stock levels for Star, as current inventory significantly exceeds its sales velocity

Reallocate excess inventory capacity to higher-performing drinks such as Trophy, which has the biggest demand

Review low-activity products separately from core items to prevent outliers from obscuring operational issues

Track stock-to-sales ratios regularly to identify slow-moving items before overstocking occurs
  
ADDITIONAL RECCOMENDATION:

Flying Fish shows consistently negligible demand, averaging 0.07 sales per day, indicating it is effectively inactive on the menu

Consider temporarily removing or de-prioritising Flying Fish to reduce inventory complexity and free storage capacity

If removed, monitor overall sales and customer feedback to confirm there is no negative impact on demand or customer satisfaction

Reallocate shelf space and purchasing focus toward higher-performing drinks

**Average Sales by day of week**

VISUALISATION:

A Coloured bar chart was used to display total sales by day of the week, allowing clear comparison of sales volume across trading days. This allows for immediate noticing of weekly patterns.

INSIGHT
Sales peak on Sundays, reaching nearly twice the volume of most other days, indicating a strong end-of-week demand pattern.

CONCLUSION
Schedule higher staffing levels on Sundays, as sales volume is nearly double that of other days

Prioritise stock availability of high-margin drinks ahead of Sunday to avoid lost profit on the peak trading day

Use targeted Sunday promotions to maximise revenue during the highest-demand period rather than discounting slower days

Sunday represents the most commercially critical trading day, where operational decisions have an outsized impact on weekly performance

# Conclusion

This project demonstrates an end-to-end analytical workflow, combining SQL for data extraction, Excel for data cleaning, and Tableau for interactive visualisation to generate actionable business insights. By examining sales, profitability, inventory, and temporal trends, the analysis provides clear recommendations for operational and strategic decisions.

Key takeaways include:

Core profit drivers: Trophy beer accounts for 24% of both sales and profit, making it a stable, high-priority product. Maintaining stock and protecting pricing is essential.

High-volume, low-margin products: Malt is popular but underperforms in profitability. A controlled price increase to £5 could significantly improve per-unit and total profit with minimal downside.

Inventory inefficiencies: Star is overstocked relative to its low sales, tying up capital unnecessarily. Low-activity products like Flying Fish could be temporarily removed or deprioritised to free capacity.

Operational timing: Sales peak on Sundays, nearly doubling other days. Staffing, stock allocation, and promotions should be adjusted accordingly to maximise revenue.

Overall, these insights demonstrate how data can drive smarter pricing, inventory management, and operational planning, turning raw sales data into practical business decisions.