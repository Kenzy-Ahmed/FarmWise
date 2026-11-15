from app.data.store import DataStore
from app.services.common import MONTH_NAMES, clean


def health_status(ndvi: float | None) -> str | None:
    if ndvi is None:
        return None
    if ndvi < 0.2:
        return "Bare / very sparse vegetation"
    if ndvi < 0.4:
        return "Sparse or stressed vegetation"
    if ndvi < 0.6:
        return "Moderate vegetation"
    return "Dense, healthy vegetation"


def _composites(store: DataStore, start=None, end=None):
    df = store.between(start, end).dropna(subset=["ndvi_composite_date", "ndvi_mean"])
    return (
        df.groupby("ndvi_composite_date")
        .agg(
            ndvi_mean=("ndvi_mean", "first"),
            ndvi_median=("ndvi_median", "first"),
            ndvi_std=("ndvi_std", "first"),
            cov=("ndvi_pixel_coverage_frac", "first"),
            low=("ndvi_low_coverage_flag", "max"),
        )
        .reset_index()
        .sort_values("ndvi_composite_date")
    )


def ndvi_series(store: DataStore, start=None, end=None, include_low_coverage: bool = True) -> dict:
    c = _composites(store, start, end)
    if not include_low_coverage:
        c = c[~c["low"].astype(bool)]
    points = [
        {
            "composite_date": r.ndvi_composite_date.date(),
            "ndvi_mean": clean(r.ndvi_mean, 4),
            "ndvi_median": clean(r.ndvi_median, 4),
            "ndvi_std": clean(r.ndvi_std, 4),
            "pixel_coverage_frac": clean(r.cov, 4),
            "low_coverage": bool(r.low),
        }
        for r in c.itertuples()
    ]
    latest = points[-1] if points else None
    return {
        "count": len(points),
        "mean": clean(c["ndvi_mean"].mean(), 4) if points else None,
        "latest": latest,
        "health_status": health_status(latest["ndvi_mean"]) if latest else None,
        "points": points,
    }


def ndvi_monthly(store: DataStore, start=None, end=None) -> list[dict]:
    c = _composites(store, start, end)
    c = c[~c["low"].astype(bool)]
    m = c.groupby(c["ndvi_composite_date"].dt.month)["ndvi_mean"].mean()
    return [{"month": int(k), "month_name": MONTH_NAMES[int(k)], "ndvi_mean": clean(v, 4)} for k, v in m.items()]
