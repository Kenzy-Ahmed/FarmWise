from fastapi import APIRouter, Depends

from app.api.deps import store
from app.core.config import get_settings
from app.data.store import DataStore
from app.schemas.common import HealthResponse, LocationResponse

router = APIRouter(tags=["meta"])

DATA_SOURCES = [
    {"name": "NASA POWER", "provides": "Temperature, precipitation, humidity, wind, solar radiation (daily)"},
    {"name": "NASA GPM IMERG", "provides": "Satellite precipitation (daily)"},
    {"name": "NASA SMAP", "provides": "Surface soil moisture (2-3 day revisit)"},
    {"name": "NASA MODIS MOD13Q1", "provides": "NDVI vegetation index (16-day, 250 m)"},
    {"name": "ISRIC SoilGrids", "provides": "Soil pH, texture, organic carbon, nitrogen, CEC, bulk density"},
    {"name": "FAO GAEZ v4", "provides": "Agro-ecological crop suitability"},
    {"name": "FAO ECOCROP", "provides": "Crop climatic and soil requirements"},
]


@router.get("/health", response_model=HealthResponse)
def health(s: DataStore = Depends(store)):
    return {
        "status": "ok",
        "version": get_settings().version,
        "rows_loaded": len(s.daily),
        "data_range": {"start": s.date_min.date(), "end": s.date_max.date()},
    }


@router.get("/location", response_model=LocationResponse)
def location(s: DataStore = Depends(store)):
    coords = s.aoi["features"][0]["geometry"]["coordinates"][0]
    lons = [c[0] for c in coords]
    lats = [c[1] for c in coords]
    return {
        "name": get_settings().site_name,
        "center": {"lat": float(s.daily["aoi_center_lat"].iloc[0]), "lon": float(s.daily["aoi_center_lon"].iloc[0])},
        "bbox": [min(lons), min(lats), max(lons), max(lats)],
        "aoi": s.aoi,
        "data_range": {"start": s.date_min.date(), "end": s.date_max.date()},
        "data_sources": DATA_SOURCES,
    }
