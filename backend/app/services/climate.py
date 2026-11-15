import pandas as pd

from app.data.store import DataStore
from app.services.common import MONTH_NAMES, clean

# public variable name -> (column, unit, default aggregation)
VARIABLES: dict[str, tuple[str, str, str]] = {
    "temp_mean": ("power_t2m_mean_c", "°C", "mean"),
    "temp_max": ("power_t2m_max_c", "°C", "mean"),
    "temp_min": ("power_t2m_min_c", "°C", "mean"),
    "precip": ("power_precip_mm_day", "mm", "sum"),
    "precip_gpm": ("gpm_precip_mm_day", "mm", "sum"),
    "humidity": ("power_rh2m_pct", "%", "mean"),
    "wind": ("power_wind2m_ms", "m/s", "mean"),
    "solar": ("power_solar_rad_mj_m2_day", "MJ/m²/day", "mean"),
    "et0": ("et0_mm_day", "mm", "sum"),
    "soil_moisture": ("smap_soil_moisture_am_m3m3", "m³/m³", "mean"),
    "ndvi": ("ndvi_mean", "", "mean"),
}

FREQ_ALIASES = {"D": "D", "W": "W", "M": "MS", "Y": "YS"}


def summary(store: DataStore, start=None, end=None) -> dict:
    df = store.between(start, end)
    if df.empty:
        raise ValueError("No data in the requested date range")
    annual = df.groupby("year").agg(
        rain=("power_precip_mm_day", "sum"),
        rain_gpm=("gpm_precip_mm_day", lambda s: s.sum(min_count=1)),
    )
    monthly_t = df.groupby("month")["power_t2m_mean_c"].mean()
    return {
        "start": df["date"].min().date(),
        "end": df["date"].max().date(),
        "years_covered": int(df["year"].nunique()),
        "mean_temp_c": clean(df["power_t2m_mean_c"].mean(), 2),
        "mean_max_temp_c": clean(df["power_t2m_max_c"].mean(), 2),
        "mean_min_temp_c": clean(df["power_t2m_min_c"].mean(), 2),
        "hottest_month": int(monthly_t.idxmax()),
        "coldest_month": int(monthly_t.idxmin()),
        "avg_annual_rainfall_mm": clean(annual["rain"].mean(), 2),
        "avg_annual_rainfall_gpm_mm": clean(annual["rain_gpm"].mean(), 2),
        "mean_rh_pct": clean(df["power_rh2m_pct"].mean(), 2),
        "mean_wind_ms": clean(df["power_wind2m_ms"].mean(), 2),
        "mean_solar_mj_m2_day": clean(df["power_solar_rad_mj_m2_day"].mean(), 2),
    }


def monthly_climatology(store: DataStore, start=None, end=None) -> list[dict]:
    df = store.between(start, end)
    n_years = df.groupby("month")["year"].nunique()
    g = df.groupby("month")
    precip_month = g["power_precip_mm_day"].sum() / n_years  # mean monthly total
    out = []
    for m, row in g.agg(
        t=("power_t2m_mean_c", "mean"),
        tmax=("power_t2m_max_c", "mean"),
        tmin=("power_t2m_min_c", "mean"),
        rh=("power_rh2m_pct", "mean"),
        ws=("power_wind2m_ms", "mean"),
        sr=("power_solar_rad_mj_m2_day", "mean"),
    ).iterrows():
        out.append({
            "month": int(m),
            "month_name": MONTH_NAMES[int(m)],
            "temp_mean_c": clean(row.t, 2),
            "temp_max_c": clean(row.tmax, 2),
            "temp_min_c": clean(row.tmin, 2),
            "precip_mm": clean(precip_month[m], 2),
            "rh_pct": clean(row.rh, 2),
            "wind_ms": clean(row.ws, 2),
            "solar_mj_m2_day": clean(row.sr, 2),
        })
    return out


def timeseries(store: DataStore, variable: str, freq: str = "M", agg: str | None = None,
               start=None, end=None) -> dict:
    if variable not in VARIABLES:
        raise KeyError(variable)
    if freq not in FREQ_ALIASES:
        raise ValueError(f"freq must be one of {list(FREQ_ALIASES)}")
    col, unit, default_agg = VARIABLES[variable]
    agg = agg or default_agg
    if agg not in {"mean", "sum", "min", "max"}:
        raise ValueError("agg must be one of mean, sum, min, max")

    s = store.between(start, end).set_index("date")[col]
    if freq != "D":
        r = s.resample(FREQ_ALIASES[freq])
        s = r.sum(min_count=1) if agg == "sum" else getattr(r, agg)()
    return {
        "variable": variable,
        "unit": unit,
        "freq": freq,
        "agg": agg if freq != "D" else "raw",
        "points": [{"date": d.date(), "value": clean(v, 4)} for d, v in s.items()],
    }
