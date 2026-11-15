# FarmWise Backend (FastAPI)

REST API that serves the processed NASA / FAO data for El-Zankalon and runs the
crop-recommendation model in `Data/scripts/`.

## Quick start

```bash
cd backend
pip install -r requirements.txt
./run.sh            # or: uvicorn app.main:app --reload
```

Open **http://localhost:8000/docs** for interactive Swagger docs (try every endpoint in the browser).

Run tests: `python -m pytest`

## Architecture

```
backend/
├── app/
│   ├── main.py              # FastAPI app factory, CORS, router registration
│   ├── core/config.py       # Settings (paths, CORS) – override with FARMWISE_* env vars
│   ├── data/store.py        # Loads the unified dataset + crop table once, cached in memory
│   ├── services/            # Pure business logic (no HTTP) – easy to test & reuse
│   │   ├── climate.py       #   summaries, monthly climatology, resampled time series
│   │   ├── soil.py          #   SoilGrids profile, USDA texture class, SMAP moisture
│   │   ├── vegetation.py    #   MODIS NDVI composites + health status
│   │   ├── crops.py         #   crop requirements + GAEZ suitability
│   │   ├── insights.py      #   dashboard metrics + risk indices (drought, heat, erosion…)
│   │   ├── seasons.py       #   monthly pattern + vulnerable / planting windows
│   │   ├── rotations.py     #   crop-sequence scoring (uses FarmWise_Rotation_Crop_Traits.csv)
│   │   ├── chat.py          #   rule-based Q&A over the data (seam for an LLM later)
│   │   └── recommendations.py  # wraps Data/scripts/{crop_suitability,scoring}.py
│   ├── schemas/             # Pydantic models = the API contract for the frontend
│   └── api/routes/          # Thin HTTP layer, one file per domain
└── tests/                   # pytest + TestClient
```

```
Frontend ──HTTP/JSON──▶ api/routes ──▶ services ──▶ data/store ──▶ Data/Processed_Data/*.csv
                                          │
                                          └──▶ Data/scripts (team's scoring model)
```

Design choices:
- **Single source of truth for the model** – the recommendation service imports the
  team's `crop_suitability.py` and `scoring.py`; a test asserts the API output equals
  `Data/Processed_Data/FarmWise_Crop_Recommendations.csv`.
- **In-memory data** – the dataset is ~4k rows, so pandas in memory is fast and has no
  infra. `data/store.py` is the only place that knows about files; swap it for a
  database later without changing routes.
- **Services vs routes** – routes only handle HTTP concerns; logic lives in services.

## Endpoints (`/api/v1`)

| Method | Path | Description |
|---|---|---|
| GET | `/health` | Status + loaded data range |
| GET | `/location` | Site name, center, bbox, AOI GeoJSON, data sources |
| GET | `/dashboard` | **One call for the dashboard**: metrics, risks, climate, soil, NDVI, moisture, top 3 crops |
| GET | `/insights` | Dashboard metric cards + 0-100 risk indices (each with its formula in `method`) |
| GET | `/seasons` | 12-month pattern (rain, temp, ET₀, NDVI, bare/crop) + vulnerable/planting windows |
| POST | `/rotations` | Score the farmer's rotation vs suggested strategies, e.g. `{"rotation": "Wheat → Maize → Fallow", "priorities": ["soil","res"]}` |
| GET | `/rotations/crops` | Crops the rotation engine knows |
| POST | `/chat` | Rule-based assistant that answers with the site's data: `{"message": "Is my land water stressed?"}` |
| GET | `/climate/summary?start=&end=` | Mean temps, annual rainfall, hottest/coldest month |
| GET | `/climate/monthly` | 12-month climatology (temp, rain, RH, wind, solar) |
| GET | `/climate/variables` | Variables available for time series |
| GET | `/climate/timeseries?variable=temp_mean&freq=M&agg=&start=&end=` | Chart data; `freq` = D/W/M/Y |
| GET | `/soil` | pH (+class), SOC, N, CEC, bulk density, texture (+USDA class) |
| GET | `/soil/moisture?start=&end=` | SMAP soil moisture series |
| GET | `/vegetation/ndvi?start=&end=&include_low_coverage=` | MODIS NDVI composites + health status |
| GET | `/vegetation/ndvi/monthly` | Average NDVI per calendar month (seasonality) |
| GET | `/crops` | All crops with requirements + GAEZ suitability |
| GET | `/crops/{code_or_name}` | One crop, e.g. `/crops/MZE` or `/crops/wheat` |
| GET | `/recommendations?top=3` | Ranked crops with scores, planting months, irrigation estimate |
| POST | `/recommendations` | Same, with custom inputs (below) |

`POST /recommendations` body (all fields optional):
```json
{
  "start_year": 2020,
  "end_year": 2025,
  "soil_ph": 6.8,
  "weights": {"temperature": 0.4, "soil": 0.2, "rainfall": 0.2, "water": 0.2},
  "crops": ["MZE", "Wheat", "COW"]
}
```

## How the Flutter app uses the API

`lib/services/api_client.dart` talks to the backend; `lib/models/app_state.dart`
loads everything at startup (`loadAll`) and falls back to the original demo values
if the backend is unreachable (the status dot turns red and shows **Retry**).

| Screen | Endpoint(s) |
|---|---|
| Dashboard | `/dashboard` (metrics, risks), `/recommendations` (best-suited crops) |
| Land analysis | `/dashboard` → soil profile, layer values; "Get rotation advice" → `/rotations` |
| Rotation advisor / Compare | `POST /rotations` (re-scored when the rotation text changes; priority weighting is client-side) |
| Seasons | `/seasons` |
| Why this? | `/recommendations` (top crop strengths/limits), `/location` (data sources) |
| Ask FarmWise | `POST /chat` |

Derived values: reference evapotranspiration (ET₀) uses Hargreaves-Samani (FAO-56 eq. 52)
from NASA POWER temperatures. Rotation indicators combine site climate (temperature fit,
season rainfall) with crop traits in `Data/Crop_Requirements/FarmWise_Rotation_Crop_Traits.csv`
(FAO indicative water needs; `income_index` is illustrative). The map heat-grid on the Land
screen is still illustrative: the data is an area average, not a per-pixel grid.

CORS is open (`*`) by default for the demo. To lock it down, set
`FARMWISE_CORS_ORIGINS=http://localhost:8080` (see `.env.example`).

## Docker

```bash
docker build -f backend/Dockerfile -t farmwise-api .   # from repo root
docker run -p 8000:8000 farmwise-api
```
