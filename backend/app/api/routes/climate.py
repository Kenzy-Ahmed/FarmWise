from typing import Literal

from fastapi import APIRouter, Depends, HTTPException, Query

from app.api.deps import DateFilter, store
from app.data.store import DataStore
from app.schemas.climate import ClimateSummary, MonthlyClimate, TimeSeries
from app.services import climate as svc

router = APIRouter(prefix="/climate", tags=["climate"])


@router.get("/summary", response_model=ClimateSummary)
def climate_summary(f: DateFilter = Depends(), s: DataStore = Depends(store)):
    try:
        return svc.summary(s, f.start, f.end)
    except ValueError as e:
        raise HTTPException(404, str(e))


@router.get("/monthly", response_model=list[MonthlyClimate],
            summary="Long-term monthly climatology (mean per calendar month)")
def climate_monthly(f: DateFilter = Depends(), s: DataStore = Depends(store)):
    return svc.monthly_climatology(s, f.start, f.end)


@router.get("/variables", summary="Variables available for /climate/timeseries")
def variables():
    return [{"variable": k, "unit": u, "default_agg": a} for k, (_, u, a) in svc.VARIABLES.items()]


@router.get("/timeseries", response_model=TimeSeries)
def climate_timeseries(
    variable: str = Query("temp_mean", description="See /climate/variables"),
    freq: Literal["D", "W", "M", "Y"] = Query("M", description="D=daily, W=weekly, M=monthly, Y=yearly"),
    agg: Literal["mean", "sum", "min", "max"] | None = Query(None, description="Aggregation (defaults per variable)"),
    f: DateFilter = Depends(),
    s: DataStore = Depends(store),
):
    try:
        return svc.timeseries(s, variable, freq, agg, f.start, f.end)
    except KeyError:
        raise HTTPException(404, f"Unknown variable '{variable}'. See /climate/variables")
