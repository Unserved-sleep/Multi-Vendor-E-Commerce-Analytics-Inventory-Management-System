from sqlalchemy.orm import Session
from fastapi_app.models import User
from fastapi_app.schemas import UserCreate


def get_users(db: Session):
    return db.query(User).all()


def get_user(db: Session, user_id: int):
    return (
        db.query(User)
        .filter(User.user_id == user_id)
        .first()
    )


def create_user(
        db: Session,
        user: UserCreate
):

    db_user = User(
        email=user.email,
        role=user.role,
        hashed_password = user.hashed_password

    )

    db.add(db_user)

    db.commit()

    db.refresh(db_user)

    return db_user


def delete_user(
        db: Session,
        user_id: int
):

    user = get_user(
        db,
        user_id
    )

    if user:

        db.delete(user)

        db.commit()

    return user