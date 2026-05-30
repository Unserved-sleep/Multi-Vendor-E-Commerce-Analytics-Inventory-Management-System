from config import *
from tqdm import tqdm
import random

conn = get_conn()
cur = conn.cursor()

ORDERS = 1_000_000
CHUNK = 25_000
CARTS = 300_000

print("Loading FK pools...")

cur.execute("""
SELECT user_id
FROM users
WHERE role='customer'
""")
customer_ids=[x[0] for x in cur.fetchall()]

cur.execute("""
SELECT product_id
FROM products
""")
product_ids=[x[0] for x in cur.fetchall()]

print("FK pools loaded.")

########################################
# CARTS
########################################

print("Generating carts...")

cart_rows=[]

for cid in tqdm(range(1,CARTS+1)):

    cart_rows.append((

        cid,

        random.choice(customer_ids),

        fake.future_datetime()
    ))

cur.executemany(
"""
INSERT INTO carts
VALUES(%s,%s,%s)
""",
cart_rows
)

conn.commit()

print("Carts inserted.")

########################################
# CART ITEMS
########################################

print("Generating cart_items...")

cart_item_rows=[]

cart_item_id=1

for cid in tqdm(range(1,CARTS+1)):

    count=random.randint(1,5)

    chosen=random.sample(
        product_ids,
        count
    )

    for pid in chosen:

        cart_item_rows.append((

            cart_item_id,

            cid,

            pid,

            random.randint(1,4)
        ))

        cart_item_id +=1

cur.executemany(
"""
INSERT INTO cart_items
VALUES(%s,%s,%s,%s)
""",
cart_item_rows
)

conn.commit()

print("Cart items inserted.")

########################################
# ORDERS + ORDER ITEMS
########################################

print("Generating orders...")

order_statuses=[
'pending',
'confirmed',
'shipped',
'delivered',
'cancelled'
]

order_id=1
order_item_id=1

for chunk_start in range(
        0,
        ORDERS,
        CHUNK
):

    order_rows=[]
    item_rows=[]

    for _ in range(CHUNK):

        customer=random.choice(
            customer_ids
        )

        status=random.choices(

            order_statuses,

            weights=[
                10,
                15,
                20,
                50,
                5
            ]
        )[0]

        total=0

        items=random.randint(
            1,
            5
        )

        chosen_products=random.sample(
            product_ids,
            items
        )

        for pid in chosen_products:

            qty=random.randint(
                1,
                4
            )

            price=round(
                random.uniform(
                    50,
                    50000
                ),
                2
            )

            total += qty*price

            item_rows.append((

                order_item_id,

                order_id,

                pid,

                qty,

                price
            ))

            order_item_id +=1

        order_rows.append((

            order_id,

            customer,

            status,

            fake.date_time_between(
                start_date='-2y',
                end_date='now'
            ),

            round(total,2)
        ))

        order_id +=1

    cur.executemany(
    """
    INSERT INTO orders
    VALUES(%s,%s,%s,%s,%s)
    """,
    order_rows
    )

    cur.executemany(
    """
    INSERT INTO order_items
    VALUES(%s,%s,%s,%s,%s)
    """,
    item_rows
    )

    conn.commit()

    print(
        f"Committed orders {chunk_start:,}"
    )

cur.close()
conn.close()

print("SET-4 COMPLETE")