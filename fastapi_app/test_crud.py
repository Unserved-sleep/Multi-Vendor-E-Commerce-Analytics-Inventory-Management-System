from fastapi_app.database import SessionLocal
from fastapi_app.crud import get_users

db = SessionLocal()

users = get_users(db)

print(users[:5])

db.close()