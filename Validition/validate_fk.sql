--------------------------------------------------
-- FK VALIDATION QUERIES
-- EXPECTED RESULT:
-- ALL SHOULD RETURN 0 ROWS
--------------------------------------------------

--------------------------------------------------
-- customer_profiles → users
--------------------------------------------------

SELECT COUNT(*) AS orphan_customer_profiles
FROM customer_profiles cp
         LEFT JOIN users u
                   ON cp.customer_id=u.user_id
WHERE u.user_id IS NULL;

--------------------------------------------------
-- seller_profiles → users
--------------------------------------------------

SELECT COUNT(*) AS orphan_seller_profiles
FROM seller_profiles sp
         LEFT JOIN users u
                   ON sp.seller_id=u.user_id
WHERE u.user_id IS NULL;

--------------------------------------------------
-- addresses → users
--------------------------------------------------

SELECT COUNT(*) AS orphan_addresses
FROM addresses a
         LEFT JOIN users u
                   ON a.user_id=u.user_id
WHERE u.user_id IS NULL;

--------------------------------------------------
-- products → seller_profiles
--------------------------------------------------

SELECT COUNT(*) AS orphan_products_seller
FROM products p
         LEFT JOIN seller_profiles s
                   ON p.seller_id=s.seller_id
WHERE s.seller_id IS NULL;

--------------------------------------------------
-- products → brands
--------------------------------------------------

SELECT COUNT(*) AS orphan_products_brand
FROM products p
         LEFT JOIN brands b
                   ON p.brand_id=b.brand_id
WHERE b.brand_id IS NULL;

--------------------------------------------------
-- product_categories → products
--------------------------------------------------

SELECT COUNT(*) AS orphan_product_categories_product
FROM product_categories pc
         LEFT JOIN products p
                   ON pc.product_id=p.product_id
WHERE p.product_id IS NULL;

--------------------------------------------------
-- product_categories → categories
--------------------------------------------------

SELECT COUNT(*) AS orphan_product_categories_category
FROM product_categories pc
         LEFT JOIN categories c
                   ON pc.category_id=c.category_id
WHERE c.category_id IS NULL;

--------------------------------------------------
-- product_images → products
--------------------------------------------------

SELECT COUNT(*) AS orphan_product_images
FROM product_images pi
         LEFT JOIN products p
                   ON pi.product_id=p.product_id
WHERE p.product_id IS NULL;

--------------------------------------------------
-- inventory → products
--------------------------------------------------

SELECT COUNT(*) AS orphan_inventory_product
FROM inventory i
         LEFT JOIN products p
                   ON i.product_id=p.product_id
WHERE p.product_id IS NULL;

--------------------------------------------------
-- inventory → warehouses
--------------------------------------------------

SELECT COUNT(*) AS orphan_inventory_warehouse
FROM inventory i
         LEFT JOIN warehouses w
                   ON i.warehouse_id=w.warehouse_id
WHERE w.warehouse_id IS NULL;

--------------------------------------------------
-- stock_movements → products
--------------------------------------------------

SELECT COUNT(*) AS orphan_stock_product
FROM stock_movements sm
         LEFT JOIN products p
                   ON sm.product_id=p.product_id
WHERE p.product_id IS NULL;

--------------------------------------------------
-- stock_movements → warehouses
--------------------------------------------------

SELECT COUNT(*) AS orphan_stock_warehouse
FROM stock_movements sm
         LEFT JOIN warehouses w
                   ON sm.warehouse_id=w.warehouse_id
WHERE w.warehouse_id IS NULL;

--------------------------------------------------
-- carts → users
--------------------------------------------------

SELECT COUNT(*) AS orphan_carts
FROM carts c
         LEFT JOIN users u
                   ON c.user_id=u.user_id
WHERE u.user_id IS NULL;

--------------------------------------------------
-- cart_items → carts
--------------------------------------------------

SELECT COUNT(*) AS orphan_cart_items_cart
FROM cart_items ci
         LEFT JOIN carts c
                   ON ci.cart_id=c.cart_id
WHERE c.cart_id IS NULL;

--------------------------------------------------
-- cart_items → products
--------------------------------------------------

SELECT COUNT(*) AS orphan_cart_items_product
FROM cart_items ci
         LEFT JOIN products p
                   ON ci.product_id=p.product_id
WHERE p.product_id IS NULL;

--------------------------------------------------
-- orders → users
--------------------------------------------------

SELECT COUNT(*) AS orphan_orders
FROM orders o
         LEFT JOIN users u
                   ON o.customer_id=u.user_id
WHERE u.user_id IS NULL;

--------------------------------------------------
-- order_items → orders
--------------------------------------------------

SELECT COUNT(*) AS orphan_order_items_order
FROM order_items oi
         LEFT JOIN orders o
                   ON oi.order_id=o.order_id
WHERE o.order_id IS NULL;

--------------------------------------------------
-- order_items → products
--------------------------------------------------

SELECT COUNT(*) AS orphan_order_items_product
FROM order_items oi
         LEFT JOIN products p
                   ON oi.product_id=p.product_id
WHERE p.product_id IS NULL;

--------------------------------------------------
-- payments → orders
--------------------------------------------------

SELECT COUNT(*) AS orphan_payments
FROM payments p
         LEFT JOIN orders o
                   ON p.order_id=o.order_id
WHERE o.order_id IS NULL;

--------------------------------------------------
-- payment_transactions → payments
--------------------------------------------------

SELECT COUNT(*) AS orphan_payment_transactions
FROM payment_transactions pt
         LEFT JOIN payments p
                   ON pt.payment_id=p.payment_id
WHERE p.payment_id IS NULL;

--------------------------------------------------
-- invoices → orders
--------------------------------------------------

SELECT COUNT(*) AS orphan_invoices
FROM invoices i
         LEFT JOIN orders o
                   ON i.order_id=o.order_id
WHERE o.order_id IS NULL;

--------------------------------------------------
-- coupon_usage → coupons
--------------------------------------------------

SELECT COUNT(*) AS orphan_coupon_usage_coupon
FROM coupon_usage cu
         LEFT JOIN coupons c
                   ON cu.coupon_id=c.coupon_id
WHERE c.coupon_id IS NULL;

--------------------------------------------------
-- coupon_usage → users
--------------------------------------------------

SELECT COUNT(*) AS orphan_coupon_usage_user
FROM coupon_usage cu
         LEFT JOIN users u
                   ON cu.customer_id=u.user_id
WHERE u.user_id IS NULL;

--------------------------------------------------
-- reviews → products
--------------------------------------------------

SELECT COUNT(*) AS orphan_reviews_product
FROM reviews r
         LEFT JOIN products p
                   ON r.product_id=p.product_id
WHERE p.product_id IS NULL;

--------------------------------------------------
-- reviews → users
--------------------------------------------------

SELECT COUNT(*) AS orphan_reviews_user
FROM reviews r
         LEFT JOIN users u
                   ON r.customer_id=u.user_id
WHERE u.user_id IS NULL;

--------------------------------------------------
-- ratings → products
--------------------------------------------------

SELECT COUNT(*) AS orphan_ratings_product
FROM ratings r
         LEFT JOIN products p
                   ON r.product_id=p.product_id
WHERE p.product_id IS NULL;

--------------------------------------------------
-- ratings → users
--------------------------------------------------

SELECT COUNT(*) AS orphan_ratings_user
FROM ratings r
         LEFT JOIN users u
                   ON r.customer_id=u.user_id
WHERE u.user_id IS NULL;

--------------------------------------------------
-- returns → order_items
--------------------------------------------------

SELECT COUNT(*) AS orphan_returns
FROM returns r
         LEFT JOIN order_items oi
                   ON r.order_item_id=oi.order_item_id
WHERE oi.order_item_id IS NULL;

--------------------------------------------------
-- refunds → returns
--------------------------------------------------

SELECT COUNT(*) AS orphan_refunds
FROM refunds r
         LEFT JOIN returns rt
                   ON r.return_id=rt.return_id
WHERE rt.return_id IS NULL;