
with daily_sales as(
    SELECT
    sum(sold) AS total_sold,
    recorded_date
    from inventory_fact
    GROUP BY recorded_date
)
SELECT 
    TO_CHAR(inventory_fact.recorded_date, 'day') AS day_of_week,
    ROUND(avg(daily_sales.total_sold), 2) AS avg_sales,
    SUM(sold) AS total_sales
from inventory_fact
INNER JOIN daily_sales on inventory_fact.recorded_date = daily_sales.recorded_date
WHERE sold >= 0 
GROUP BY day_of_week
ORDER BY 
avg_sales DESC;
