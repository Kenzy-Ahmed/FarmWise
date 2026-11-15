"""Environmental indicators and risk indices for the farmer dashboard.

Every risk is a transparent 0-100 index; the formula is returned with the value
so the frontend can show "how was this calculated".
"""
import pandas as pd

from app.data.store import DataStore
from app.services.common import clean

# Approximate volumetric field capacity of a clay-loam topsoil (m3/m3)
FIELD_CAPACITY = 0.32


def _clip(v: float) -> float:
    return max(0.0, min(100.0, float(v)))


def _level(v: float) -> str:
    return "High" if v >= 65 else "Medium" if v >= 40 else "Low"


def _latest_window(df: pd.DataFrame, col: str, days: int):
    sub = df.dropna(subset=[col])
    if sub.empty:
        return sub, None
    end = sub["date"].max()
    return sub[sub["date"] > end - pd.Timedelta(days=days)], end


def metrics(store: DataStore) -> list[dict]:
    d = store.daily
    w30, t_end = _latest_window(d, "power_t2m_mean_c", 30)
    temp = w30["power_t2m_mean_c"].mean()
    rain30 = w30["power_precip_mm_day"].sum()
    et0_30 = w30["et0_mm_day"].mean()

    sm = d.dropna(subset=["smap_soil_moisture_am_m3m3"]).iloc[-1]
    nd = d.dropna(subset=["ndvi_mean"]).iloc[-1]

    annual = d.groupby("year").agg(p=("power_precip_mm_day", "sum"), e=("et0_mm_day", "sum"))
    rain_cover = annual["p"].mean() / annual["e"].mean() * 100

    as_of = t_end.date()
    return [
        {
            "key": "temperature", "label": "Average temperature", "value": clean(temp, 1), "unit": "°C",
            "display": f"{temp:.1f} °C", "bar": _clip(temp / 45 * 100), "as_of": as_of, "source": "NASA POWER",
            "description": "Mean air temperature over the last 30 days. Warm days speed up growth but raise water needs.",
        },
        {
            "key": "rainfall", "label": "Recent rainfall", "value": clean(rain30, 1), "unit": "mm / 30 days",
            "display": f"{rain30:.0f} mm / 30 days", "bar": _clip(rain30 / 100 * 100), "as_of": as_of,
            "source": "NASA POWER",
            "description": "Very little rain means crops depend on irrigation." if rain30 < 20
            else "Recent rain is helping to recharge the soil.",
        },
        {
            "key": "soil_moisture", "label": "Soil moisture", "value": clean(sm.smap_soil_moisture_am_m3m3, 3),
            "unit": "m³/m³", "display": f"{sm.smap_soil_moisture_am_m3m3:.2f} m³/m³",
            "bar": _clip(sm.smap_soil_moisture_am_m3m3 / FIELD_CAPACITY * 100), "as_of": sm.date.date(),
            "source": "NASA SMAP",
            "description": "Low moisture early in the season risks poor germination."
            if sm.smap_soil_moisture_am_m3m3 < 0.15 else "Top-soil moisture is adequate for germination.",
        },
        {
            "key": "ndvi", "label": "Vegetation health (NDVI)", "value": clean(nd.ndvi_mean, 2), "unit": "",
            "display": f"{nd.ndvi_mean:.2f}", "bar": _clip(nd.ndvi_mean * 100), "as_of": nd.ndvi_composite_date.date(),
            "source": "NASA MODIS",
            "description": "A lower value suggests crops or cover are under stress." if nd.ndvi_mean < 0.5
            else "Crops and cover are green and growing well.",
        },
        {
            "key": "et0", "label": "Evapotranspiration", "value": clean(et0_30, 2), "unit": "mm/day",
            "display": f"{et0_30:.1f} mm/day", "bar": _clip(et0_30 / 8 * 100), "as_of": as_of,
            "source": "Derived (Hargreaves, NASA POWER)",
            "description": "How much water plants and soil lose each day (reference ET₀).",
        },
        {
            "key": "water_availability", "label": "Rain vs. water demand", "value": clean(rain_cover, 1), "unit": "%",
            "display": f"{rain_cover:.0f}% of ET₀", "bar": _clip(rain_cover), "as_of": as_of,
            "source": "Derived (NASA POWER)",
            "description": "Share of yearly evaporative demand covered by rain; the rest must come from irrigation.",
        },
    ]


def risks(store: DataStore) -> list[dict]:
    d = store.daily
    n_years = d["year"].nunique()

    annual_p = d.groupby("year")["power_precip_mm_day"].sum().mean()
    annual_e = d.groupby("year")["et0_mm_day"].sum().mean()
    drought = _clip((1 - annual_p / annual_e) * 100)

    hot_share = (d["power_t2m_max_c"] >= 35).mean()
    heat = _clip(hot_share / 0.25 * 100)

    sm = d["smap_soil_moisture_am_m3m3"].dropna()
    sm_recent = sm.tail(10).mean()
    water = _clip((1 - sm_recent / FIELD_CAPACITY) * 100)

    heavy_days = (d["power_precip_mm_day"] >= 20).sum() / n_years
    extreme = _clip(heavy_days / 5 * 100)

    comp = d.dropna(subset=["ndvi_composite_date"]).groupby("ndvi_composite_date")["ndvi_mean"].first()
    bare_share = (comp < 0.4).mean()
    erosion = _clip(bare_share * 100)

    def r(key, label, value, description, method):
        return {"key": key, "label": label, "value": round(value), "level": _level(value),
                "description": description, "method": method}

    return [
        r("drought", "Drought risk", drought, "Long dry spells can cut yields without irrigation.",
          f"1 − rain/ET₀ (annual rain {annual_p:.0f} mm vs ET₀ {annual_e:.0f} mm)"),
        r("heat", "Heat stress", heat, "Hot spells can damage flowering.",
          f"{hot_share * 100:.0f}% of days reach ≥35 °C (25% of days = 100)"),
        r("erosion", "Soil erosion risk", erosion, "Bare fields lose topsoil to wind and storms.",
          f"{bare_share * 100:.0f}% of 16-day NDVI composites show sparse cover (NDVI < 0.4)"),
        r("water_stress", "Water stress", water, "Crops may need more water than is available.",
          f"1 − recent SMAP moisture ({sm_recent:.2f}) / field capacity ({FIELD_CAPACITY})"),
        r("extreme_rain", "Extreme rainfall risk", extreme, "Heavy storms can waterlog fields and wash soil away.",
          f"{heavy_days:.1f} days/year with ≥20 mm rain (5 days = 100)"),
    ]
