-- Check record counts
SELECT COUNT(*) FROM ecommerce_olist.olist_orders;

-- Check for missing customer IDs
SELECT COUNT(*) 
FROM ecommerce_olist.olist_orders 
WHERE customer_id IS NULL;

-- Preview date range
SELECT 
  MIN(order_purchase_timestamp) AS earliest_order, 
  MAX(order_purchase_timestamp) AS latest_order 
FROM ecommerce_olist.olist_orders;

