from sqlalchemy import Column
from sqlalchemy import BigInteger
from sqlalchemy import String
from sqlalchemy import TIMESTAMP

from fastapi_app.database import Base


class User(Base):

    __tablename__ = "users"

    user_id = Column(
        BigInteger,
        primary_key=True,
        index=True
    )

    email = Column(
        String
    )

    role = Column(
        String
    )

    hashed_password = Column(
        String
    )