
CREATE TABLE product_dim (
  product_id INTEGER PRIMARY KEY,
  drink TEXT,
  purchase_price NUMERIC(10,2),
  selling_price NUMERIC(10,2)
);
CREATE TABLE inventory_fact (
  date DATE,
  product_id INTEGER,
  old_stock INTEGER,
  supply INTEGER,
  total_old_stock INTEGER,
  sold INTEGER,
  new_stock INTEGER,
  FOREIGN KEY (product_id) REFERENCES product_dim(product_id)
);
-- Create product_dim and inventory_fact tables
--inventory_fact has a foreign key referencing product_dim in order to avoid data redundancy and maintain referential integrity between the two tables.

SET datestyle = DMY; 
-- Ran into issue where dates were being misinterpreted. 
-- During CSV import, PostgreSQL misread dates like 24/02/2024 as invalid. I resolved this by setting DateStyle = DMY so that all dates in DD/MM/YYYY format were imported correctly

\copy product_dim FROM './data/product_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', NULL '');
\copy inventory_fact FROM './data/inventory_fact.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', NULL '');
-- The \copy command is a psql meta-command that allows you to import data from a CSV file into a specified table.
--loaded both tables
