"""Loads the processed datasets once and keeps them in memory.

The unified dataset is small (~4k daily rows), so an in-memory pandas frame is
the fastest path for a demo. Swap this module for a DB-backed repository later
without touching the routes.
"""
import json
from dataclasses import dataclass
from functools import lru_cache

import pandas as pd

from app.core.config import get_settings


@dataclass(frozen=True)
class DataStore:
    daily: pd.DataFrame
    crops: pd.DataFrame
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


@lru_cache
def get_store() -> DataStore:
    s = get_settings()
    daily = pd.read_csv(s.unified_dataset, parse_dates=["date", "ndvi_composite_date"])
    daily = daily.sort_values("date").reset_index(drop=True)
    crops = pd.read_csv(s.crop_requirements)
    with open(s.aoi_geojson, encoding="utf-8") as f:
        aoi = json.load(f)
    return DataStore(daily=daily, crops=crops, aoi=aoi)
