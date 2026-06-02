--Q1
SELECT product_categories.category_id,products.product_id,products.product_name,SUM(order_items.quantity*order_items.unit_price) AS revenue,
RANK() OVER
           (
           PARTITION BY product_categories.category_id
           ORDER BY SUM(order_items.quantity*order_items.unit_price) DESC
           )                                                                                                                            AS revenue_rank
FROM products
JOIN product_categories
ON products.product_id=product_categories.product_id
JOIN order_items
ON products.product_id=order_items.product_id
GROUP BY product_categories.category_id,products.product_id,products.product_name;

--Q2
SELECT *
FROM(
    SELECT product_categories.category_id,products.product_id,products.product_name,SUM(order_items.quantity) AS units_sold,
    RANK() OVER
            (
            PARTITION BY product_categories.category_id
            ORDER BY SUM(order_items.quantity) DESC
            )                                                                                                     AS sales_rank
    FROM products
    JOIN product_categories
    ON products.product_id=product_categories.product_id
    JOIN order_items
    ON products.product_id=order_items.product_id
    GROUP BY product_categories.category_id,products.product_id,products.product_name
    ) as ppcoi
WHERE sales_rank<=5;

--Q3
SELECT orders.order_id,orders.customer_id,orders.order_date,
ROW_NUMBER() OVER
        (
        PARTITION BY orders.customer_id
        ORDER BY orders.order_date
        ) AS purchase_sequence
FROM orders;

--Q4
SELECT products.seller_id,DATE_TRUNC('month',orders.order_date) AS month,
       SUM(order_items.quantity*order_items.unit_price) AS monthly_revenue,
       SUM(SUM(order_items.quantity*order_items.unit_price))
       OVER(
           PARTITION BY products.seller_id
           ORDER BY DATE_TRUNC('month',orders.order_date)
            )  AS running_total_revenue
FROM products
JOIN order_items
 ON products.product_id=order_items.product_id
JOIN orders
ON order_items.order_id=orders.order_id
GROUP BY products.seller_id,DATE_TRUNC('month',orders.order_date);

--Q5
SELECT products.seller_id,DATE_TRUNC('month',orders.order_date) AS month,
       SUM(order_items.quantity*order_items.unit_price) AS monthly_revenue,
       LAG(
       SUM(order_items.quantity*order_items.unit_price)
        )
       OVER(
           PARTITION BY products.seller_id
           ORDER BY DATE_TRUNC('month',orders.order_date)
       ) AS previous_month_revenue
FROM products
JOIN order_items
ON products.product_id=order_items.product_id
JOIN orders
ON order_items.order_id=orders.order_id
GROUP BY products.seller_id,DATE_TRUNC('month',orders.order_date);

--Q6
SELECT products.seller_id,DATE_TRUNC('month',orders.order_date) AS month,
SUM(order_items.quantity*order_items.unit_price) AS monthly_revenue,
ROUND(
         (
         SUM(order_items.quantity*order_items.unit_price) -
         LAG(SUM(order_items.quantity*order_items.unit_price)
         )
         OVER(PARTITION BY products.seller_id
              ORDER BY DATE_TRUNC('month',orders.order_date)
              )
         )*100.0 /NULLIF (
                        LAG(
                         SUM(order_items.quantity*order_items.unit_price)
                        )
                        OVER(
                             PARTITION BY products.seller_id
                             ORDER BY DATE_TRUNC('month',orders.order_date)
                        ),0
            ),2
        ) AS revenue_growth_percentage
FROM products
JOIN order_items
ON products.product_id=order_items.product_id
JOIN orders
ON order_items.order_id=orders.order_id
GROUP BY products.seller_id,DATE_TRUNC('month',orders.order_date);

--Q7
WITH monthly_revenue AS
    (
        SELECT products.seller_id,DATE_TRUNC('month',orders.order_date) AS month,
        SUM(order_items.quantity*order_items.unit_price) AS revenue
        FROM products
        JOIN order_items
        ON products.product_id=order_items.product_id
        JOIN orders
        ON order_items.order_id=orders.order_id
        GROUP BY products.seller_id,DATE_TRUNC('month',orders.order_date)
        )
SELECT * FROM
    (
        SELECT seller_id,month,revenue,LAG(revenue)
               OVER(
                   PARTITION BY seller_id
                   ORDER BY month
                ) AS previous_revenue
        FROM monthly_revenue
    ) as mr
WHERE revenue<previous_revenue;

--Q8
SELECT orders.order_date,orders.total_amount,
AVG(orders.total_amount)
       OVER(
           ORDER BY orders.order_date
           ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
           ) AS rolling_7day_avg
FROM orders;

--Q9
SELECT orders.customer_id,
SUM(orders.total_amount) AS lifetime_spend,
DENSE_RANK() OVER
    (
       ORDER BY SUM(orders.total_amount) DESC
    ) AS customer_rank
FROM orders
GROUP BY orders.customer_id;

--Q10
SELECT products.product_id,products.product_name,
       SUM(order_items.quantity*order_items.unit_price) AS revenue,
       NTILE(4) OVER
           (
           ORDER BY SUM(order_items.quantity*order_items.unit_price) DESC
           ) AS revenue_quartile
FROM products
JOIN order_items
ON products.product_id=order_items.product_id
GROUP BY products.product_id,products.product_name;


--Q11
SELECT orders.customer_id,orders.order_date,
       MIN(orders.order_date)
       OVER
           (
           PARTITION BY orders.customer_id
           )
           AS first_order_date,
       MAX(orders.order_date)
       OVER
           (
           PARTITION BY orders.customer_id
           )
           AS latest_order_date
FROM orders;

--Q12
SELECT order_items.order_item_id,order_items.order_id,order_items.product_id,
       ROUND(
               (
                   order_items.quantity*order_items.unit_price
                   ) *100.0 /
               SUM(order_items.quantity*order_items.unit_price)
               OVER
                   (
                   PARTITION BY order_items.order_id
                   ),2
       ) AS contribution_percentage
FROM order_items;

--Q13
SELECT orders.customer_id,orders.order_id,orders.order_date,
       LEAD(orders.order_date)
       OVER
           (
           PARTITION BY orders.customer_id
           ORDER BY orders.order_date
           )
           AS next_order_date,
       LEAD(orders.order_date)
       OVER
           (
           PARTITION BY orders.customer_id
           ORDER BY orders.order_date
           )
           -
       orders.order_date
           AS days_between_orders
FROM orders;

--Q14
SELECT *
FROM
    (
        SELECT products.seller_id,DATE_TRUNC('month',orders.order_date) AS month,
               SUM(order_items.quantity*order_items.unit_price) AS revenue,
               RANK()
               OVER
                   (
                   PARTITION BY products.seller_id
                   ORDER BY SUM(order_items.quantity*order_items.unit_price) DESC
                   )
                                                                        AS revenue_rank
        FROM products
                 JOIN order_items
                      ON products.product_id=order_items.product_id
                 JOIN orders
                      ON order_items.order_id=orders.order_id
        GROUP BY products.seller_id,DATE_TRUNC('month',orders.order_date)
    ) as poio
WHERE revenue_rank=1;

--Q15
WITH monthly_sales AS
         (
             SELECT products.product_id,DATE_TRUNC('month',orders.order_date) AS month,
                    SUM(order_items.quantity) AS units_sold
             FROM products
                      JOIN order_items
                           ON products.product_id=order_items.product_id
                      JOIN orders
                           ON order_items.order_id=orders.order_id
             GROUP BY products.product_id,DATE_TRUNC('month',orders.order_date)
         )
SELECT *
FROM
    (
        SELECT product_id,month,units_sold,
               LAG(units_sold)
               OVER
                   (
                   PARTITION BY product_id
                   ORDER BY month
                   )
                   AS previous_month_sales
        FROM monthly_sales
    ) as ms
WHERE units_sold>previous_month_sales;

--Q16
SELECT DATE(orders.order_date) AS order_day,
       COUNT(*)
       OVER(
           ORDER BY DATE(orders.order_date)
           ) AS cumulative_orders
FROM orders;

--Q17
SELECT seller_profiles.seller_id,seller_profiles.business_name,
       SUM(order_items.quantity*order_items.unit_price) AS revenue,
       PERCENT_RANK()
       OVER
           (
           ORDER BY SUM(order_items.quantity*order_items.unit_price)
           ) AS revenue_percent_rank
FROM seller_profiles
JOIN products
ON seller_profiles.seller_id=products.seller_id
JOIN order_items
ON products.product_id=order_items.product_id
GROUP BY seller_profiles.seller_id,seller_profiles.business_name;

--Q18
SELECT * FROM
    (
        SELECT product_categories.category_id,seller_profiles.seller_id,seller_profiles.business_name,
        SUM(order_items.quantity*order_items.unit_price) AS revenue,
        DENSE_RANK() OVER
                   (
                   PARTITION BY product_categories.category_id
                   ORDER BY SUM(order_items.quantity*order_items.unit_price) DESC
                   ) AS seller_rank
        FROM seller_profiles
        JOIN products
        ON seller_profiles.seller_id=products.seller_id
        JOIN product_categories
        ON products.product_id=product_categories.product_id
        JOIN order_items
        ON products.product_id=order_items.product_id
        GROUP BY product_categories.category_id,seller_profiles.seller_id,seller_profiles.business_name
    ) as spppcoi
WHERE seller_rank<=3;

--Q19
SELECT orders.customer_id, AVG(orders.total_amount) AS customer_avg_order_value,
       AVG(AVG(orders.total_amount))
       OVER() AS platform_avg_order_value
FROM orders
GROUP BY orders.customer_id;

--Q20
SELECT * FROM
    (
        SELECT cart_items.cart_item_id,cart_items.cart_id,cart_items.product_id,cart_items.quantity,
               ROW_NUMBER() OVER(
                   PARTITION BY cart_items.cart_id,cart_items.product_id
                   ORDER BY cart_items.cart_item_id DESC
                   ) AS duplicate_rank
        FROM cart_items
    ) as ci
WHERE duplicate_rank=1;