"""Application settings, overridable with FARMWISE_* environment variables."""
from functools import lru_cache
from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict

REPO_ROOT = Path(__file__).resolve().parents[3]
DATA_DIR = REPO_ROOT / "Data"


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_prefix="FARMWISE_", env_file=".env", extra="ignore")

    app_name: str = "FarmWise API"
    version: str = "0.1.0"
    api_prefix: str = "/api/v1"

    data_dir: Path = DATA_DIR
    unified_dataset: Path = DATA_DIR / "Processed_Data" / "FarmWise_Unified_Dataset.csv"
    crop_requirements: Path = DATA_DIR / "Crop_Requirements" / "FarmWise_Crop_Requirements_Complete.csv"
    rotation_traits: Path = DATA_DIR / "Crop_Requirements" / "FarmWise_Rotation_Crop_Traits.csv"
    aoi_geojson: Path = DATA_DIR / "Documentation" / "AOI" / "El_Zankalon_AOI.geojson"
    scripts_dir: Path = DATA_DIR / "scripts"

    site_name: str = "El-Zankalon, Sharqia, Egypt"

    # Comma-separated list, e.g. "http://localhost:5173,https://farmwise.app"
    cors_origins: str = "*"

    @property
    def cors_origin_list(self) -> list[str]:
        return [o.strip() for o in self.cors_origins.split(",") if o.strip()]


@lru_cache
def get_settings() -> Settings:
    return Settings()
