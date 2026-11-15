from fastapi import APIRouter, Depends, HTTPException, Query

from app.api.deps import store
from app.data.store import DataStore
from app.schemas.crops import Crop, RecommendationRequest, RecommendationResponse
from app.services import crops as crop_svc
from app.services import recommendations as rec_svc

router = APIRouter(tags=["crops"])


@router.get("/crops", response_model=list[Crop])
def list_crops(s: DataStore = Depends(store)):
    return crop_svc.list_crops(s)


@router.get("/crops/{key}", response_model=Crop, summary="Get a crop by code (e.g. MZE) or name")
def get_crop(key: str, s: DataStore = Depends(store)):
    crop = crop_svc.get_crop(s, key)
    if crop is None:
        raise HTTPException(404, f"Unknown crop '{key}'")
    return crop


def _run(s: DataStore, req: RecommendationRequest):
    try:
        return rec_svc.recommend(
            s, req.start_year, req.end_year, req.soil_ph, req.weights.model_dump(), req.crops
        )
    except ValueError as e:
        raise HTTPException(422, str(e))


@router.get("/recommendations", response_model=RecommendationResponse,
            summary="Ranked crop recommendations with default settings")
def recommendations(
    top: int | None = Query(None, ge=1, description="Return only the top N crops"),
    s: DataStore = Depends(store),
):
    res = _run(s, RecommendationRequest())
    if top:
        res["recommendations"] = res["recommendations"][:top]
    return res


@router.post("/recommendations", response_model=RecommendationResponse,
             summary="Ranked crop recommendations with custom inputs (year range, lab pH, weights)")
def recommendations_custom(req: RecommendationRequest, s: DataStore = Depends(store)):
    return _run(s, req)
