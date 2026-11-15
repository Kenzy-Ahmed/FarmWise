from datetime import date

from pydantic import BaseModel


class SoilProfile(BaseModel):
    ph: float
    ph_class: str
    soc_g_kg: float
    nitrogen_g_kg: float
    cec_cmolc_kg: float
    bulk_density_kg_dm3: float
    clay_pct: float
    sand_pct: float
    silt_pct: float
    texture_normalized: dict[str, float]
    texture_class: str
    source: str = "ISRIC SoilGrids 250m (0-5 cm, AOI mean)"


class SoilMoisturePoint(BaseModel):
    date: date
    soil_moisture_m3m3: float
    at_min_value: bool


class SoilMoistureSeries(BaseModel):
    source: str = "NASA SMAP L3 (AM pass)"
    mean_m3m3: float | None
    latest: SoilMoisturePoint | None
    points: list[SoilMoisturePoint]
