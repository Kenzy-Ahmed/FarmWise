# NASA POWER Daily Weather Data

## 1. Data Source

- **Source:** NASA POWER
- **Product:** Daily Point Meteorological and Solar Data
- **Website:** https://power.larc.nasa.gov/
- **Meteorological data source:** MERRA-2
- **Solar radiation data source:** CERES SYN1deg

## 2. Study Area

- **Location:** El-Zankalon, Sharqia, Egypt
- **Study period:** 2015-01-01 to 2025-12-31

## 3. Raw Data

- **Raw file:** nasa_power_elzankalon_2015_2025.csv
- **Raw folder:** G:/FarmWise/Raw_Data/NASA_POWER/
- **Original records:** 4018
- **Original columns:** 9

The raw file was preserved without modification.

## 4. Variables

| Original Variable | Processed Column | Unit | Description |
|---|---|---|---|
| YEAR + DOY | date | YYYY-MM-DD | Observation date |
| T2M | t2m_c | °C | Temperature at 2 meters |
| T2M_MAX | t2m_max_c | °C | Maximum temperature |
| T2M_MIN | t2m_min_c | °C | Minimum temperature |
| PRECTOTCORR | precip_mm_day | mm/day | Corrected precipitation |
| RH2M | rh2m_pct | % | Relative humidity at 2 meters |
| WS2M | ws2m_ms | m/s | Wind speed at 2 meters |
| ALLSKY_SFC_SW_DWN | solar_rad_mj_m2_day | MJ/m²/day | All-sky surface shortwave downward irradiance |

## 5. Data Cleaning

The following operations were performed:

1. Skipped the metadata/header lines before reading the tabular data.
2. Combined YEAR and DOY to create a proper date column.
3. Checked for missing values and invalid fill values (-999).
4. Renamed columns to descriptive names.
5. Sorted records chronologically.
6. Checked for duplicate dates.
7. Converted measurement columns to numeric data types.
8. Preserved the original raw dataset.

No outlier values were automatically deleted.

## 6. Outlier Analysis

Monthly IQR analysis using a multiplier of 3 was applied to selected variables.

| Variable | Flagged Outliers |
|---|---:|
| T2M | 0 |
| T2M_MAX | 0 |
| T2M_MIN | 0 |
| RH2M | 5 |
| WS2M | 3 |
| Solar Radiation | 35 |

A total of 43 observations were flagged.

These observations were retained because statistical outlier detection alone does not prove that a measurement is invalid.

## 7. Validation

Final validation was performed on the saved processed CSV.

- Expected daily records: 4018
- Actual daily records: 4018
- Date range: 2015-01-01 to 2025-12-31
- Missing values: 0
- Duplicate dates: 0
- Missing dates: 0
- Unexpected dates: 0

### Physical and Logical Checks

Physical ranges and temperature relationships were checked.

Validation results:

- Correct row count: PASS
- No missing values: PASS
- No duplicate dates: PASS
- No missing dates: PASS
- No unexpected dates: PASS
- Dates sorted: PASS
- Physical ranges valid: PASS
- Logical checks valid: PASS

## 8. Processed Data

- **Output file:** NASA_POWER_Final.csv
- **Output folder:** G:/FarmWise/Processed_Data/NASA_POWER/
- **Final shape:** (4018, 8)
- **Status:** All validation checks passed

## 9. Limitations and Notes

- NASA POWER provides gridded/reanalysis-based and satellite-derived estimates, not direct measurements from every farm field.
- Outliers were flagged for review but not removed automatically.
- The dataset ends on 2025-12-31. Other project datasets may have different temporal coverage.
- Further spatial and temporal alignment may be required before combining this dataset with MODIS NDVI and GPM precipitation.

---
Documentation generated: 2026-11-13
