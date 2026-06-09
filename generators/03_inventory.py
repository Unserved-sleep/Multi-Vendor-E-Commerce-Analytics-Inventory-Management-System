from config import *
from tqdm import tqdm
import random

conn=get_conn()
cur=conn.cursor()

WAREHOUSES=25

print("Loading products...")

cur.execute("""
SELECT product_id
FROM products
""")

product_ids=[x[0] for x in cur.fetchall()]

print("Products loaded.")

########################################
# WAREHOUSES
########################################

print("Generating warehouses...")

warehouse_rows=[]

for wid in range(1,WAREHOUSES+1):

    warehouse_rows.append((

        wid,

        f"Warehouse_{wid}",

        fake.city(),

        random.randint(
            10000,
            100000
        )
    ))

cur.executemany(
"""
INSERT INTO warehouses
VALUES(%s,%s,%s,%s)
""",
warehouse_rows
)

conn.commit()

print("Warehouses inserted.")

########################################
# INVENTORY
########################################

print("Generating inventory...")

inventory_rows=[]

for pid in tqdm(product_ids):

    assigned=random.sample(
        range(1,WAREHOUSES+1),
        random.randint(2,5)
    )

    for wid in assigned:

        inventory_rows.append((

            pid,

            wid,

            random.randint(
                10,
                1000
            )
        ))

cur.executemany(
"""
INSERT INTO inventory
VALUES(%s,%s,%s)
""",
inventory_rows
)

conn.commit()

print("Inventory inserted.")

########################################
# STOCK MOVEMENTS
########################################

print("Generating stock movements...")

movement_rows=[]

movement_id=1

movement_types=[
'stock_in',
'stock_out',
'damaged',
'returned'
]

for row in tqdm(inventory_rows):

    pid=row[0]
    wid=row[1]

    moves=random.randint(2,10)

    for _ in range(moves):

        movement_rows.append((

            movement_id,

            pid,

            wid,

            random.choice(
                movement_types
            ),

            random.randint(
                1,
                200
            ),

            fake.date_time_this_year()
        ))

        movement_id +=1

cur.executemany(
"""
INSERT INTO stock_movements
VALUES(%s,%s,%s,%s,%s,%s)
""",
movement_rows
)

conn.commit()

print("Stock movements inserted.")

cur.close()
conn.close()

print("SET-3 COMPLETE")