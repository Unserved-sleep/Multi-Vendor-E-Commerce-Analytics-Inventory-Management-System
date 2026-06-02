--Q1
CREATE OR REPLACE VIEW seller_dashboard_view AS
WITH product_sales AS
         (
             SELECT products.seller_id,products.product_id,products.product_name,
                    SUM(order_items.quantity) AS units_sold
             FROM products
             JOIN order_items
             ON products.product_id=order_items.product_id
             GROUP BY products.seller_id,products.product_id,products.product_name
         )
SELECT seller_profiles.seller_id,
       seller_profiles.business_name,
       SUM(order_items.quantity*order_items.unit_price) AS total_revenue,
       COUNT(DISTINCT orders.order_id) AS order_count,
       ROUND(AVG(ratings.stars),2) AS average_rating,
       (
           SELECT product_sales.product_name
           FROM product_sales
           WHERE product_sales.seller_id=seller_profiles.seller_id
           ORDER BY product_sales.units_sold DESC
           LIMIT 1
       ) AS top_product
FROM seller_profiles
LEFT JOIN products
ON seller_profiles.seller_id=products.seller_id
LEFT JOIN order_items
ON products.product_id=order_items.product_id
LEFT JOIN orders
ON order_items.order_id=orders.order_id
LEFT JOIN ratings
ON products.product_id=ratings.product_id
GROUP BY seller_profiles.seller_id,seller_profiles.business_name;

select * from seller_dashboard_view;


--Q2
CREATE OR REPLACE VIEW monthly_revenue_view AS
WITH monthly_sales AS
         (
             SELECT products.seller_id,
                    DATE_TRUNC('month',orders.order_date) AS month,
                    SUM(order_items.quantity*order_items.unit_price) AS revenue
             FROM products
             JOIN order_items
             ON products.product_id=order_items.product_id
             JOIN orders
             ON order_items.order_id=orders.order_id
             GROUP BY products.seller_id,DATE_TRUNC('month',orders.order_date)
         )
SELECT seller_id, month, revenue,
       ROUND(
               (
                   revenue - LAG(revenue) OVER
                       (
                       PARTITION BY seller_id
                       ORDER BY month
                       )
                   ) *100.0 / NULLIF(
                               LAG(revenue) OVER (
                                   PARTITION BY seller_id
                                   ORDER BY month
                                   ),0
               ),2
       ) AS growth_percentage
FROM monthly_sales;

--Q3
CREATE OR REPLACE VIEW low_stock_view AS
SELECT products.product_name,
       warehouses.location,
       inventory.quantity_available
FROM inventory
JOIN products
ON inventory.product_id=products.product_id
JOIN warehouses
ON inventory.warehouse_id=warehouses.warehouse_id
WHERE inventory.quantity_available<50;

--Q4
CREATE OR REPLACE VIEW customer_order_history_view AS
SELECT users.email, orders.order_id,
       orders.status AS order_status,
       payments.status AS payment_status, returns.return_status
FROM users
JOIN orders
ON users.user_id=orders.customer_id
LEFT JOIN payments
ON orders.order_id=payments.order_id
LEFT JOIN order_items
ON orders.order_id=order_items.order_id
LEFT JOIN returns
ON order_items.order_item_id=returns.order_item_id;

--Q5
CREATE OR REPLACE VIEW abandoned_cart_view AS
SELECT carts.cart_id, users.email,
       COUNT(cart_items.cart_item_id) AS item_count,
       SUM(cart_items.quantity*products.base_price) AS total_cart_value,
       EXTRACT(
               DAY FROM NOW()-carts.expiry_time
       ) AS cart_age_days
FROM carts
JOIN users
ON carts.user_id=users.user_id
JOIN cart_items
ON carts.cart_id=cart_items.cart_id
JOIN products
ON cart_items.product_id=products.product_id
WHERE carts.expiry_time<NOW()-INTERVAL '24 hours'
GROUP BY carts.cart_id,users.email,carts.expiry_time;