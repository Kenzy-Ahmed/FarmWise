
from pathlib import Path
import sys

BASE_DIR = Path(r"G:\FarmWise\Data")

DATASET_PATH = (
    BASE_DIR / "Merged_Data" /
    "FarmWise_Unified_Dataset.csv"
)

CROP_REQUIREMENTS_PATH = (
    BASE_DIR / "Crop_Requirements" /
    "FarmWise_Crop_Requirements_Complete.csv"
)

sys.path.insert(0, str(Path(__file__).resolve().parent))

from crop_suitability import load_data, analyze_crop_suitability
from scoring import rank_crops


def get_recommendations(
    dataset_path=DATASET_PATH,
    crop_requirements_path=CROP_REQUIREMENTS_PATH
):
    df, crops = load_data(
        dataset_path,
        crop_requirements_path
    )

    suitability = analyze_crop_suitability(df, crops)

    recommendations = rank_crops(suitability)

    return recommendations


if __name__ == "__main__":

    results = get_recommendations()

    print("\nFarmWise Crop Recommendations")
    print("=" * 50)

    print(
        results[
            ["rank", "crop_name", "overall_score",
             "recommendation_notes"]
        ].to_string(index=False)
    )
