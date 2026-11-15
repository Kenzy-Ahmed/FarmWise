from pydantic import BaseModel, Field


class GaezSuitability(BaseModel):
    high_input_irrigated_pct: float
    high_input_rainfed_pct: float
    low_input_irrigated_pct: float
    low_input_rainfed_pct: float


class Crop(BaseModel):
    code: str
    name: str
    scientific_name: str
    temp_opt_min: float
    temp_opt_max: float
    rainfall_opt_min_annual_mm: float
    rainfall_opt_max_annual_mm: float
    soil_ph_opt_min: float
    soil_ph_opt_max: float
    soil_texture: str
    soil_drainage: str
    water_system: str
    water_need_min_mm_season: float
    water_need_max_mm_season: float
    drought_sensitivity: str
    notes: str
    sources: list[str]
    gaez_suitability: GaezSuitability | None


class ScoreWeights(BaseModel):
    temperature: float = Field(0.40, ge=0)
    soil: float = Field(0.20, ge=0)
    rainfall: float = Field(0.20, ge=0)
    water: float = Field(0.20, ge=0)


class RecommendationRequest(BaseModel):
    start_year: int | None = Field(None, description="First year of climate history to use")
    end_year: int | None = Field(None, description="Last year of climate history to use")
    soil_ph: float | None = Field(None, ge=0, le=14, description="Override the satellite soil pH (e.g. from a lab test)")
    weights: ScoreWeights = Field(default_factory=ScoreWeights)
    crops: list[str] | None = Field(None, description="Restrict to these crop codes/names")


class CropScores(BaseModel):
    temperature: float
    soil: float
    rainfall: float
    water: float


class Recommendation(BaseModel):
    rank: int
    crop_code: str
    crop_name: str
    overall_score: float
    suitability_label: str
    scores: CropScores
    suitable_months: list[str]
    number_of_suitable_months: int
    rainfall_coverage_pct: float
    rainfall_gap_mm: float
    ph_deviation: float
    avg_water_need_mm_season: float
    est_irrigation_need_mm_season: float
    irrigation_needed: bool
    gaez_suitability: GaezSuitability | None
    strengths: list[str]
    limitations: list[str]
    summary: str


class SiteConditions(BaseModel):
    start_year: int
    end_year: int
    avg_annual_rainfall_mm: float
    soil_ph: float
    soil_ph_source: str


class RecommendationResponse(BaseModel):
    site: SiteConditions
    weights: ScoreWeights
    recommendations: list[Recommendation]
