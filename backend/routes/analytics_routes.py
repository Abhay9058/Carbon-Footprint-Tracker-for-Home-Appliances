from services.database import db
from schemas import AnalyticsModel, EcoTipModel
from fastapi import APIRouter
from typing import List

router = APIRouter(prefix="/analytics", tags=["Analytics"])


@router.get("/{user_id}", response_model=AnalyticsModel)
async def get_analytics(user_id: int):
    return await db.get_analytics(user_id)


@router.get("/tips/list", response_model=List[EcoTipModel])
async def get_eco_tips(limit: int = 5):
    return await db.get_eco_tips(limit)
