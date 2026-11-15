import pandas as pd

from app.data.store import DataStore
from app.services.common import clean

GAEZ_KEYS = {
    "hilm": "high_input_irrigated_pct",
    "hrlm": "high_input_rainfed_pct",
    "lilm": "low_input_irrigated_pct",
    "lrlm": "low_input_rainfed_pct",
}


def gaez_for(store: DataStore, code: str) -> dict | None:
    out = {}
    for suffix, key in GAEZ_KEYS.items():
        col = f"gaez_{code.lower()}_{suffix}_suitable_pct"
        if col not in store.daily.columns:
            return None
        out[key] = clean(store.daily[col].median(), 2)
    return out


def _crop_dict(store: DataStore, r: pd.Series) -> dict:
    return {
        "code": r.crop_code,
        "name": r.crop_name,
        "scientific_name": r.scientific_name,
        "temp_opt_min": r.temp_opt_min,
        "temp_opt_max": r.temp_opt_max,
        "rainfall_opt_min_annual_mm": r.rainfall_opt_min_annual_mm,
        "rainfall_opt_max_annual_mm": r.rainfall_opt_max_annual_mm,
        "soil_ph_opt_min": r.soil_ph_opt_min,
        "soil_ph_opt_max": r.soil_ph_opt_max,
        "soil_texture": r.soil_texture,
        "soil_drainage": r.soil_drainage,
        "water_system": r.water_system,
        "water_need_min_mm_season": r.crop_water_need_min_mm_season,
        "water_need_max_mm_season": r.crop_water_need_max_mm_season,
        "drought_sensitivity": r.drought_sensitivity,
        "notes": r.data_notes,
        "sources": [u for u in (r.source_url, r.water_source_url) if isinstance(u, str)],
        "gaez_suitability": gaez_for(store, r.crop_code),
    }


def list_crops(store: DataStore) -> list[dict]:
    return [_crop_dict(store, r) for _, r in store.crops.iterrows()]


def find_crop_rows(store: DataStore, keys: list[str]) -> pd.DataFrame:
    wanted = {k.strip().lower() for k in keys}
    c = store.crops
    mask = c["crop_code"].str.lower().isin(wanted) | c["crop_name"].str.lower().isin(wanted)
    return c[mask]


def get_crop(store: DataStore, key: str) -> dict | None:
    rows = find_crop_rows(store, [key])
    return None if rows.empty else _crop_dict(store, rows.iloc[0])
