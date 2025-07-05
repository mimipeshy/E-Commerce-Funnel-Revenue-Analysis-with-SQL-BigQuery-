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

-- Calculate Conversion Rates Between Funnel Stages
WITH funnel_counts AS (
  SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT IF(order_approved_at IS NOT NULL, order_id, NULL)) AS approved_orders,
    COUNT(DISTINCT IF(order_delivered_carrier_date IS NOT NULL, order_id, NULL)) AS shipped_orders,
    COUNT(DISTINCT IF(order_delivered_customer_date IS NOT NULL, order_id, NULL)) AS delivered_orders
  FROM ecommerce_olist.vw_funnel_data
)

SELECT 
  total_orders,
  approved_orders,
  ROUND(approved_orders / total_orders * 100, 2) AS pct_approved,
  shipped_orders,
  ROUND(shipped_orders / approved_orders * 100, 2) AS pct_shipped,
  delivered_orders,
  ROUND(delivered_orders / shipped_orders * 100, 2) AS pct_delivered
FROM funnel_counts;

 -- calculate drop off analysis by group
SELECT 
  p.product_category_name,
  COUNT(DISTINCT f.order_id) AS total_orders,
  COUNT(DISTINCT IF(f.order_delivered_customer_date IS NOT NULL, f.order_id, NULL)) AS delivered_orders,
  ROUND(COUNT(DISTINCT IF(f.order_delivered_customer_date IS NOT NULL, f.order_id, NULL)) / COUNT(DISTINCT f.order_id) * 100, 2) AS delivery_rate
FROM ecommerce_olist.vw_funnel_data f
JOIN ecommerce_olist.olist_order_items i ON f.order_id = i.order_id
JOIN ecommerce_olist.olist_products p ON i.product_id = p.product_id
GROUP BY product_category_name
ORDER BY delivery_rate ASC
LIMIT 10;

-- calculate avg time to approve , ship and deliver
SELECT
  ROUND(AVG(DATE_DIFF(order_approved_at, order_purchase_timestamp, DAY)), 2) AS avg_days_to_approve,
  ROUND(AVG(DATE_DIFF(order_delivered_carrier_date, order_approved_at, DAY)), 2) AS avg_days_to_ship,
  ROUND(AVG(DATE_DIFF(order_delivered_customer_date, order_delivered_carrier_date, DAY)), 2) AS avg_days_to_deliver
FROM ecommerce_olist.vw_funnel_data
WHERE 
  order_approved_at IS NOT NULL AND 
  order_delivered_carrier_date IS NOT NULL AND 
  order_delivered_customer_date IS NOT NULL;

