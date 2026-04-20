from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from routes import user_routes, appliance_routes, usage_routes, analytics_routes

app = FastAPI(
    title="Eco Warrior API",
    description="Carbon Footprint Tracker Backend API",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class CarbonRequest(BaseModel):
    electricity: float
    transport: float
    diet: float = 0.0


class CarbonResponse(BaseModel):
    carbon_footprint: float

app.include_router(user_routes.router)
app.include_router(appliance_routes.router)
app.include_router(usage_routes.router)
app.include_router(analytics_routes.router)


@app.get("/")
async def root():
    return {"message": "Carbon Tracker API Running"}


@app.get("/health")
async def health_check():
    return {"status": "healthy"}


@app.post("/calculate")
async def calculate_carbon(request: CarbonRequest) -> CarbonResponse:
    carbon = (request.electricity * 0.5) + (request.transport * 0.2) + (request.diet * 0.3)
    return CarbonResponse(carbon_footprint=carbon)


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)
