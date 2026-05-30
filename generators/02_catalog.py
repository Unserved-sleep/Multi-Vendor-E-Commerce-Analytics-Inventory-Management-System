from config import *
from tqdm import tqdm
import random

conn = get_conn()
cur = conn.cursor()

PRODUCTS = 50_000

print("Loading FK pools...")

cur.execute("SELECT seller_id FROM seller_profiles")
seller_ids = [x[0] for x in cur.fetchall()]

cur.execute("SELECT brand_id FROM brands")
brand_ids = [x[0] for x in cur.fetchall()]

cur.execute("SELECT category_id FROM categories")
category_ids = [x[0] for x in cur.fetchall()]

print("FK pools loaded.")

########################################
# PRODUCTS
########################################

print("Generating products...")

product_rows=[]

for pid in tqdm(range(1, PRODUCTS+1)):

    product_rows.append((

        pid,

        f"SKU{pid}",

        fake.slug(),

        fake.catch_phrase(),

        round(
            random.uniform(50,50000),
            2
        ),

        random.choice(seller_ids),

        random.choice(brand_ids),

        random.choice([
            'active',
            'inactive'
        ])
    ))

cur.executemany(
    """
    INSERT INTO products
    VALUES(%s,%s,%s,%s,%s,%s,%s,%s)
    """,
    product_rows
)

conn.commit()

print("Products inserted.")

########################################
# PRODUCT CATEGORIES
########################################

print("Generating product_categories...")

category_rows=[]

for pid in tqdm(range(1,PRODUCTS+1)):

    chosen=random.sample(
        category_ids,
        random.randint(1,3)
    )

    for cid in chosen:

        category_rows.append((pid,cid))

cur.executemany(
    """
    INSERT INTO product_categories
    VALUES(%s,%s)
    """,
    category_rows
)

conn.commit()

print("Product categories inserted.")

########################################
# PRODUCT IMAGES
########################################

print("Generating product_images...")

image_rows=[]

image_id=1

for pid in tqdm(range(1,PRODUCTS+1)):

    count=random.randint(1,4)

    for order in range(count):

        image_rows.append((

            image_id,

            pid,

            fake.image_url(),

            order+1
        ))

        image_id +=1

cur.executemany(
    """
    INSERT INTO product_images
    VALUES(%s,%s,%s,%s)
    """,
    image_rows
)

conn.commit()

print("Product images inserted.")

cur.close()
conn.close()

print("SET-2 COMPLETE")