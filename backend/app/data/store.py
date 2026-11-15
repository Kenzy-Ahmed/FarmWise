"""Loads the processed datasets once and keeps them in memory.

The unified dataset is small (~4k daily rows), so an in-memory pandas frame is
the fastest path for a demo. Swap this module for a DB-backed repository later
without touching the routes.
"""
import json
from dataclasses import dataclass
from functools import lru_cache

import numpy as np
import pandas as pd

from app.core.config import get_settings


@dataclass(frozen=True)
class DataStore:
    daily: pd.DataFrame
    crops: pd.DataFrame
    traits: pd.DataFrame
    aoi: dict

    @property
    def date_min(self) -> pd.Timestamp:
        return self.daily["date"].min()

    @property
    def date_max(self) -> pd.Timestamp:
        return self.daily["date"].max()

    def between(self, start=None, end=None) -> pd.DataFrame:
        df = self.daily
        if start is not None:
            df = df[df["date"] >= pd.Timestamp(start)]
        if end is not None:
            df = df[df["date"] <= pd.Timestamp(end)]
        return df


def hargreaves_et0(df: pd.DataFrame) -> pd.Series:
    """Reference evapotranspiration (mm/day), Hargreaves-Samani (FAO-56 eq. 52).

    Extraterrestrial radiation Ra follows FAO-56 eqs. 21-25 from latitude and
    day of year.
    """
    lat = np.radians(df["aoi_center_lat"].to_numpy())
    j = df["day_of_year"].to_numpy()
    dr = 1 + 0.033 * np.cos(2 * np.pi * j / 365)
    decl = 0.409 * np.sin(2 * np.pi * j / 365 - 1.39)
    ws = np.arccos(np.clip(-np.tan(lat) * np.tan(decl), -1, 1))
    ra = (24 * 60 / np.pi) * 0.0820 * dr * (
        ws * np.sin(lat) * np.sin(decl) + np.cos(lat) * np.cos(decl) * np.sin(ws)
    )  # MJ m-2 day-1
    tmax, tmin, tmean = df["power_t2m_max_c"], df["power_t2m_min_c"], df["power_t2m_mean_c"]
    et0 = 0.0023 * 0.408 * ra * (tmean + 17.8) * np.sqrt((tmax - tmin).clip(lower=0))
    return et0.round(3)


@lru_cache
def get_store() -> DataStore:
    s = get_settings()
    daily = pd.read_csv(s.unified_dataset, parse_dates=["date", "ndvi_composite_date"])
    daily = daily.sort_values("date").reset_index(drop=True)
    crops = pd.read_csv(s.crop_requirements)
    traits = pd.read_csv(s.rotation_traits)
    daily["et0_mm_day"] = hargreaves_et0(daily)
    with open(s.aoi_geojson, encoding="utf-8") as f:
        aoi = json.load(f)
    return DataStore(daily=daily, crops=crops, traits=traits, aoi=aoi)
