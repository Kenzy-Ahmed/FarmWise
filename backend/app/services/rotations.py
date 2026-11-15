"""Rotation (crop sequence) evaluation.

Scores a sequence of crops on six 0-100 indicators the frontend shows:
water demand, soil benefit, nitrogen potential, erosion reduction, climate
suitability and income potential. Climate suitability and water demand use
the site's satellite climatology; the rest come from crop traits
(Data/Crop_Requirements/FarmWise_Rotation_Crop_Traits.csv).

These are rule-based decision-support indicators, not yield predictions.
"""
import re

import pandas as pd

from app.data.store import DataStore

SEASON_MONTHS = {"winter": [11, 12, 1, 2, 3, 4], "summer": [5, 6, 7, 8, 9, 10]}
PRIORITY_KEYS = {
    "soil": "soil_benefit",
    "water": "water_demand",  # inverted
    "res": "climate_suitability",
    "n": "nitrogen_potential",
    "ero": "erosion_reduction",
    "inc": "income_potential",
}

SUGGESTED = [
    ("Soil health strategy", ["Wheat", "Faba bean", "Maize", "Clover"]),
    ("Climate resilience strategy", ["Barley", "Chickpea", "Sorghum"]),
]


def parse_sequence(text: str) -> list[str]:
    return [p.strip() for p in re.split(r"→|->|,|;|/|\+", text) if p.strip()]


def _clip(v: float) -> int:
    return int(round(max(0.0, min(100.0, v))))


class _Site:
    def __init__(self, store: DataStore):
        d = store.daily
        n_years = d.groupby("month")["year"].nunique()
        self.temp = d.groupby("month")["power_t2m_mean_c"].mean()
        self.rain = d.groupby("month")["power_precip_mm_day"].sum() / n_years


def _lookup(traits: pd.DataFrame, name: str) -> pd.Series | None:
    key = name.strip().lower()
    for _, t in traits.iterrows():
        if key == t.crop_name.lower() or key in [a.strip() for a in str(t.aliases).split(";")]:
            return t
    # loose match e.g. "clover cover crop" -> clover
    for _, t in traits.iterrows():
        if t.crop_name.lower() in key:
            return t
    return None


def _thermal_fit(site: _Site, t: pd.Series, months: list[int]) -> float:
    scores = []
    for m in months:
        temp = site.temp[m]
        if t.temp_opt_min <= temp <= t.temp_opt_max:
            scores.append(1.0)
        else:
            dist = t.temp_opt_min - temp if temp < t.temp_opt_min else temp - t.temp_opt_max
            scores.append(max(0.0, 1 - dist / 6))
    return sum(scores) / len(scores) * 100


def evaluate(store: DataStore, name: str, sequence: list[str], why: str | None = None) -> dict:
    site = _Site(store)
    traits = store.traits
    slots = []
    next_season = "winter"
    unknown = []
    for crop in sequence:
        t = _lookup(traits, crop)
        if t is None:
            unknown.append(crop)
            season = next_season
        else:
            season = t.season if t.season in SEASON_MONTHS else next_season
        next_season = "summer" if season == "winter" else "winter"
        slots.append((crop, t, season))

    known = [(c, t, s) for c, t, s in slots if t is not None and t.crop_name != "Fallow"]
    n = len(slots) or 1
    fallow_share = sum(1 for _, t, _ in slots if t is not None and t.crop_name == "Fallow") / n
    legume_share = sum(1 for _, t, _ in known if bool(t.legume)) / n
    cover_share = sum(1 for _, t, _ in known if bool(t.cover_crop)) / n
    residue_share = sum(1 for _, t, _ in known if bool(t.residue_benefit)) / n
    families = {t.family for _, t, _ in known}

    # Net irrigation need per crop: seasonal need minus ~80% of season rain
    irr, fits, incomes = [], [], []
    for c, t, s in known:
        need = (t.water_need_min_mm + t.water_need_max_mm) / 2
        rain = float(site.rain[SEASON_MONTHS[s]].sum()) * 0.8
        irr.append(max(0.0, need - rain))
        fits.append((c, _thermal_fit(site, t, SEASON_MONTHS[s])))
        incomes.append(t.income_index)

    water_demand = _clip(sum(irr) / n / 900 * 100) if known else 0
    climate = _clip(sum(f for _, f in fits) / len(fits)) if fits else 0
    nitrogen = _clip(15 + 85 * legume_share) if known else 0
    soil = _clip(30 + 45 * legume_share + 25 * cover_share + 15 * residue_share
                 + 5 * max(0, len(families) - 1) - 40 * fallow_share)
    erosion = _clip(75 * (1 - fallow_share) + 35 * cover_share)
    income = _clip(sum(incomes) / n) if known else 0

    risks = []
    if water_demand >= 60:
        risks.append("High irrigation demand, especially in the dry summer months")
    if fallow_share:
        risks.append("Bare fallow leaves soil exposed to wind erosion")
    if legume_share == 0:
        risks.append("No nitrogen-fixing crops, so more fertiliser is needed")
    poor = [c for c, f in fits if f < 50]
    if poor:
        risks.append(f"{', '.join(poor)} poorly matched to local temperatures")
    wl = [c for c, t, _ in known if bool(t.waterlogging_sensitive)]
    if wl:
        risks.append(f"{', '.join(wl)} sensitive to waterlogging on heavy clay loam")
    if unknown:
        risks.append(f"No trait data for {', '.join(unknown)} (scored as neutral)")

    if why is None:
        parts = []
        if legume_share:
            parts.append("legumes add nitrogen")
        if cover_share:
            parts.append("cover crops keep roots in the soil")
        if climate >= 70:
            parts.append("crops fit local temperatures well")
        if water_demand < 45:
            parts.append("water demand is moderate")
        why = ("This rotation works because " + ", ".join(parts) + ".") if parts else \
            "Baseline rotation used for comparison."

    return {
        "name": name,
        "sequence": sequence,
        "water_demand": water_demand,
        "soil_benefit": soil,
        "nitrogen_potential": nitrogen,
        "erosion_reduction": erosion,
        "climate_suitability": climate,
        "income_potential": income,
        "est_irrigation_mm_per_year": round(sum(irr) / n * 2),
        "crop_fit": [{"crop": c, "climate_fit": round(f)} for c, f in fits],
        "unknown_crops": unknown,
        "risk": "; ".join(risks) + "." if risks else "No major risks identified.",
        "why": why,
    }


def priority_score(rot: dict, priorities: list[str] | None) -> int:
    keys = [k for k in (priorities or []) if k in PRIORITY_KEYS] or list(PRIORITY_KEYS)
    vals = [100 - rot["water_demand"] if k == "water" else rot[PRIORITY_KEYS[k]] for k in keys]
    return round(sum(vals) / len(vals))


def _site_optimised(store: DataStore) -> list[str]:
    """Pick the best-fitting winter and summer crops, preferring a legume in one slot."""
    site = _Site(store)
    best = {}
    for season in ("winter", "summer"):
        cands = []
        for _, t in store.traits[store.traits.season == season].iterrows():
            fit = _thermal_fit(site, t, SEASON_MONTHS[season])
            need = (t.water_need_min_mm + t.water_need_max_mm) / 2
            score = 0.5 * fit + 0.3 * (100 - need / 9) + 0.2 * t.income_index
            cands.append((score, bool(t.legume), t.crop_name))
        cands.sort(reverse=True)
        best[season] = cands
    w_cereal = next(c for c in best["winter"] if not c[1])[2]
    w_legume = next(c for c in best["winter"] if c[1])[2]
    s_any = best["summer"][0][2]
    s_second = next(c for c in best["summer"] if c[2] != s_any)[2]
    return [w_cereal, s_any, w_legume, s_second]


def strategies(store: DataStore, current: str | list[str] | None = None,
               priorities: list[str] | None = None) -> list[dict]:
    seq = parse_sequence(current) if isinstance(current, str) else (current or [])
    seq = seq or ["Wheat", "Maize", "Fallow"]
    out = [evaluate(store, "Existing rotation", seq,
                    why="This is your current practice, used as the baseline for comparison.")]
    for name, s in SUGGESTED:
        out.append(evaluate(store, name, s))
    out.append(evaluate(store, "Site-optimised strategy", _site_optimised(store)))
    for r in out:
        r["score"] = priority_score(r, priorities)
    return out
