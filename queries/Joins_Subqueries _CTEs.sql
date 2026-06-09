--Q1
SELECT products.product_name,brands.brand_name,seller_profiles.business_name,categories.category_name
FROM products
JOIN brands
ON products.brand_id=brands.brand_id
JOIN seller_profiles
ON products.seller_id=seller_profiles.seller_id
JOIN product_categories
ON products.product_id=product_categories.product_id
 JOIN categories
ON product_categories.category_id=categories.category_id;

--Q2
SELECT users.user_id,users.email
FROM users
LEFT JOIN orders
ON users.user_id=orders.customer_id
WHERE users.role='customer'
AND orders.order_id IS NULL;

--Q3
SELECT seller_profiles.seller_id,seller_profiles.business_name,COUNT(products.product_id) AS total_products
FROM seller_profiles
LEFT JOIN products
ON seller_profiles.seller_id=products.seller_id
GROUP BY seller_profiles.seller_id,seller_profiles.business_name
ORDER BY total_products DESC;

--Q4
SELECT orders.order_id,users.email,products.product_name,order_items.quantity,orders.total_amount
FROM orders
JOIN users
ON orders.customer_id=users.user_id
JOIN order_items
ON orders.order_id=order_items.order_id
JOIN products
ON order_items.product_id=products.product_id;

--Q5
SELECT products.product_id,products.product_name
FROM products
WHERE EXISTS
    (
        SELECT 1
        FROM order_items
        WHERE order_items.product_id=products.product_id
    );

--Q6
SELECT products.product_id,products.product_name
FROM products
WHERE NOT EXISTS
    (
        SELECT 1
        FROM order_items
        WHERE order_items.product_id=products.product_id
    );

--Q7
SELECT products.product_id,products.product_name,products.base_price
FROM products
JOIN product_categories
ON products.product_id=product_categories.product_id
WHERE products.base_price >
      (
          SELECT AVG(products.base_price)
          FROM products
          JOIN product_categories
          ON products.product_id=product_categories.product_id
          WHERE product_categories.category_id=
                (
                    SELECT product_categories.category_id
                    FROM product_categories
                    WHERE product_categories.product_id=products.product_id
                    LIMIT 1
                )
      );

--Q8
SELECT seller_id,product_name,base_price
FROM(
    SELECT products.seller_id,products.product_name,products.base_price,
    ROW_NUMBER()
    OVER (
         PARTITION BY products.seller_id
         ORDER BY products.base_price DESC
         )
         AS price_rank
    FROM products
    ) as p
WHERE price_rank<=3;

--Q9
SELECT orders.customer_id
FROM orders
WHERE orders.order_date >= CURRENT_DATE - INTERVAL '6 months'
GROUP BY orders.customer_id
HAVING COUNT
    (
        DISTINCT DATE_TRUNC('month',orders.order_date)
    )=6;

--Q10
SELECT coupons.coupon_id,coupons.coupon_code
FROM coupons
LEFT JOIN coupon_usage
ON coupons.coupon_id=coupon_usage.coupon_id
WHERE coupon_usage.usage_id IS NULL;


--Q11
SELECT seller_profiles.seller_id,seller_profiles.business_name,products.product_name,SUM(order_items.quantity) AS units_sold
FROM seller_profiles
JOIN products
ON seller_profiles.seller_id=products.seller_id
JOIN order_items
 ON products.product_id=order_items.product_id
GROUP BY seller_profiles.seller_id,seller_profiles.business_name,products.product_name
ORDER BY units_sold DESC;

--Q12
SELECT payments.payment_id,payments.order_id,payments.method,payments.status
FROM payments
WHERE payments.status='failed';

--Q13
SELECT products.product_id,products.product_name,ROUND(AVG(ratings.stars),2) AS avg_rating,COUNT(reviews.review_id) AS total_reviews
FROM products
LEFT JOIN ratings
ON products.product_id=ratings.product_id
LEFT JOIN reviews
ON products.product_id=reviews.product_id
GROUP BY products.product_id,products.product_name
ORDER BY avg_rating DESC;

--Q14
WITH seller_revenue AS
    (
        SELECT products.seller_id,SUM(order_items.quantity*order_items.unit_price) AS revenue
        FROM products
        JOIN order_items
         ON products.product_id=order_items.product_id
        GROUP BY products.seller_id
    )
SELECT seller_revenue.seller_id,seller_profiles.business_name,seller_revenue.revenue
FROM seller_revenue
JOIN seller_profiles
ON seller_revenue.seller_id=seller_profiles.seller_id
WHERE seller_revenue.revenue >
      (
          SELECT AVG(revenue)
          FROM seller_revenue
      );

--Q15
SELECT orders.customer_id,users.email,COUNT(orders.order_id) AS completed_orders
FROM orders
JOIN users
ON orders.customer_id=users.user_id
WHERE orders.status='delivered'
GROUP BY orders.customer_id,users.email
HAVING COUNT(orders.order_id)>5
ORDER BY completed_orders DESC;


--Q16
WITH RECURSIVE category_tree AS
            (
                SELECT category_id,category_name,parent_category_id
                FROM categories
                WHERE parent_category_id IS NULL
                UNION ALL
                SELECT categories.category_id,categories.category_name,categories.parent_category_id
                FROM categories
                JOIN category_tree
                ON categories.parent_category_id=category_tree.category_id
            )
SELECT * FROM category_tree;

--Q17
SELECT returns.return_id,orders.order_id,returns.reason_code,refunds.amount
FROM returns
JOIN order_items
ON returns.order_item_id=order_items.order_item_id
JOIN orders
ON order_items.order_id=orders.order_id
 LEFT JOIN refunds
ON returns.return_id=refunds.return_id;

--Q18
SELECT DISTINCT seller_profiles.seller_id,seller_profiles.business_name
FROM seller_profiles
JOIN products
ON seller_profiles.seller_id=products.seller_id
 JOIN ratings
 ON products.product_id=ratings.product_id
WHERE ratings.stars=1;

--Q19
SELECT seller_profiles.seller_id,seller_profiles.business_name,COUNT(DISTINCT orders.customer_id) AS unique_customers,
RANK() OVER(
            ORDER BY COUNT(DISTINCT orders.customer_id) DESC
           ) AS seller_rank
FROM seller_profiles
JOIN products
ON seller_profiles.seller_id=products.seller_id
JOIN order_items
ON products.product_id=order_items.product_id
JOIN orders
ON order_items.order_id=orders.order_id
GROUP BY seller_profiles.seller_id,seller_profiles.business_name;

--Q20
SELECT carts.cart_id,carts.user_id,cart_items.product_id,cart_items.quantity
FROM carts
 JOIN cart_items
ON carts.cart_id=cart_items.cart_id
WHERE NOT EXISTS
    (
        SELECT 1
        FROM orders
        WHERE orders.customer_id=carts.user_id
    );