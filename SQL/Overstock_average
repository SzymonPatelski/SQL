with inventory_average as (
SELECT 
round(avg(total_old_stock),2) AS avg_total_old_stock,
round(avg(sold),2) AS average_sold,
product_id
 FROM inventory_fact
 WHERE sold >= 0
 GROUP BY product_id
)
select 
 drink,
avg_total_old_stock,
average_sold,
round(avg_total_old_stock/average_sold,2) AS avg_stock_excess_ratio
 from inventory_average
  inner join product_dim on inventory_average.product_id = product_dim.product_id
 where avg_total_old_stock > (2 * average_sold)
 order by avg_stock_excess_ratio DESC;
