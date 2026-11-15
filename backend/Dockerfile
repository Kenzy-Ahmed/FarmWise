# Build from the repo root:  docker build -f backend/Dockerfile -t farmwise-api .
FROM python:3.12-slim
WORKDIR /srv
COPY backend/requirements.txt backend/requirements.txt
RUN pip install --no-cache-dir -r backend/requirements.txt
COPY Data/Processed_Data/FarmWise_Unified_Dataset.csv Data/Processed_Data/
COPY Data/Crop_Requirements Data/Crop_Requirements
COPY Data/Documentation/AOI Data/Documentation/AOI
COPY Data/scripts Data/scripts
COPY backend backend
WORKDIR /srv/backend
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
