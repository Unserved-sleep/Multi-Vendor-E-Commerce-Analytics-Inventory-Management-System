# Multi-Vendor E-Commerce Analytics & Inventory Management System

## Features
- Multi-vendor marketplace schema
- Large-scale synthetic dataset generation
- PostgreSQL relational design
- Analytics + validation queries

## Tech Stack
- PostgreSQL 18
- Python
- Faker
- Psycopg3
- DataGrip
- DataSpell

## Database Scale
Users: 100K
Products: 50K
Orders: 1M+
Order Items: 3M+

## Setup
1. Clone repo
2. Restore dump
3. Run validation queries

## Restore Database

pg_restore -U postgres -d multi_vendor_ecom database/multi_vendor_ecom.dump
