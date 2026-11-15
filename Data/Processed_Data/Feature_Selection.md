
# FarmWise Feature Selection Report

## 1. Dataset Overview

- Dataset: FarmWise_Unified_Dataset.csv
- Records: 4018
- Columns: 61
- Study Area: El Zankalon, Sharqia, Egypt
- Time Range: 2015–2025

## 2. Feature Groups

| Group | Features | Role |
|---|---:|---|
| Weather | 6 | Environmental conditions |
| Rainfall | 2 | Water availability |
| Soil | 8 | Soil properties |
| SMAP | 2 | Soil moisture information |
| GAEZ | 28 | Crop suitability reference |
| NDVI | 9 | Vegetation monitoring |

## 3. Feature Selection Decisions

- Weather: Retained as dynamic environmental features.
- Rainfall: POWER and GPM retained separately.
- Soil: Retained as static soil information.
- SMAP: Retained as supplementary information due to 66.45% missing values.
- GAEZ: Retained as crop suitability reference information.
- NDVI: Retained for vegetation monitoring and optional NDVI prediction.

## 4. Limitations

- Soil and GAEZ features are constant within the current study area dataset.
- SMAP has a high missing-value percentage.
- NDVI observations are composite-based, not independent daily measurements.
- No verified crop-label target is currently available.

## 5. Final Decision

The features provide environmental information and crop suitability
references for the recommendation workflow.

Final input selection should be coordinated with the Crop
Recommendation team.
