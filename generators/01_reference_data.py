from config import *
from tqdm import tqdm
import random

conn = get_conn()
cur = conn.cursor()

print("Generating users...")

customer_ids=[]
seller_ids=[]

for uid in tqdm(range(1, USERS+1)):

    role = random.choices(
        ['customer','seller'],
        weights=[90,10]
    )[0]

    email=fake.unique.email()

    cur.execute("""
    INSERT INTO users
    VALUES(%s,%s,%s,%s)
    """,(
        uid,
        email,
        fake.password(),
        role
    ))

    if role=='customer':
        customer_ids.append(uid)
    else:
        seller_ids.append(uid)

conn.commit()

print("Users inserted.")


print("Customer profiles...")

for cid in tqdm(customer_ids):

    cur.execute("""
    INSERT INTO customer_profiles
    VALUES(%s,%s,%s,%s)
    """,(
        cid,
        random.randint(0,5000),
        None,
        fake.date_of_birth(
            minimum_age=18,
            maximum_age=75
        )
    ))

conn.commit()


print("Seller profiles...")

for sid in tqdm(seller_ids):

    cur.execute("""
    INSERT INTO seller_profiles
    VALUES(%s,%s,%s,%s,%s)
    """,(
        sid,
        fake.company(),
        fake.bothify("GST########"),
        round(random.uniform(2,15),2),
        random.choice([True,False])
    ))

conn.commit()


print("Addresses...")

address_id=1

for uid in tqdm(range(1,USERS+1)):

    count=random.randint(1,ADDRESS_MAX)

    for _ in range(count):

        cur.execute("""
        INSERT INTO addresses
        VALUES(%s,%s,%s,%s,%s,%s,%s)
        """,(
            address_id,
            uid,
            fake.street_address(),
            fake.city(),
            fake.state(),
            fake.country(),
            fake.postcode()
        ))

        address_id +=1

conn.commit()


print("Updating preferred addresses...")

for cid in tqdm(customer_ids):

    cur.execute("""
    SELECT address_id
    FROM addresses
    WHERE user_id=%s
    ORDER BY RANDOM()
    LIMIT 1
    """,(cid,))

    addr=cur.fetchone()[0]

    cur.execute("""
    UPDATE customer_profiles
    SET preferred_address=%s
    WHERE customer_id=%s
    """,(addr,cid))

conn.commit()


print("Brands...")

for bid in tqdm(range(1,BRANDS+1)):

    cur.execute("""
    INSERT INTO brands
    VALUES(%s,%s,%s)
    """,(
        bid,
        fake.company(),
        random.choice([True,False])
    ))

conn.commit()


print("Categories...")

names=[
"Electronics","Mobiles","Laptops",
"Gaming","Clothing","Shoes",
"Books","Furniture","Beauty",
"Kitchen","Sports","Groceries"
]

for cid in tqdm(range(1,CATEGORY_COUNT+1)):

    if cid <=20:
        parent=None
    else:
        parent=random.randint(
            1,
            cid-1
        )

    cur.execute("""
    INSERT INTO categories
    VALUES(%s,%s,%s)
    """,(
        cid,
        random.choice(names)+"_"+str(cid),
        parent
    ))

conn.commit()


cur.close()
conn.close()

print("REFERENCE TABLE GENERATION COMPLETE")


