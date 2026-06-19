from pydantic import BaseModel


class UserBase(BaseModel):
    email: str
    role: str


class UserCreate(UserBase):
    hashed_password: str


class UserResponse(UserBase):
    user_id: int

    class Config:
        from_attributes = True