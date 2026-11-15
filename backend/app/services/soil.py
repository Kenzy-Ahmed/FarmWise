from app.data.store import DataStore
from app.services.common import clean


def ph_class(ph: float) -> str:
    # USDA NRCS soil reaction classes
    if ph < 5.5:
        return "Strongly acidic"
    if ph < 6.5:
        return "Moderately to slightly acidic"
    if ph < 7.4:
        return "Neutral"
    if ph < 7.9:
        return "Slightly alkaline"
    if ph < 8.5:
        return "Moderately alkaline"
    return "Strongly alkaline"


def usda_texture(sand: float, silt: float, clay: float) -> str:
    """USDA texture triangle classification (inputs in % summing to 100)."""
    if silt + 1.5 * clay < 15:
        return "Sand"
    if silt + 1.5 * clay < 30:
        return "Loamy sand"
    if (7 <= clay < 20 and sand > 52 and silt + 2 * clay >= 30) or (clay < 7 and silt < 50 and silt + 2 * clay >= 30):
        return "Sandy loam"
    if 7 <= clay < 27 and 28 <= silt < 50 and sand <= 52:
        return "Loam"
    if (silt >= 50 and 12 <= clay < 27) or (50 <= silt < 80 and clay < 12):
        return "Silt loam"
    if silt >= 80 and clay < 12:
        return "Silt"
    if 20 <= clay < 35 and silt < 28 and sand > 45:
        return "Sandy clay loam"
    if 27 <= clay < 40 and 20 < sand <= 45:
        return "Clay loam"
    if 27 <= clay < 40 and sand <= 20:
        return "Silty clay loam"
    if clay >= 35 and sand > 45:
        return "Sandy clay"
    if clay >= 40 and silt >= 40:
        return "Silty clay"
    if clay >= 40 and sand <= 45 and silt < 40:
        return "Clay"
    return "Loam"


def profile(store: DataStore) -> dict:
    # Soil values are static per AOI; take the median to be robust
    d = store.daily
    clay, sand, silt = (float(d[c].median()) for c in ("soil_clay_pct", "soil_sand_pct", "soil_silt_pct"))
    total = clay + sand + silt
    norm = {"clay": clay / total * 100, "sand": sand / total * 100, "silt": silt / total * 100}
    ph = float(d["soil_ph"].median())
    return {
        "ph": clean(ph, 2),
        "ph_class": ph_class(ph),
        "soc_g_kg": clean(d["soil_soc_g_kg"].median(), 2),
        "nitrogen_g_kg": clean(d["soil_nitrogen_g_kg"].median(), 3),
        "cec_cmolc_kg": clean(d["soil_cec_cmolc_kg"].median(), 2),
        "bulk_density_kg_dm3": clean(d["soil_bdod_kg_dm3"].median(), 3),
        "clay_pct": clean(clay, 2),
        "sand_pct": clean(sand, 2),
        "silt_pct": clean(silt, 2),
        "texture_normalized": {k: clean(v, 1) for k, v in norm.items()},
        "texture_class": usda_texture(norm["sand"], norm["silt"], norm["clay"]),
    }


def moisture(store: DataStore, start=None, end=None) -> dict:
    df = store.between(start, end).dropna(subset=["smap_soil_moisture_am_m3m3"])
    points = [
        {
            "date": r.date.date(),
            "soil_moisture_m3m3": clean(r.smap_soil_moisture_am_m3m3, 4),
            "at_min_value": bool(r.smap_at_min_value_flag),
        }
        for r in df.itertuples()
    ]
    return {
        "mean_m3m3": clean(df["smap_soil_moisture_am_m3m3"].mean(), 4) if points else None,
        "latest": points[-1] if points else None,
        "points": points,
    }
