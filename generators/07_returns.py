from config import *
from tqdm import tqdm
import random

conn=get_conn()
cur=conn.cursor()

RETURN_RATE=0.08
CHUNK=50_000

########################################
# LOAD ELIGIBLE ORDER ITEMS
########################################

print("Loading delivered order items...")

cur.execute("""

SELECT
oi.order_item_id

FROM order_items oi

JOIN orders o
ON oi.order_id=o.order_id

WHERE o.status='delivered'

""")

eligible_items=[x[0] for x in cur.fetchall()]

print(
    f"{len(eligible_items):,} eligible items loaded."
)

########################################
# SAMPLE RETURNS
########################################

return_count=int(
    len(eligible_items)*RETURN_RATE
)

selected=random.sample(
    eligible_items,
    return_count
)

print(
    f"Generating {return_count:,} returns..."
)

reason_codes=[
'Damaged',
'Wrong Item',
'Quality Issue',
'Not Needed',
'Late Delivery'
]

conditions=[
'new',
'opened',
'damaged'
]

statuses=[
'approved',
'pending',
'rejected'
]

refund_methods=[
'original',
'wallet',
'bank'
]

########################################
# GENERATE
########################################

return_id=1
refund_id=1

for start in range(
        0,
        return_count,
        CHUNK
):

    batch=selected[
        start:start+CHUNK
    ]

    return_rows=[]
    refund_rows=[]

    for order_item_id in batch:

        status=random.choices(

            statuses,

            weights=[
                70,
                15,
                15
            ]

        )[0]

        return_rows.append((

            return_id,

            order_item_id,

            random.choice(
                reason_codes
            ),

            random.choice(
                conditions
            ),

            status
        ))

        if status=='approved':

            refund_rows.append((

                refund_id,

                return_id,

                round(
                    random.uniform(
                        10,
                        5000
                    ),
                    2
                ),

                random.choice(
                    refund_methods
                ),

                fake.date_time_this_year()
            ))

            refund_id +=1

        return_id +=1

    cur.executemany(
    """
    INSERT INTO returns
    VALUES(%s,%s,%s,%s,%s)
    """,
    return_rows
    )

    if refund_rows:

        cur.executemany(
        """
        INSERT INTO refunds
        VALUES(%s,%s,%s,%s,%s)
        """,
        refund_rows
        )

    conn.commit()

    print(
        f"Committed {start:,}"
    )

cur.close()
conn.close()

print("SET-7 COMPLETE")