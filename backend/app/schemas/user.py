from pydantic import BaseModel


class UserBase(BaseModel):
    name: str
    email: str


class UserCreate(UserBase):
    pass


class UserResponse(UserBase):
    id: int

    model_config = {"from_attributes": True}
