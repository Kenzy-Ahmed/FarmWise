
import pandas as pd


def rank_crops(suitability_df):

    required_columns = [
        "crop_name",
        "temp_score",
        "rainfall_coverage_pct",
        "ph_deviation",
        "avg_water_need_mm_season",
        "irrigation_needed"
    ]

    missing = [
        col for col in required_columns
        if col not in suitability_df.columns
    ]

    if missing:
        raise ValueError(f"Missing columns: {missing}")

    ranked = suitability_df.copy()

    # 1. Temperature score
    ranked["temperature_score"] = ranked["temp_score"]

    # 2. Soil pH score
    ranked["soil_score"] = (
        100 / (1 + ranked["ph_deviation"])
    )

    # 3. Rainfall coverage score
    ranked["rainfall_score"] = (
        ranked["rainfall_coverage_pct"].clip(0, 100)
    )

    # 4. Relative water efficiency score
    min_water = ranked["avg_water_need_mm_season"].min()

    ranked["water_score"] = (
        min_water / ranked["avg_water_need_mm_season"] * 100
    )

    # 5. Weighted overall score (same original weights)
    ranked["overall_score"] = (
        ranked["temperature_score"] * 0.40
        + ranked["soil_score"] * 0.20
        + ranked["rainfall_score"] * 0.20
        + ranked["water_score"] * 0.20
    )

    # 6. Rank crops
    ranked = ranked.sort_values(
        by="overall_score",
        ascending=False
    ).reset_index(drop=True)

    ranked.insert(0, "rank", range(1, len(ranked) + 1))

    # 7. Explain strengths and limitations
    def explain_crop(row):

        strengths = []
        limitations = []

        # Temperature
        if row["temperature_score"] >= 60:
            strengths.append("Good temperature compatibility")
        elif row["temperature_score"] >= 40:
            strengths.append("Moderate temperature compatibility")
        else:
            limitations.append("Limited temperature compatibility")

        # Soil pH
        if row["ph_deviation"] <= 0.2:
            strengths.append("Soil pH is close to the preferred range")
        else:
            limitations.append("Soil pH is outside the preferred range")

        # Rainfall
        coverage = row["rainfall_coverage_pct"]

        if coverage >= 100:
            strengths.append("Annual rainfall meets the reference minimum")
        else:
            limitations.append(
                f"Rainfall covers only {coverage:.1f}% "
                "of the reference annual minimum"
            )

        # Irrigation
        if bool(row["irrigation_needed"]):
            limitations.append("Supplementary irrigation is required")

        # Water demand (relative comparison)
        if row["water_score"] >= 80:
            strengths.append(
                "Relatively lower seasonal water demand "
                "compared with the other evaluated crops"
            )

        water_need = row["avg_water_need_mm_season"]

        return pd.Series({
            "strengths": (
                " | ".join(strengths)
                if strengths else "No major strengths identified"
            ),
            "limitations": (
                " | ".join(limitations)
                if limitations else "No major limitations identified"
            ),
            "recommendation_notes": (
                " | ".join(strengths + limitations)
            ),
            "recommendation_summary": (
                f"{row['crop_name']} ranked #{int(row['rank'])} "
                f"with an overall score of {row['overall_score']:.2f}. "
                f"Estimated seasonal water need: {water_need:.0f} mm. "
                f"Rainfall coverage: {coverage:.1f}%."
            )
        })

    explanations = ranked.apply(explain_crop, axis=1)

    ranked = pd.concat([ranked, explanations], axis=1)

    return ranked
