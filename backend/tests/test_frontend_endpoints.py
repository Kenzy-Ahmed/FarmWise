"""Endpoints consumed by the Flutter app (lib/services/api_client.dart)."""
import pytest

API = "/api/v1"


def test_insights_shape(client):
    body = client.get(f"{API}/insights").json()
    assert {m["key"] for m in body["metrics"]} == {
        "temperature", "rainfall", "soil_moisture", "ndvi", "et0", "water_availability"}
    for m in body["metrics"]:
        assert 0 <= m["bar"] <= 100
    for r in body["risks"]:
        assert 0 <= r["value"] <= 100
        assert r["level"] in {"Low", "Medium", "High"}
        assert r["method"]


def test_dashboard_includes_metrics_and_risks(client):
    body = client.get(f"{API}/dashboard").json()
    assert body["metrics"] and body["risks"] and body["location"]


def test_seasons(client):
    body = client.get(f"{API}/seasons").json()
    assert len(body["months"]) == 12
    assert {m["field_status"] for m in body["months"]} <= {"bare", "crop"}
    assert [i["title"] for i in body["insights"]] == ["Vulnerable", "Cover crop window", "Rotation windows"]


def test_et0_is_plausible_for_egypt(client):
    pts = client.get(f"{API}/climate/timeseries", params={"variable": "et0", "freq": "Y"}).json()["points"]
    annual = [p["value"] for p in pts]
    assert all(1300 < v < 2200 for v in annual)


def test_rotations_default_and_custom(client):
    r = client.post(f"{API}/rotations", json={"rotation": "Wheat → Maize → Fallow", "priorities": ["soil", "res"]})
    assert r.status_code == 200
    rots = r.json()
    assert rots[0]["name"] == "Existing rotation"
    assert rots[0]["sequence"] == ["Wheat", "Maize", "Fallow"]
    assert len(rots) >= 3
    for rot in rots:
        for k in ("water_demand", "soil_benefit", "nitrogen_potential", "erosion_reduction",
                  "climate_suitability", "income_potential", "score"):
            assert 0 <= rot[k] <= 100


def test_rotation_legumes_beat_fallow_on_soil(client):
    rots = {x["name"]: x for x in client.post(f"{API}/rotations", json={"rotation": "Wheat, Maize, Fallow"}).json()}
    assert rots["Soil health strategy"]["soil_benefit"] > rots["Existing rotation"]["soil_benefit"]
    assert rots["Soil health strategy"]["nitrogen_potential"] > rots["Existing rotation"]["nitrogen_potential"]


def test_rotation_unknown_crop_flagged(client):
    rot = client.post(f"{API}/rotations", json={"rotation": "Wheat -> Dragonfruit"}).json()[0]
    assert rot["unknown_crops"] == ["Dragonfruit"]


@pytest.mark.parametrize("q,topic", [
    ("Is my land water stressed?", "water"),
    ("How is my soil?", "soil"),
    ("pests?", "pests"),
    ("which rotation is best", "strategy"),
    ("how hot does it get", "climate"),
    ("what's my ndvi", "vegetation"),
    ("hello", "help"),
])
def test_chat_topics(client, q, topic):
    body = client.post(f"{API}/chat", json={"message": q}).json()
    assert body["topic"] == topic and body["reply"]
