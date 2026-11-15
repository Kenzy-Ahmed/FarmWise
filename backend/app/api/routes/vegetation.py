from fastapi import APIRouter, Depends, Query

from app.api.deps import DateFilter, store
from app.data.store import DataStore
from app.schemas.vegetation import NdviMonthly, NdviSeries
from app.services import vegetation as svc

router = APIRouter(prefix="/vegetation", tags=["vegetation"])


@router.get("/ndvi", response_model=NdviSeries)
def ndvi(
    include_low_coverage: bool = Query(True, description="Include composites flagged as low pixel coverage"),
    f: DateFilter = Depends(),
    s: DataStore = Depends(store),
):
    return svc.ndvi_series(s, f.start, f.end, include_low_coverage)


@router.get("/ndvi/monthly", response_model=list[NdviMonthly], summary="Average NDVI per calendar month")
def ndvi_monthly(f: DateFilter = Depends(), s: DataStore = Depends(store)):
    return svc.ndvi_monthly(s, f.start, f.end)
