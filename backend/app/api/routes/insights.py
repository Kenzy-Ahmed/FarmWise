from fastapi import APIRouter, Depends

from app.api.deps import store
from app.core.config import get_settings
from app.data.store import DataStore
from app.schemas.insights import ChatRequest, ChatResponse, Insights, Rotation, RotationRequest, Seasons
from app.services import chat, insights, rotations, seasons

router = APIRouter(tags=["insights"])


@router.get("/insights", response_model=Insights, summary="Dashboard metrics and risk indicators")
def get_insights(s: DataStore = Depends(store)):
    return {"location": get_settings().site_name, "metrics": insights.metrics(s), "risks": insights.risks(s)}


@router.get("/seasons", response_model=Seasons, summary="Monthly pattern + planting / vulnerable windows")
def get_seasons(s: DataStore = Depends(store)):
    return seasons.seasons(s)


@router.get("/rotations/crops", summary="Crops known to the rotation engine")
def rotation_crops(s: DataStore = Depends(store)):
    return s.traits[["crop_name", "family", "season", "legume", "cover_crop"]].to_dict(orient="records")


@router.post("/rotations", response_model=list[Rotation],
             summary="Evaluate the farmer's rotation against suggested strategies")
def evaluate_rotations(req: RotationRequest, s: DataStore = Depends(store)):
    return rotations.strategies(s, req.rotation, req.priorities)


@router.post("/chat", response_model=ChatResponse, summary="Ask FarmWise (rule-based, data-backed answers)")
def ask(req: ChatRequest, s: DataStore = Depends(store)):
    return chat.answer(s, req.message, req.rotation, req.priorities)
