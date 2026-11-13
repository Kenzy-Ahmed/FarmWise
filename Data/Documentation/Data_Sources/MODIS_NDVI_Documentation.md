
# MODIS NDVI — FarmWise

## 1. Data Source Information

- **Product:** MODIS/Terra Vegetation Indices 16-Day L3 Global 250m SIN Grid V061
- **Short Name:** MOD13Q1.061
- **Satellite:** Terra
- **Provider:** NASA LP DAAC
- **Spatial Resolution:** 250m nominal
- **Temporal Resolution:** 16 days
- **Study Area:** El-Zankalon, Sharqia, Egypt
- **Data Period:** 2015-01-01 to 2025-09-30

## 2. Selected Variables

- NDVI
- Pixel Reliability
- VI Quality
- MODLAND QA
- VI Usefulness

## 3. Data Processing

The following processing steps were performed:

1. Loaded the original MODIS NetCDF file using xarray.
2. Converted MODIS sinusoidal coordinates to geographic coordinates (WGS84).
3. Applied the El-Zankalon AOI spatial filter.
4. Removed the observation dated 2014-12-19.
5. Decoded the MODIS VI Quality bit fields.
6. Applied strict quality filtering.

## 4. Quality Filtering Rules

Only observations satisfying all the following conditions were retained:

- Pixel Reliability == 0
- MODLAND QA == 0
- VI Usefulness <= 2
- NDVI is not missing

## 5. Final Dataset Statistics

- **Final Observations:** 1,836,495
- **Unique Dates:** 248
- **Date Range:** 2015-01-01 to 2025-09-30
- **Number of Columns:** 9
- **Missing Values:** 0

## 6. Final Dataset Columns

| Column | Description |
|---|---|
| time | MODIS observation date |
| ydim | MODIS projected Y coordinate |
| xdim | MODIS projected X coordinate |
| NDVI | Normalized Difference Vegetation Index |
| MODLAND_QA | MODIS land quality flag |
| VI_Usefulness | Vegetation Index usefulness level |
| Pixel_Reliability | Pixel reliability classification |
| Longitude | Geographic longitude (WGS84) |
| Latitude | Geographic latitude (WGS84) |

## 7. Output File

- **Filename:** MODIS_NDVI_Final.csv
- **Location:** Processed_Data/MODIS_NDVI/

## 8. Important Notes

- The AOI is a rectangular geographic bounding box, not an exact agricultural field boundary.
- The nominal MODIS spatial resolution is 250m.
- NDVI values were decoded using the product scale factor.
- The original raw NetCDF file was preserved unchanged.
- Quality filtering was applied to create a separate analysis-ready dataset.

## 9. Validation

The final dataset passed the following checks:

- No missing values in the final columns.
- All MODLAND QA values equal 0.
- All Pixel Reliability values equal 0.
- All VI Usefulness values are less than or equal to 2.
- All NDVI values are within the expected range of -1 to 1.
