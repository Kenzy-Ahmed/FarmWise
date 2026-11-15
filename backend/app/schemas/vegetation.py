from datetime import date

from pydantic import BaseModel


class NdviPoint(BaseModel):
    composite_date: date
    ndvi_mean: float
    ndvi_median: float
    ndvi_std: float
    pixel_coverage_frac: float
    low_coverage: bool


class NdviSeries(BaseModel):
    source: str = "MODIS MOD13Q1 v061 (250 m, 16-day)"
    count: int
    mean: float | None
    latest: NdviPoint | None
    health_status: str | None
    points: list[NdviPoint]


class NdviMonthly(BaseModel):
    month: int
    month_name: str
    ndvi_mean: float
