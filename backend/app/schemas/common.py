from datetime import date
from typing import Any

from pydantic import BaseModel


class DateRange(BaseModel):
    start: date
    end: date


class HealthResponse(BaseModel):
    status: str
    version: str
    rows_loaded: int
    data_range: DateRange


class LocationResponse(BaseModel):
    name: str
    center: dict[str, float]
    bbox: list[float]
    aoi: dict[str, Any]
    data_range: DateRange
    data_sources: list[dict[str, str]]
