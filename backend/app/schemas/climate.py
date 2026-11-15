from datetime import date

from pydantic import BaseModel


class ClimateSummary(BaseModel):
    start: date
    end: date
    years_covered: int
    mean_temp_c: float
    mean_max_temp_c: float
    mean_min_temp_c: float
    hottest_month: int
    coldest_month: int
    avg_annual_rainfall_mm: float
    avg_annual_rainfall_gpm_mm: float | None
    mean_rh_pct: float
    mean_wind_ms: float
    mean_solar_mj_m2_day: float


class MonthlyClimate(BaseModel):
    month: int
    month_name: str
    temp_mean_c: float
    temp_max_c: float
    temp_min_c: float
    precip_mm: float
    rh_pct: float
    wind_ms: float
    solar_mj_m2_day: float


class TimeSeriesPoint(BaseModel):
    date: date
    value: float | None


class TimeSeries(BaseModel):
    variable: str
    unit: str
    freq: str
    agg: str
    points: list[TimeSeriesPoint]
