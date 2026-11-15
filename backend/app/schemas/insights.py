from datetime import date

from pydantic import BaseModel, Field


class Metric(BaseModel):
    key: str
    label: str
    value: float | None
    unit: str
    display: str
    bar: float = Field(description="0-100 value for a progress bar")
    as_of: date
    source: str
    description: str


class Risk(BaseModel):
    key: str
    label: str
    value: int
    level: str
    description: str
    method: str


class Insights(BaseModel):
    location: str
    metrics: list[Metric]
    risks: list[Risk]


class SeasonMonth(BaseModel):
    month: int
    month_name: str
    rain_mm: float
    temp_mean_c: float
    temp_max_c: float
    et0_mm: float
    ndvi: float | None
    field_status: str


class SeasonInsight(BaseModel):
    title: str
    months: list[int]
    text: str


class Seasons(BaseModel):
    months: list[SeasonMonth]
    insights: list[SeasonInsight]


class CropFit(BaseModel):
    crop: str
    climate_fit: int


class Rotation(BaseModel):
    name: str
    sequence: list[str]
    score: int
    water_demand: int
    soil_benefit: int
    nitrogen_potential: int
    erosion_reduction: int
    climate_suitability: int
    income_potential: int
    est_irrigation_mm_per_year: int
    crop_fit: list[CropFit]
    unknown_crops: list[str]
    risk: str
    why: str


class RotationRequest(BaseModel):
    rotation: str | list[str] | None = Field(None, examples=["Wheat → Maize → Fallow"])
    priorities: list[str] | None = Field(None, examples=[["soil", "res"]],
                                         description="Any of soil, water, res, n, ero, inc")


class ChatRequest(BaseModel):
    message: str
    rotation: str | None = None
    priorities: list[str] | None = None


class ChatResponse(BaseModel):
    reply: str
    topic: str
