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



--Q6
CREATE OR REPLACE PROCEDURE apply_coupon
(
    IN p_coupon_code TEXT,
    IN p_customer_id BIGINT,
    IN p_order_amount DECIMAL
)
    LANGUAGE plpgsql
AS $$
DECLARE v_discount_type TEXT;
    DECLARE v_discount_value DECIMAL;
    DECLARE v_expiry DATE;
    DECLARE v_max_uses INT;
    DECLARE v_used_count INT;
    DECLARE v_min_order DECIMAL;
BEGIN

    SELECT discount_type,discount_value,expiry_date,max_uses,min_order_value
    INTO v_discount_type,v_discount_value,v_expiry,v_max_uses,v_min_order
    FROM coupons
    WHERE coupon_code=p_coupon_code;

    SELECT COUNT(*)
    INTO v_used_count
    FROM coupon_usage
             JOIN coupons
                  ON coupon_usage.coupon_id=coupons.coupon_id
    WHERE coupons.coupon_code=p_coupon_code;

    IF v_expiry<CURRENT_DATE THEN
        RAISE EXCEPTION 'Coupon expired';
    END IF;

    IF v_used_count>=v_max_uses THEN
        RAISE EXCEPTION 'Coupon usage limit exceeded';
    END IF;

    IF p_order_amount<v_min_order THEN
        RAISE EXCEPTION 'Minimum order value not met';
    END IF;

END;
$$;

--Q7
CREATE OR REPLACE PROCEDURE mark_order_delivered
(
    IN p_order_id BIGINT
)
    LANGUAGE plpgsql
AS $$
BEGIN

    UPDATE orders
    SET status='delivered'
    WHERE order_id=p_order_id;

    INSERT INTO invoices
    (
        order_id,
        invoice_number,
        generated_at,
        tax_amount
    )
    VALUES
        (
            p_order_id,
            'INV-'||p_order_id,
            NOW(),
            100
        );

END;
$$;

--Q8
CREATE OR REPLACE FUNCTION deduct_inventory_after_order()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS $$
BEGIN

    UPDATE inventory
    SET quantity_available=quantity_available-NEW.quantity
    WHERE product_id=NEW.product_id;

    INSERT INTO stock_movements
    (
        product_id,
        warehouse_id,
        movement_type,
        quantity,
        movement_timestamp
    )
    SELECT
        NEW.product_id,
        warehouse_id,
        'stock_out',
        NEW.quantity,
        NOW()
    FROM inventory
    WHERE product_id=NEW.product_id
    LIMIT 1;

    RETURN NEW;

END;
$$;

CREATE TRIGGER trg_order_items_inventory
    AFTER INSERT
    ON order_items
    FOR EACH ROW
EXECUTE FUNCTION deduct_inventory_after_order();

--Q9
CREATE OR REPLACE FUNCTION restore_inventory_after_return()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS $$
BEGIN

    UPDATE inventory
    SET quantity_available=quantity_available+order_items.quantity
    FROM order_items
    WHERE inventory.product_id=order_items.product_id
      AND order_items.order_item_id=NEW.order_item_id;

    INSERT INTO stock_movements
    (
        product_id,
        warehouse_id,
        movement_type,
        quantity,
        movement_timestamp
    )
    SELECT
        order_items.product_id,
        inventory.warehouse_id,
        'returned',
        order_items.quantity,
        NOW()
    FROM order_items
             JOIN inventory
                  ON order_items.product_id=inventory.product_id
    WHERE order_items.order_item_id=NEW.order_item_id
    LIMIT 1;

    RETURN NEW;

END;
$$;

CREATE TRIGGER trg_returns_inventory
    AFTER INSERT
    ON returns
    FOR EACH ROW
EXECUTE FUNCTION restore_inventory_after_return();

--Q10
CREATE OR REPLACE FUNCTION restore_inventory_on_cancel()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS $$
BEGIN

    IF NEW.status='cancelled'
        AND OLD.status IS DISTINCT FROM 'cancelled'
    THEN

        UPDATE inventory
        SET quantity_available=quantity_available+order_items.quantity
        FROM order_items
        WHERE inventory.product_id=order_items.product_id
          AND order_items.order_id=NEW.order_id;

    END IF;

    RETURN NEW;

END;
$$;

CREATE TRIGGER trg_cancel_order_inventory
    AFTER UPDATE
    ON orders
    FOR EACH ROW
EXECUTE FUNCTION restore_inventory_on_cancel();


--Q11
CREATE OR REPLACE FUNCTION update_product_rating()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS $$
BEGIN

    UPDATE products
    SET average_rating=
            (
                SELECT ROUND(AVG(stars),2)
                FROM ratings
                WHERE ratings.product_id=NEW.product_id
            )
    WHERE products.product_id=NEW.product_id;

    RETURN NEW;

END;
$$;

CREATE TRIGGER trg_update_product_rating
    AFTER INSERT
    ON ratings
    FOR EACH ROW
EXECUTE FUNCTION update_product_rating();

--Q12
CREATE OR REPLACE FUNCTION generate_invoice_after_payment()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS $$
BEGIN

    IF NEW.status='success'
    THEN

        INSERT INTO invoices
        (
            order_id,
            invoice_number,
            generated_at,
            tax_amount
        )
        VALUES
            (
                NEW.order_id,
                'INV-'||NEW.payment_id,
                NOW(),
                100
            );

    END IF;

    RETURN NEW;

END;
$$;

CREATE TRIGGER trg_generate_invoice
    AFTER INSERT
    ON payments
    FOR EACH ROW
EXECUTE FUNCTION generate_invoice_after_payment();

--Q13
CREATE OR REPLACE FUNCTION low_stock_alert()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS $$
BEGIN

    IF NEW.quantity_available<50
    THEN

        RAISE NOTICE 'Low stock alert for product %',NEW.product_id;

    END IF;

    RETURN NEW;

END;
$$;

CREATE TRIGGER trg_low_stock_alert
    AFTER UPDATE
    ON inventory
    FOR EACH ROW
EXECUTE FUNCTION low_stock_alert();

--Q14
BEGIN;

INSERT INTO orders
(
    customer_id,
    status,
    order_date,
    total_amount
)
VALUES
    (
        1,
        'pending',
        NOW(),
        1000
    );

INSERT INTO payments
(
    order_id,
    method,
    status,
    gateway_reference
)
VALUES
    (
        999999999,
        'card',
        'failed',
        'TEST_FAILURE'
    );

ROLLBACK;

--Q15
CREATE OR REPLACE PROCEDURE process_return
(
    IN p_order_item_id BIGINT,
    IN p_reason TEXT,
    IN p_refund_amount DECIMAL
)
    LANGUAGE plpgsql
AS $$
DECLARE v_return_id BIGINT;
BEGIN

    INSERT INTO returns
    (
        order_item_id,
        reason_code,
        item_condition,
        return_status
    )
    VALUES
        (
            p_order_item_id,
            p_reason,
            'opened',
            'approved'
        )
    RETURNING return_id
        INTO v_return_id;

    INSERT INTO refunds
    (
        return_id,
        amount,
        method,
        processed_timestamp
    )
    VALUES
        (
            v_return_id,
            p_refund_amount,
            'original',
            NOW()
        );

    COMMIT;

EXCEPTION
    WHEN OTHERS
        THEN
            ROLLBACK;
            RAISE;

END;
$$;