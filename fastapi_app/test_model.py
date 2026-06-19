from fastapi_app.database import SessionLocal
from fastapi_app.models import User

db = SessionLocal()

user = db.query(User).first()

print(user)

if user:
    print(user.user_id)
    print(user.email)
    print(user.role)

db.close()