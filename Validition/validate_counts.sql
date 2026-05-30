SELECT 'users' AS table_name, COUNT(*) FROM users
UNION ALL
SELECT 'customer_profiles', COUNT(*) FROM customer_profiles
UNION ALL
SELECT 'seller_profiles', COUNT(*) FROM seller_profiles
UNION ALL
SELECT 'addresses', COUNT(*) FROM addresses
UNION ALL
SELECT 'brands', COUNT(*) FROM brands
UNION ALL
SELECT 'categories', COUNT(*) FROM categories
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'product_categories', COUNT(*) FROM product_categories
UNION ALL
SELECT 'product_images', COUNT(*) FROM product_images
UNION ALL
SELECT 'warehouses', COUNT(*) FROM warehouses
UNION ALL
SELECT 'inventory', COUNT(*) FROM inventory
UNION ALL
SELECT 'stock_movements', COUNT(*) FROM stock_movements
UNION ALL
SELECT 'carts', COUNT(*) FROM carts
UNION ALL
SELECT 'cart_items', COUNT(*) FROM cart_items
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'payments', COUNT(*) FROM payments
UNION ALL
SELECT 'payment_transactions', COUNT(*) FROM payment_transactions
UNION ALL
SELECT 'invoices', COUNT(*) FROM invoices
UNION ALL
SELECT 'coupons', COUNT(*) FROM coupons
UNION ALL
SELECT 'coupon_usage', COUNT(*) FROM coupon_usage
UNION ALL
SELECT 'reviews', COUNT(*) FROM reviews
UNION ALL
SELECT 'ratings', COUNT(*) FROM ratings
UNION ALL
SELECT 'returns', COUNT(*) FROM returns
UNION ALL
SELECT 'refunds', COUNT(*) FROM refunds;