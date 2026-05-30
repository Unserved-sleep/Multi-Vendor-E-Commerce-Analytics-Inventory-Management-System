CREATE TABLE "users" (
  "user_id" BIGINT PRIMARY KEY,
  "email" VARCHAR(255) UNIQUE,
  "hashed_password" VARCHAR(255),
  "role" VARCHAR(20)
);

CREATE TABLE "customer_profiles" (
  "customer_id" BIGINT PRIMARY KEY,
  "loyalty_points" INT,
  "preferred_address" BIGINT,
  "date_of_birth" DATE
);

CREATE TABLE "seller_profiles" (
  "seller_id" BIGINT PRIMARY KEY,
  "business_name" VARCHAR(255),
  "gst_vat" VARCHAR(100),
  "commission_rate" DECIMAL(5,2),
  "verification_status" BOOLEAN
);

CREATE TABLE "addresses" (
  "address_id" BIGINT PRIMARY KEY,
  "user_id" BIGINT,
  "address_line" TEXT,
  "city" VARCHAR(100),
  "state" VARCHAR(100),
  "country" VARCHAR(100),
  "zip_code" VARCHAR(20)
);

CREATE TABLE "categories" (
  "category_id" BIGINT PRIMARY KEY,
  "category_name" VARCHAR(255),
  "parent_category_id" BIGINT
);

CREATE TABLE "brands" (
  "brand_id" BIGINT PRIMARY KEY,
  "brand_name" VARCHAR(255),
  "verified_flag" BOOLEAN
);

CREATE TABLE "products" (
  "product_id" BIGINT PRIMARY KEY,
  "sku" VARCHAR(100),
  "slug" VARCHAR(255),
  "product_name" VARCHAR(255),
  "base_price" DECIMAL(10,2),
  "seller_id" BIGINT,
  "brand_id" BIGINT,
  "status" VARCHAR(50)
);

CREATE TABLE "product_categories" (
  "product_id" BIGINT,
  "category_id" BIGINT
);

CREATE TABLE "product_images" (
  "image_id" BIGINT PRIMARY KEY,
  "product_id" BIGINT,
  "image_url" TEXT,
  "sort_order" INT
);

CREATE TABLE "warehouses" (
  "warehouse_id" BIGINT PRIMARY KEY,
  "warehouse_name" VARCHAR(255),
  "location" VARCHAR(255),
  "capacity" INT
);

CREATE TABLE "inventory" (
  "product_id" BIGINT,
  "warehouse_id" BIGINT,
  "quantity_available" INT
);

CREATE TABLE "stock_movements" (
  "movement_id" BIGINT PRIMARY KEY,
  "product_id" BIGINT,
  "warehouse_id" BIGINT,
  "movement_type" VARCHAR(50),
  "quantity" INT,
  "movement_timestamp" TIMESTAMP
);

CREATE TABLE "carts" (
  "cart_id" BIGINT PRIMARY KEY,
  "user_id" BIGINT,
  "expiry_time" TIMESTAMP
);

CREATE TABLE "cart_items" (
  "cart_item_id" BIGINT PRIMARY KEY,
  "cart_id" BIGINT,
  "product_id" BIGINT,
  "quantity" INT
);

CREATE TABLE "orders" (
  "order_id" BIGINT PRIMARY KEY,
  "customer_id" BIGINT,
  "status" VARCHAR(50),
  "order_date" TIMESTAMP,
  "total_amount" DECIMAL(10,2)
);

CREATE TABLE "order_items" (
  "order_item_id" BIGINT PRIMARY KEY,
  "order_id" BIGINT,
  "product_id" BIGINT,
  "quantity" INT,
  "unit_price" DECIMAL(10,2)
);

CREATE TABLE "payments" (
  "payment_id" BIGINT PRIMARY KEY,
  "order_id" BIGINT,
  "method" VARCHAR(50),
  "status" VARCHAR(50),
  "gateway_reference" VARCHAR(255)
);

CREATE TABLE "payment_transactions" (
  "transaction_id" BIGINT PRIMARY KEY,
  "payment_id" BIGINT,
  "transaction_status" VARCHAR(50),
  "transaction_time" TIMESTAMP
);

CREATE TABLE "invoices" (
  "invoice_id" BIGINT PRIMARY KEY,
  "order_id" BIGINT,
  "invoice_number" VARCHAR(100),
  "invoice_date" TIMESTAMP,
  "tax_amount" DECIMAL(10,2)
);

CREATE TABLE "coupons" (
  "coupon_id" BIGINT PRIMARY KEY,
  "coupon_code" VARCHAR(100),
  "discount_type" VARCHAR(50),
  "discount_value" DECIMAL(10,2),
  "max_uses" INT,
  "expiry_date" DATE,
  "minimum_order_value" DECIMAL(10,2)
);

CREATE TABLE "coupon_usage" (
  "usage_id" BIGINT PRIMARY KEY,
  "coupon_id" BIGINT,
  "customer_id" BIGINT,
  "used_at" TIMESTAMP
);

CREATE TABLE "reviews" (
  "review_id" BIGINT PRIMARY KEY,
  "product_id" BIGINT,
  "customer_id" BIGINT,
  "title" VARCHAR(255),
  "body" TEXT,
  "verified_purchase" BOOLEAN,
  "helpful_votes" INT
);

CREATE TABLE "ratings" (
  "rating_id" BIGINT PRIMARY KEY,
  "product_id" BIGINT,
  "customer_id" BIGINT,
  "stars" INT,
  "moderation_status" VARCHAR(50)
);

CREATE TABLE "returns" (
  "return_id" BIGINT PRIMARY KEY,
  "order_item_id" BIGINT,
  "reason_code" VARCHAR(255),
  "item_condition" VARCHAR(100),
  "return_status" VARCHAR(50)
);

CREATE TABLE "refunds" (
  "refund_id" BIGINT PRIMARY KEY,
  "return_id" BIGINT,
  "amount" DECIMAL(10,2),
  "refund_method" VARCHAR(50),
  "processed_timestamp" TIMESTAMP
);

ALTER TABLE "customer_profiles" ADD FOREIGN KEY ("customer_id") REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "seller_profiles" ADD FOREIGN KEY ("seller_id") REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "addresses" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "categories" ADD FOREIGN KEY ("parent_category_id") REFERENCES "categories" ("category_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "products" ADD FOREIGN KEY ("seller_id") REFERENCES "seller_profiles" ("seller_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "products" ADD FOREIGN KEY ("brand_id") REFERENCES "brands" ("brand_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "product_categories" ADD FOREIGN KEY ("product_id") REFERENCES "products" ("product_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "product_categories" ADD FOREIGN KEY ("category_id") REFERENCES "categories" ("category_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "product_images" ADD FOREIGN KEY ("product_id") REFERENCES "products" ("product_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "inventory" ADD FOREIGN KEY ("product_id") REFERENCES "products" ("product_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "inventory" ADD FOREIGN KEY ("warehouse_id") REFERENCES "warehouses" ("warehouse_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "stock_movements" ADD FOREIGN KEY ("product_id") REFERENCES "products" ("product_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "stock_movements" ADD FOREIGN KEY ("warehouse_id") REFERENCES "warehouses" ("warehouse_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "carts" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "cart_items" ADD FOREIGN KEY ("cart_id") REFERENCES "carts" ("cart_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "cart_items" ADD FOREIGN KEY ("product_id") REFERENCES "products" ("product_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "orders" ADD FOREIGN KEY ("customer_id") REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "order_items" ADD FOREIGN KEY ("order_id") REFERENCES "orders" ("order_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "order_items" ADD FOREIGN KEY ("product_id") REFERENCES "products" ("product_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "payments" ADD FOREIGN KEY ("order_id") REFERENCES "orders" ("order_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "payment_transactions" ADD FOREIGN KEY ("payment_id") REFERENCES "payments" ("payment_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "invoices" ADD FOREIGN KEY ("order_id") REFERENCES "orders" ("order_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "coupon_usage" ADD FOREIGN KEY ("coupon_id") REFERENCES "coupons" ("coupon_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "coupon_usage" ADD FOREIGN KEY ("customer_id") REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "reviews" ADD FOREIGN KEY ("product_id") REFERENCES "products" ("product_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "reviews" ADD FOREIGN KEY ("customer_id") REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "ratings" ADD FOREIGN KEY ("product_id") REFERENCES "products" ("product_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "ratings" ADD FOREIGN KEY ("customer_id") REFERENCES "users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "returns" ADD FOREIGN KEY ("order_item_id") REFERENCES "order_items" ("order_item_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "refunds" ADD FOREIGN KEY ("return_id") REFERENCES "returns" ("return_id") DEFERRABLE INITIALLY IMMEDIATE;
