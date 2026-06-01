from config import *
import psycopg

def get_conn():
    return psycopg.connect(**DB_CONFIG)