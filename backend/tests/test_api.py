import csv
from pathlib import Path

import pytest

API = "/api/v1"
REPO = Path(__file__).resolve().parents[2]


def test_health(client):
    r = client.get(f"{API}/health")
    assert r.status_code == 200
    body = r.json()
    assert body["status"] == "ok"
    assert body["rows_loaded"] > 4000


def test_location(client):
    body = client.get(f"{API}/location").json()
    assert body["bbox"] == [31.35, 30.44, 31.55, 30.64]
    assert body["aoi"]["type"] == "FeatureCollection"


@pytest.mark.parametrize("path", [
    "/climate/summary", "/climate/monthly", "/climate/variables", "/soil", "/soil/moisture",
    "/vegetation/ndvi", "/vegetation/ndvi/monthly", "/crops", "/crops/MZE", "/crops/wheat",
    "/recommendations", "/dashboard",
])
def test_endpoints_ok(client, path):
    assert client.get(API + path).status_code == 200


def test_climate_monthly_has_12_months(client):
    months = client.get(f"{API}/climate/monthly").json()
    assert [m["month"] for m in months] == list(range(1, 13))


def test_timeseries_filters_and_aggregates(client):
    r = client.get(f"{API}/climate/timeseries", params={"variable": "precip", "freq": "Y",
                                                       "start": "2020-01-01", "end": "2021-12-31"})
    pts = r.json()["points"]
    assert [p["date"] for p in pts] == ["2020-01-01", "2021-01-01"]


def test_timeseries_unknown_variable(client):
    assert client.get(f"{API}/climate/timeseries", params={"variable": "nope"}).status_code == 404


def test_unknown_crop(client):
    assert client.get(f"{API}/crops/XYZ").status_code == 404


def test_soil_texture(client):
    soil = client.get(f"{API}/soil").json()
    assert sum(soil["texture_normalized"].values()) == pytest.approx(100, abs=0.2)
    assert soil["texture_class"]


def test_recommendations_match_reference_csv(client):
    """API ranking must match the team's committed FarmWise_Crop_Recommendations.csv."""
    with open(REPO / "Data/Processed_Data/FarmWise_Crop_Recommendations.csv", encoding="utf-8-sig") as f:
        expected = [(row["crop_name"], float(row["overall_score"])) for row in csv.DictReader(f)]
    recs = client.get(f"{API}/recommendations").json()["recommendations"]
    got = [(r["crop_name"], r["overall_score"]) for r in recs]
    assert [g[0] for g in got] == [e[0] for e in expected]
    for (_, g), (_, e) in zip(got, expected):
        assert g == pytest.approx(e, abs=0.01)


def test_recommendations_top(client):
    assert len(client.get(f"{API}/recommendations", params={"top": 3}).json()["recommendations"]) == 3


def test_recommendations_custom_ph_and_weights(client):
    base = client.get(f"{API}/recommendations").json()
    r = client.post(f"{API}/recommendations", json={
        "soil_ph": 6.5, "weights": {"temperature": 1, "soil": 0, "rainfall": 0, "water": 0},
    })
    assert r.status_code == 200
    body = r.json()
    assert body["site"]["soil_ph_source"] == "User provided"
    # temperature-only weighting -> overall == temperature score
    for rec in body["recommendations"]:
        assert rec["overall_score"] == pytest.approx(rec["scores"]["temperature"], abs=0.01)
    assert body != base


def test_recommendations_crop_filter(client):
    r = client.post(f"{API}/recommendations", json={"crops": ["MZE", "Wheat"]})
    assert {x["crop_code"] for x in r.json()["recommendations"]} == {"MZE", "WHE"}


def test_recommendations_bad_year_range(client):
    assert client.post(f"{API}/recommendations", json={"start_year": 2050}).status_code == 422


def test_cors_header(client):
    r = client.get(f"{API}/health", headers={"Origin": "http://localhost:5173"})
    assert r.headers.get("access-control-allow-origin") in ("*", "http://localhost:5173")
