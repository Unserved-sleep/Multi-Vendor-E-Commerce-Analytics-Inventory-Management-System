--Q1
CREATE OR REPLACE PROCEDURE place_order
(
    IN p_customer_id BIGINT,
    IN p_cart_id BIGINT
)
    LANGUAGE plpgsql
AS $$
DECLARE v_order_id BIGINT;
    DECLARE v_total DECIMAL(10,2);
BEGIN

    SELECT SUM(cart_items.quantity*products.base_price)
    INTO v_total
    FROM cart_items
             JOIN products
                  ON cart_items.product_id=products.product_id
    WHERE cart_items.cart_id=p_cart_id;

    INSERT INTO orders
    (
        customer_id,
        status,
        order_date,
        total_amount
    )
    VALUES
        (
            p_customer_id,
            'confirmed',
            NOW(),
            v_total
        )
    RETURNING order_id
        INTO v_order_id;

    INSERT INTO order_items
    (
        order_id,
        product_id,
        quantity,
        unit_price
    )
    SELECT
        v_order_id,
        cart_items.product_id,
        cart_items.quantity,
        products.base_price
    FROM cart_items
             JOIN products
                  ON cart_items.product_id=products.product_id
    WHERE cart_items.cart_id=p_cart_id;

    INSERT INTO payments
    (
        order_id,
        method,
        status,
        gateway_reference
    )
    VALUES
        (
            v_order_id,
            'card',
            'success',
            gen_random_uuid()
        );

    COMMIT;

EXCEPTION
    WHEN OTHERS
        THEN
            ROLLBACK;
            RAISE;

END;
$$;

--Q2
CREATE OR REPLACE PROCEDURE update_locked_inventory
(
    IN p_product_id BIGINT,
    IN p_warehouse_id BIGINT,
    IN p_quantity INT
)
    LANGUAGE plpgsql
AS $$
DECLARE v_stock INT;
BEGIN

    SELECT quantity_available
    INTO v_stock
    FROM inventory
    WHERE inventory.product_id=p_product_id
      AND inventory.warehouse_id=p_warehouse_id
        FOR UPDATE;

    IF v_stock<p_quantity THEN
        RAISE EXCEPTION 'Insufficient stock';
    END IF;

    UPDATE inventory
    SET quantity_available=quantity_available-p_quantity
    WHERE inventory.product_id=p_product_id
      AND inventory.warehouse_id=p_warehouse_id;

END;
$$;

--Q3
CREATE OR REPLACE PROCEDURE cancel_order
(
    IN p_order_id BIGINT
)
    LANGUAGE plpgsql
AS $$
DECLARE v_time TIMESTAMP;
BEGIN

    SELECT order_date
    INTO v_time
    FROM orders
    WHERE orders.order_id=p_order_id;

    IF NOW()-v_time>INTERVAL '24 hours' THEN
        RAISE EXCEPTION 'Cancellation window expired';
    END IF;

    UPDATE orders
    SET status='cancelled'
    WHERE orders.order_id=p_order_id;

END;
$$;

--Q4
CREATE OR REPLACE PROCEDURE refund_payment
(
    IN p_payment_id BIGINT,
    IN p_amount DECIMAL
)
    LANGUAGE plpgsql
AS $$
DECLARE v_original_amount DECIMAL;
BEGIN

    SELECT orders.total_amount
    INTO v_original_amount
    FROM payments
             JOIN orders
                  ON payments.order_id=orders.order_id
    WHERE payments.payment_id=p_payment_id;

    IF p_amount>v_original_amount THEN
        RAISE EXCEPTION 'Refund exceeds original payment';
    END IF;

    UPDATE payments
    SET status='refunded'
    WHERE payments.payment_id=p_payment_id;

END;
$$;

--Q5
CREATE OR REPLACE PROCEDURE update_inventory
(
    IN p_product_id BIGINT,
    IN p_warehouse_id BIGINT,
    IN p_quantity_change INT
)
    LANGUAGE plpgsql
AS $$
DECLARE v_new_quantity INT;
BEGIN

    UPDATE inventory
    SET quantity_available=quantity_available+p_quantity_change
    WHERE inventory.product_id=p_product_id
      AND inventory.warehouse_id=p_warehouse_id
    RETURNING quantity_available
        INTO v_new_quantity;

    IF v_new_quantity<0 THEN
        RAISE EXCEPTION 'Negative inventory not allowed';
    END IF;

    INSERT INTO stock_movements
    (
        product_id,
        warehouse_id,
        movement_type,
        quantity,
        movement_timestamp
    )
    VALUES
        (
            p_product_id,
            p_warehouse_id,
            'stock_out',
            ABS(p_quantity_change),
            NOW()
        );

END;
$$;