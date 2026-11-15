
import pandas as pd


def load_data(unified_path, crops_path):
    """Load environmental data and crop requirements."""

    df = pd.read_csv(unified_path)
    crops = pd.read_csv(crops_path)

    return df, crops


def analyze_crop_suitability(df, crops):
    """Analyze temperature, rainfall, soil pH and water demand."""

    df = df.copy()

    df["date"] = pd.to_datetime(df["date"])
    df["year"] = df["date"].dt.year
    df["month"] = df["date"].dt.month

    # Annual climate
    annual = df.groupby("year").agg(
        annual_rainfall=("power_precip_mm_day", "sum")
    )

    # Monthly temperature
    monthly = df.groupby("month").agg(
        mean_temp=("power_t2m_mean_c", "mean")
    )

    avg_rainfall = annual["annual_rainfall"].mean()
    site_ph = df["soil_ph"].median()

    results = []

    for _, crop in crops.iterrows():

        # Temperature matching
        suitable_months = monthly[
            monthly["mean_temp"].between(
                crop["temp_opt_min"],
                crop["temp_opt_max"]
            )
        ].index.tolist()

        temp_score = len(suitable_months) / 12 * 100

        # Rainfall analysis
        rainfall_gap = max(
            0,
            crop["rainfall_opt_min_annual_mm"] - avg_rainfall
        )

        rainfall_coverage = (
            avg_rainfall /
            crop["rainfall_opt_min_annual_mm"] * 100
        )

        # Soil pH
        ph_deviation = max(
            crop["soil_ph_opt_min"] - site_ph,
            0,
            site_ph - crop["soil_ph_opt_max"]
        )

        # Water demand
        avg_water = (
            crop["crop_water_need_min_mm_season"] +
            crop["crop_water_need_max_mm_season"]
        ) / 2

        results.append({
            "crop_name": crop["crop_name"],
            "number_of_months": len(suitable_months),
            "temp_score": round(temp_score, 2),
            "rainfall_gap": round(rainfall_gap, 2),
            "rainfall_coverage_pct": round(
                rainfall_coverage, 2
            ),
            "ph_deviation": round(ph_deviation, 2),
            "avg_water_need_mm_season": avg_water,
            "irrigation_needed": rainfall_gap > 0
        })

    return pd.DataFrame(results)
