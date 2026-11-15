from fastapi import APIRouter, Depends

from app.api.deps import DateFilter, store
from app.data.store import DataStore
from app.schemas.soil import SoilMoistureSeries, SoilProfile
from app.services import soil as svc

router = APIRouter(prefix="/soil", tags=["soil"])


@router.get("", response_model=SoilProfile)
def soil_profile(s: DataStore = Depends(store)):
    return svc.profile(s)


@router.get("/moisture", response_model=SoilMoistureSeries)
def soil_moisture(f: DateFilter = Depends(), s: DataStore = Depends(store)):
    return svc.moisture(s, f.start, f.end)
