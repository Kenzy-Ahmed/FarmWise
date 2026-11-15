from app.data.store import DataStore
from app.services import climate, vegetation
from app.services.common import MONTH_NAMES


def _ranges(months: list[int]) -> str:
    """[5,6,7,8,9] -> 'May–Sep' (wraps around the year end)."""
    if not months:
        return "none"
    ms = sorted(months)
    groups, cur = [], [ms[0]]
    for m in ms[1:]:
        if m == cur[-1] + 1:
            cur.append(m)
        else:
            groups.append(cur)
            cur = [m]
    groups.append(cur)
    if len(groups) > 1 and groups[0][0] == 1 and groups[-1][-1] == 12:
        groups[0] = groups.pop() + groups[0]
    return ", ".join(MONTH_NAMES[g[0]] if len(g) == 1 else f"{MONTH_NAMES[g[0]]}–{MONTH_NAMES[g[-1]]}" for g in groups)


def seasons(store: DataStore) -> dict:
    clim = climate.monthly_climatology(store)
    ndvi = {m["month"]: m["ndvi_mean"] for m in vegetation.ndvi_monthly(store)}
    d = store.daily
    n_years = d.groupby("month")["year"].nunique()
    et0 = (d.groupby("month")["et0_mm_day"].sum() / n_years).round(1)

    months = []
    for c in clim:
        m = c["month"]
        nd = ndvi.get(m)
        months.append({
            "month": m,
            "month_name": c["month_name"],
            "rain_mm": c["precip_mm"],
            "temp_mean_c": c["temp_mean_c"],
            "temp_max_c": c["temp_max_c"],
            "et0_mm": float(et0[m]),
            "ndvi": nd,
            "field_status": "bare" if nd is not None and nd < 0.45 else "crop",
        })

    vulnerable = [m["month"] for m in months if m["rain_mm"] < 5 and m["temp_max_c"] > 29]
    bare = [m["month"] for m in months if m["field_status"] == "bare"]
    # Cool-season sowing: first month after the hot season where mean temp drops to <= 25 °C
    autumn = [m for m in months if m["month"] >= 9 and m["temp_mean_c"] <= 25]
    winter_sow = autumn[0]["month_name"] if autumn else "Nov"
    spring = [m for m in months if 3 <= m["month"] <= 6 and m["temp_mean_c"] >= 20]
    summer_sow = spring[0]["month_name"] if spring else "Apr"
    rainy = [m["month"] for m in months if m["rain_mm"] >= 5]

    return {
        "months": months,
        "insights": [
            {"title": "Vulnerable", "months": vulnerable,
             "text": f"{_ranges(vulnerable)}: little rain (<5 mm/month) and highs above 29 °C."},
            {"title": "Cover crop window", "months": bare,
             "text": f"Low vegetation cover in {_ranges(bare)}; rain mostly falls in {_ranges(rainy)}. "
                     "A cover crop in the bare period protects the soil."},
            {"title": "Rotation windows", "months": [],
             "text": f"{winter_sow} for cool-season crops (wheat, faba bean, clover); "
                     f"{summer_sow} for summer crops (maize, sorghum, cowpea)."},
        ],
    }
