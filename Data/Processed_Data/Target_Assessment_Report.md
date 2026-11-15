
# FarmWise Target Assessment Report

## 1. Available Target Candidates

### NDVI Mean
- Source: NASA MODIS
- Variable: ndvi_mean
- Unit: Unitless NDVI
- Processing: Mean over valid pixels.
- Meaning: Represents the average vegetation index of the study area.

### GAEZ Crop Suitability
- Source: FAO GAEZ
- Variables: 28 crop suitability features.
- Meaning: Represents the suitable land share for different crops.
- Limitation: Values are static within the current study area dataset.

## 2. Target Assessment

NDVI mean can be used as a target for vegetation condition
or future NDVI prediction.

However, it does not directly identify the most suitable crop.

GAEZ provides crop suitability reference information,
but it is not an independently verified crop-label dataset.

## 3. Final Decision

The current dataset does not contain a verified ground-truth
crop label for supervised crop recommendation.

A rule-based crop suitability scoring approach is therefore
a suitable alternative for the recommendation workflow.

NDVI prediction can be treated as a separate optional task.

## 4. Limitations

- No verified crop labels are available.
- GAEZ values are static for the current study area.
- NDVI measures vegetation conditions, not crop identity.
