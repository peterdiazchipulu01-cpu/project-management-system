from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..schemas.user import UserCreate, UserResponse
from ..crud import users as crud

router = APIRouter(prefix="/api/users", tags=["users"])


@router.get("/", response_model=List[UserResponse])
def list_users(db: Session = Depends(get_db)):
    return crud.get_users(db)


@router.post("/", response_model=UserResponse, status_code=201)
def create_user(user: UserCreate, db: Session = Depends(get_db)):
    return crud.create_user(db, user)
