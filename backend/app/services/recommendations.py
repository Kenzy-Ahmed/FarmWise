"""Crop recommendation service.

Wraps the team's scoring engine in Data/scripts (crop_suitability.py +
scoring.py) so there is a single source of truth for the model, and enriches
its output with planting windows, irrigation estimates and GAEZ context.
"""
import sys

from app.core.config import get_settings
from app.data.store import DataStore
from app.services import crops as crop_svc
from app.services.common import MONTH_NAMES, clean

_scripts = str(get_settings().scripts_dir)
if _scripts not in sys.path:
    sys.path.insert(0, _scripts)

from crop_suitability import analyze_crop_suitability  # noqa: E402
from scoring import rank_crops  # noqa: E402


def suitability_label(score: float) -> str:
    if score >= 70:
        return "Highly suitable"
    if score >= 50:
        return "Moderately suitable"
    if score >= 40:
        return "Marginally suitable"
    return "Low suitability"


def _split(text: str, none_marker: str) -> list[str]:
    if not isinstance(text, str) or text == none_marker:
        return []
    return [t.strip() for t in text.split("|") if t.strip()]


def recommend(store: DataStore, start_year=None, end_year=None, soil_ph=None,
              weights: dict | None = None, crops: list[str] | None = None) -> dict:
    df = store.daily
    if start_year is not None:
        df = df[df["year"] >= start_year]
    if end_year is not None:
        df = df[df["year"] <= end_year]
    if df.empty:
        raise ValueError("No climate data for the requested year range")

    crop_rows = store.crops if not crops else crop_svc.find_crop_rows(store, crops)
    if crop_rows.empty:
        raise ValueError("None of the requested crops are known")

    ph_source = "SoilGrids (satellite/model)"
    if soil_ph is not None:
        df = df.assign(soil_ph=soil_ph)
        ph_source = "User provided"

    suitability = analyze_crop_suitability(df, crop_rows)
    ranked = rank_crops(suitability, weights=weights)

    # Planting window + rough irrigation estimate (seasonal need minus rain
    # falling in the thermally suitable months)
    n_years = df.groupby("month")["year"].nunique()
    monthly_temp = df.groupby("month")["power_t2m_mean_c"].mean()
    monthly_rain = df.groupby("month")["power_precip_mm_day"].sum() / n_years
    annual_rain = df.groupby("year")["power_precip_mm_day"].sum().mean()

    by_name = crop_rows.set_index("crop_name")
    results = []
    for _, r in ranked.iterrows():
        req = by_name.loc[r.crop_name]
        months = monthly_temp[monthly_temp.between(req.temp_opt_min, req.temp_opt_max)].index.tolist()
        season_rain = float(monthly_rain.loc[months].sum()) if months else 0.0
        irrigation = max(0.0, float(r.avg_water_need_mm_season) - season_rain)
        results.append({
            "rank": int(r["rank"]),
            "crop_code": req.crop_code,
            "crop_name": r.crop_name,
            "overall_score": clean(r.overall_score, 2),
            "suitability_label": suitability_label(r.overall_score),
            "scores": {
                "temperature": clean(r.temperature_score, 2),
                "soil": clean(r.soil_score, 2),
                "rainfall": clean(r.rainfall_score, 2),
                "water": clean(r.water_score, 2),
            },
            "suitable_months": [MONTH_NAMES[m] for m in months],
            "number_of_suitable_months": int(r.number_of_months),
            "rainfall_coverage_pct": clean(r.rainfall_coverage_pct, 2),
            "rainfall_gap_mm": clean(r.rainfall_gap, 2),
            "ph_deviation": clean(r.ph_deviation, 2),
            "avg_water_need_mm_season": clean(r.avg_water_need_mm_season, 1),
            "est_irrigation_need_mm_season": clean(irrigation, 1),
            "irrigation_needed": bool(r.irrigation_needed),
            "gaez_suitability": crop_svc.gaez_for(store, req.crop_code),
            "strengths": _split(r.strengths, "No major strengths identified"),
            "limitations": _split(r.limitations, "No major limitations identified"),
            "summary": r.recommendation_summary,
        })

    w = {"temperature": 0.40, "soil": 0.20, "rainfall": 0.20, "water": 0.20, **(weights or {})}
    return {
        "site": {
            "start_year": int(df["year"].min()),
            "end_year": int(df["year"].max()),
            "avg_annual_rainfall_mm": clean(annual_rain, 2),
            "soil_ph": clean(df["soil_ph"].median(), 2),
            "soil_ph_source": ph_source,
        },
        "weights": w,
        "recommendations": results,
    }
