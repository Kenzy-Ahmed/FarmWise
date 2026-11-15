from fastapi import APIRouter, Depends

from app.api.deps import store
from app.data.store import DataStore
from app.core.config import get_settings
from app.services import climate, insights, recommendations, soil, vegetation

router = APIRouter(tags=["dashboard"])


@router.get("/dashboard", summary="Everything the home screen needs in a single call")
def dashboard(s: DataStore = Depends(store)):
    ndvi = vegetation.ndvi_series(s)
    moisture = soil.moisture(s)
    rec = recommendations.recommend(s)
    return {
        "location": get_settings().site_name,
        "site": rec["site"],
        "metrics": insights.metrics(s),
        "risks": insights.risks(s),
        "climate": climate.summary(s),
        "monthly_climate": climate.monthly_climatology(s),
        "soil": soil.profile(s),
        "vegetation": {
            "latest": ndvi["latest"],
            "mean": ndvi["mean"],
            "health_status": ndvi["health_status"],
            "monthly": vegetation.ndvi_monthly(s),
        },
        "soil_moisture": {"latest": moisture["latest"], "mean_m3m3": moisture["mean_m3m3"]},
        "top_recommendations": rec["recommendations"][:3],
    }
