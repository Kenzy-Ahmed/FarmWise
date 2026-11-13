# GPM IMERG - Daily Precipitation Documentation

## 1. Data Source
- **Provider:** NASA GES DISC
- **Product:** GPM_3IMERGDF (IMERG Final Run, Daily), **Version V07**
- **Spatial resolution:** 0.1°
- **Bounding box (W, S, E, N):** 31.35, 30.44, 31.55, 30.64
- **Raw file:** `Raw_Data/GPM_IMERG_Daily_Precipitation_2015_2025.csv` (never modified)
- **Fill value in source:** -9999.900390625

## 2. Study Area and Period
- **Area:** El-Zankalon, Sharqia, Egypt
- **Period:** 2015-01-01 to 2025-09-30 (3926 daily records)
- **Note:** GPM ends on 2025-09-30, while NASA POWER ends on 2025-12-31.

## 3. Variables and Units
| Final column | Original name | Description | Unit |
|---|---|---|---|
| date | time | Calendar date (YYYY-MM-DD) | - |
| precip_gpm_mm_day | mean_GPM_3IMERGDF_07_precipitation | Area-averaged daily precipitation over the bounding box | mm/day |

Original units were kept.

## 4. Cleaning Steps
1. Parsed the metadata header and read the fill value from the file.
2. Converted `time` (ISO 8601) to a plain date (YYYY-MM-DD).
3. Replaced the fill value with NaN (fill-value rows found: 0). Fill values were **not** converted to zero.
4. True zero-rain days were preserved as 0.
5. Sorted by date, checked duplicates and missing dates.
6. No interpolation or imputation was applied.

## 5. Quality Rules
- Precipitation must be >= 0 mm/day.
- Values above 300 mm/day would be flagged as physically implausible for this region.
- Top values and summer (Jun-Aug) rain days were reviewed manually and **kept** (no deletion).
- Missing (NaN) is different from zero precipitation.

## 6. Final Dataset
- **Output file:** `Processed_Data/GPM_IMERG_Final.csv`
- **Shape:** 3926 rows x 2 columns
- **First date:** 2015-01-01 | **Last date:** 2025-09-30
- **Missing values:** 0
- **Duplicate dates:** 0
- **Zero-rain days:** 3412

### Final statistics
| index | count | mean | std | min | 25% | 50% | 75% | max |
|---|---|---|---|---|---|---|---|---|
| precip_gpm_mm_day | 3926.0 | 0.102 | 1.06 | 0.0 | 0.0 | 0.0 | 0.0 | 52.054 |

### Five wettest days
| date | precip_gpm_mm_day |
|---|---|
| 2020-03-12 | 52.054028 |
| 2020-03-13 | 15.16175 |
| 2019-02-06 | 13.21781 |
| 2020-01-14 | 12.670126 |
| 2016-01-07 | 12.105085 |

## 7. Notes
- IMERG is a satellite-based area average; it is not a point measurement.
- NASA POWER's `precip_mm_day` (MERRA-2 model) is a separate source; both are kept for later comparison.
- Integration with MODIS NDVI must use the overlapping date range only.
