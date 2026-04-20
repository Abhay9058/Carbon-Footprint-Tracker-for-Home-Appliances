from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime


class UserModel(BaseModel):
    id: int
    username: str
    email: str = ""
    role: str = "user"
    member_since: str
    total_carbon_emissions: float = 0.0
    dark_mode: bool = False
    eco_tips_notifications: bool = True


class LoginRequest(BaseModel):
    email: str
    password: str


class RegisterRequest(BaseModel):
    username: str
    email: str
    password: str


class AuthResponse(BaseModel):
    success: bool
    message: str
    user_id: Optional[int] = None
    user: Optional[UserModel] = None


class ApplianceType(str):
    LIGHTING = "Lighting"
    COOLING = "Cooling"
    HEATING = "Heating"
    ENTERTAINMENT = "Entertainment"
    KITCHEN = "Kitchen"
    LAUNDRY = "Laundry"
    COMPUTING = "Computing"
    OTHER = "Other"


class ApplianceModel(BaseModel):
    id: int
    user_id: int
    name: str
    appliance_type: str
    wattage: float
    quantity: int
    created_at: str


class UsageLogModel(BaseModel):
    id: int
    user_id: int
    appliance_id: int
    hours: float
    date: str
    carbon_emission: float
    created_at: str


class ApplianceCreate(BaseModel):
    name: str
    appliance_type: str
    wattage: float
    quantity: int


class UsageLogCreate(BaseModel):
    appliance_id: int
    hours: float
    date: str


class AnalyticsModel(BaseModel):
    daily_emissions: List[dict]
    weekly_total: float
    monthly_total: float = 0.0
    yearly_total: float = 0.0
    monthly_emissions: List[dict]
    emissions_by_appliance: List[dict]
    top_appliances: List[dict]
    highest_emission_appliance: Optional[dict] = None
    today_emission: float
    daily_average: float
    total_carbon_emissions: float = 0.0


class EcoTipModel(BaseModel):
    id: int
    title: str
    description: str
    category: str


class UserUpdate(BaseModel):
    username: Optional[str] = None
    email: Optional[str] = None
    dark_mode: Optional[bool] = None
    eco_tips_notifications: Optional[bool] = None
