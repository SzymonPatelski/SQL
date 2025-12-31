SELECT product_dim.drink,
selling_price - purchase_price AS profit_margin,
sum (inventory_fact.sold * (selling_price - purchase_price)) AS total_profit
FROM product_dim 
INNER JOIN inventory_fact ON product_dim.product_id = inventory_fact.product_id
WHERE purchase_price > 0 AND sold >= 0  -- Exclude promotional items and invalid sales data
group by product_dim.drink, profit_margin
order by total_profit DESC
