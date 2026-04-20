from services.database import db
from schemas import UserModel, UserUpdate, LoginRequest, RegisterRequest, AuthResponse
from fastapi import APIRouter, HTTPException
from typing import List, Optional

router = APIRouter(prefix="/user", tags=["User"])


@router.get("/{user_id}", response_model=UserModel)
async def get_user(user_id: int):
    user = await db.get_user(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


@router.put("/{user_id}", response_model=UserModel)
async def update_user(user_id: int, update: UserUpdate):
    user = await db.update_user(
        user_id,
        username=update.username,
        email=update.email,
        dark_mode=update.dark_mode,
        eco_tips_notifications=update.eco_tips_notifications
    )
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


@router.post("/login", response_model=AuthResponse)
async def login(login_data: LoginRequest):
    result = await db.login_user(login_data)
    if not result.success:
        raise HTTPException(status_code=401, detail=result.message)
    return result


@router.post("/register", response_model=AuthResponse)
async def register(register_data: RegisterRequest):
    result = await db.register_user(register_data)
    if not result.success:
        raise HTTPException(status_code=400, detail=result.message)
    return result
