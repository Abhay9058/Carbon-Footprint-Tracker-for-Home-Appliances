from services.database import db
from schemas import UsageLogModel, UsageLogCreate
from fastapi import APIRouter
from typing import List, Optional

router = APIRouter(prefix="/usage", tags=["Usage Logs"])


@router.get("/{user_id}", response_model=List[UsageLogModel])
async def get_usage_logs(user_id: int, limit: Optional[int] = None):
    return await db.get_usage_logs(user_id, limit)


@router.post("/{user_id}", response_model=UsageLogModel)
async def create_usage_log(user_id: int, log: UsageLogCreate):
    return await db.create_usage_log(user_id, log)
