from fastapi import APIRouter
from fastapi import Depends
from fastapi import HTTPException

from sqlalchemy.orm import Session

from fastapi_app.database import get_db

import fastapi_app.crud
import fastapi_app.schemas

router = APIRouter(
    prefix="/users",
    tags=["Users"]
)


@router.get(
    "/",
    response_model=list[fastapi_app.schemas.UserResponse]
)
def get_all_users(
        db: Session = Depends(get_db)
):

    return fastapi_app.crud.get_users(db)


@router.get(
    "/{user_id}",
    response_model=fastapi_app.schemas.UserResponse
)
def get_single_user(
        user_id: int,
        db: Session = Depends(get_db)
):

    user = fastapi_app.crud.get_user(
        db,
        user_id
    )

    if user is None:

        raise HTTPException(
            status_code=404,
            detail="User not found"
        )

    return user


@router.post(
    "/",
    response_model=fastapi_app.schemas.UserResponse
)
def create_new_user(
        user: fastapi_app.schemas.UserCreate,
        db: Session = Depends(get_db)
):

    return fastapi_app.crud.create_user(
        db,
        user
    )


@router.delete(
    "/{user_id}"
)
def delete_existing_user(
        user_id: int,
        db: Session = Depends(get_db)
):

    user = fastapi_app.crud.delete_user(
        db,
        user_id
    )

    if user is None:

        raise HTTPException(
            status_code=404,
            detail="User not found"
        )

    return {
        "message": "User deleted successfully"
    }