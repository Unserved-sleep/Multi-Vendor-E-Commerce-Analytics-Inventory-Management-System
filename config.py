import psycopg
from faker import Faker
import random

fake = Faker()

DB_CONFIG = {
    "host":"localhost",
    "port":5432,
    "dbname":"multi_vendor_ecom",
    "user":"postgres",
    "password":"120205"
}

USERS = 100_000
SELLER_RATIO = 0.10
ADDRESS_MAX = 3
BRANDS = 500
CATEGORY_COUNT = 200

def get_conn():
    return psycopg.connect(**DB_CONFIG)