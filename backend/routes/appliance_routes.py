from services.database import db
from schemas import ApplianceModel, ApplianceCreate
from fastapi import APIRouter, HTTPException
from typing import List

router = APIRouter(prefix="/appliances", tags=["Appliances"])


@router.get("/{user_id}", response_model=List[ApplianceModel])
async def get_appliances(user_id: int):
    return await db.get_appliances(user_id)


@router.post("/{user_id}", response_model=ApplianceModel)
async def create_appliance(user_id: int, appliance: ApplianceCreate):
    return await db.create_appliance(user_id, appliance)


@router.delete("/{appliance_id}")
async def delete_appliance(appliance_id: int):
    if await db.delete_appliance(appliance_id):
        return {"message": "Appliance deleted successfully"}
    raise HTTPException(status_code=404, detail="Appliance not found")


@router.get("/calculate/{appliance_id}/{hours}")
async def calculate_emission(appliance_id: int, hours: float):
    emission = await db.calculate_carbon_emission(appliance_id, hours)
    return {"emission": emission}
