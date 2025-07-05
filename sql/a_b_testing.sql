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

 -- Preview AOV by Group
SELECT
  p.payment_type,
  COUNT(DISTINCT o.order_id) AS total_orders,
  ROUND(SUM(p.payment_value), 2) AS total_revenue,
  ROUND(SUM(p.payment_value) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM ecommerce_olist.vw_clean_order_payments p
JOIN ecommerce_olist.vw_clean_orders o 
  ON p.order_id = o.order_id
GROUP BY p.payment_type
ORDER BY avg_order_value DESC;

-- Preview AOV by Delivery Status
SELECT
  p.payment_type,
  COUNT(DISTINCT o.order_id) AS orders,
  ROUND(SUM(p.payment_value), 2) AS revenue,
  ROUND(SUM(p.payment_value) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value,
  ROUND(COUNTIF(o.order_delivered_customer_date IS NOT NULL) / COUNT(*) * 100, 2) AS pct_delivered
FROM ecommerce_olist.vw_clean_order_payments p
JOIN ecommerce_olist.vw_clean_orders o 
  ON p.order_id = o.order_id
GROUP BY p.payment_type
ORDER BY avg_order_value DESC;
