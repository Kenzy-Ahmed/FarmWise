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
| GET | `/dashboard` | **One call for the home screen**: climate, soil, NDVI, moisture, top 3 crops |
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

## Connecting the frontend

CORS is open (`*`) by default for the demo. To lock it down, set
`FARMWISE_CORS_ORIGINS=http://localhost:5173` (see `.env.example`).

```js
const API = import.meta.env.VITE_API_URL ?? "http://localhost:8000/api/v1";
const dashboard = await fetch(`${API}/dashboard`).then(r => r.json());
```

## Docker

```bash
docker build -f backend/Dockerfile -t farmwise-api .   # from repo root
docker run -p 8000:8000 farmwise-api
```
