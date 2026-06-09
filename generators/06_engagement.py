from config import *
from tqdm import tqdm
import random

conn=get_conn()
cur=conn.cursor()

COUPONS=500
REVIEWS=500_000
CHUNK=50_000

########################################
# LOAD FK POOLS
########################################

print("Loading customers...")

cur.execute("""
SELECT user_id
FROM users
WHERE role='customer'
""")

customer_ids=[x[0] for x in cur.fetchall()]

print("Loading products...")

cur.execute("""
SELECT product_id
FROM products
""")

product_ids=[x[0] for x in cur.fetchall()]

print("Loading orders...")

cur.execute("""
SELECT order_id,customer_id
FROM orders
""")

orders=cur.fetchall()

print("FK pools loaded.")

########################################
# COUPONS
########################################

print("Generating coupons...")

coupon_rows=[]

for cid in range(1,COUPONS+1):

    coupon_rows.append((

        cid,

        f"COUPON{cid}",

        random.choice([
            'flat',
            'percentage'
        ]),

        round(
            random.uniform(
                5,
                50
            ),
            2
        ),

        random.randint(
            100,
            10000
        ),

        fake.future_date(),

        round(
            random.uniform(
                100,
                1000
            ),
            2
        )
    ))

cur.executemany(
"""
INSERT INTO coupons
VALUES(%s,%s,%s,%s,%s,%s,%s)
""",
coupon_rows
)

conn.commit()

print("Coupons inserted.")

########################################
# COUPON USAGE
########################################

print("Generating coupon_usage...")

usage_rows=[]

usage_id=1

sample_orders=random.sample(
    orders,
    min(
        250_000,
        len(orders)
    )
)

for order in tqdm(sample_orders):

    usage_rows.append((

        usage_id,

        random.randint(
            1,
            COUPONS
        ),

        order[1],

        fake.date_time_this_year()
    ))

    usage_id +=1

cur.executemany(
"""
INSERT INTO coupon_usage
VALUES(%s,%s,%s,%s)
""",
usage_rows
)

conn.commit()

print("Coupon usage inserted.")

########################################
# REVIEWS + RATINGS
########################################

print("Generating reviews and ratings...")

review_id=1
rating_id=1

for start in range(
        0,
        REVIEWS,
        CHUNK
):

    review_rows=[]
    rating_rows=[]

    for _ in range(CHUNK):

        customer=random.choice(
            customer_ids
        )

        product=random.choice(
            product_ids
        )

        verified=random.choices(
            [True,False],
            weights=[75,25]
        )[0]

        review_rows.append((

            review_id,

            product,

            customer,

            fake.sentence(),

            fake.paragraph(),

            verified,

            random.randint(
                0,
                1000
            )
        ))

        stars=random.choices(

            [1,2,3,4,5],

            weights=[
                5,
                10,
                15,
                30,
                40
            ]

        )[0]

        rating_rows.append((

            rating_id,

            product,

            customer,

            stars,

            random.choice([
                'approved',
                'pending',
                'rejected'
            ])
        ))

        review_id +=1
        rating_id +=1

    cur.executemany(
    """
    INSERT INTO reviews
    VALUES(%s,%s,%s,%s,%s,%s,%s)
    """,
    review_rows
    )

    cur.executemany(
    """
    INSERT INTO ratings
    VALUES(%s,%s,%s,%s,%s)
    """,
    rating_rows
    )

    conn.commit()

    print(
        f"Committed {start:,}"
    )

cur.close()
conn.close()

print("SET-6 COMPLETE")