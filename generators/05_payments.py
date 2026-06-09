from config import *
from tqdm import tqdm
import random

conn=get_conn()
cur=conn.cursor()

CHUNK=50_000

print("Loading orders...")

cur.execute("""
SELECT order_id,status
FROM orders
""")

orders=cur.fetchall()

print(f"{len(orders):,} orders loaded.")

payment_methods=[
'card',
'upi',
'wallet',
'netbanking'
]

payment_statuses=[
'success',
'failed',
'pending'
]

########################################
# PAYMENTS
########################################

print("Generating payments...")

payment_id=1
transaction_id=1
invoice_id=1

for start in range(
        0,
        len(orders),
        CHUNK
):

    batch=orders[start:start+CHUNK]

    payment_rows=[]
    transaction_rows=[]
    invoice_rows=[]

    for order in batch:

        order_id=order[0]
        order_status=order[1]

        if order_status=='cancelled':

            status='failed'

        else:

            status=random.choices(

                payment_statuses,

                weights=[
                    80,
                    10,
                    10
                ]

            )[0]

        method=random.choice(
            payment_methods
        )

        payment_rows.append((

            payment_id,

            order_id,

            method,

            status,

            fake.uuid4()
        ))

        transaction_rows.append((

            transaction_id,

            payment_id,

            status,

            fake.date_time_this_year()
        ))

        if status=='success':

            invoice_rows.append((

                invoice_id,

                order_id,

                f"INV{invoice_id}",

                fake.date_time_this_year(),

                round(
                    random.uniform(
                        5,
                        500
                    ),
                    2
                )
            ))

            invoice_id +=1

        payment_id +=1
        transaction_id +=1

    cur.executemany(
    """
    INSERT INTO payments
    VALUES(%s,%s,%s,%s,%s)
    """,
    payment_rows
    )

    cur.executemany(
    """
    INSERT INTO payment_transactions
    VALUES(%s,%s,%s,%s)
    """,
    transaction_rows
    )

    if invoice_rows:

        cur.executemany(
        """
        INSERT INTO invoices
        VALUES(%s,%s,%s,%s,%s)
        """,
        invoice_rows
        )

    conn.commit()

    print(
        f"Committed {start:,}"
    )

cur.close()
conn.close()

print("SET-5 COMPLETE")