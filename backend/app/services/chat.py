"""Rule-based assistant that answers with the site's real data.

Kept deliberately simple (keyword intents) so the demo works offline; the
`answer` function is the seam for plugging in an LLM later.
"""
import re

from app.data.store import DataStore
from app.services import climate, insights, recommendations, rotations, soil, vegetation


def answer(store: DataStore, message: str, rotation: str | None = None,
           priorities: list[str] | None = None) -> dict:
    q = message.lower()
    m = {x["key"]: x for x in insights.metrics(store)}
    rk = {x["key"]: x for x in insights.risks(store)}

    if re.search(r"water|stress|dry|drought|irrigat", q):
        text = (f"Recent rainfall is only {m['rainfall']['display']} while plants lose about "
                f"{m['et0']['display']} to evapotranspiration. SMAP top-soil moisture is "
                f"{m['soil_moisture']['display']} (as of {m['soil_moisture']['as_of']}). Rain covers "
                f"{m['water_availability']['display']}, so drought risk is {rk['drought']['level'].lower()} "
                f"({rk['drought']['value']}/100) and crops rely on irrigation. Check with a soil moisture probe in your field.")
        topic = "water"
    elif re.search(r"soil|organic|nitrogen|ph\b|fertili", q):
        s = soil.profile(store)
        text = (f"Your soil is {s['texture_class'].lower()} with pH {s['ph']} ({s['ph_class'].lower()}), "
                f"organic carbon {s['soc_g_kg']} g/kg and nitrogen {s['nitrogen_g_kg']} g/kg (SoilGrids). "
                "Legumes such as faba bean or clover fix nitrogen, and cover crops add organic matter and protect "
                "against erosion. Confirm with a lab soil test.")
        topic = "soil"
    elif re.search(r"pest|disease|insect", q):
        text = ("Changing crop families each season interrupts pests and diseases that depend on one host. "
                "It lowers pressure but rarely removes it, so keep scouting.")
        topic = "pests"
    elif re.search(r"strateg|rotation|best|which|recommend|plant|grow|crop", q):
        strat = rotations.strategies(store, rotation, priorities)
        strat.sort(key=lambda r: r["score"], reverse=True)
        top = strat[0]
        crops = recommendations.recommend(store)["recommendations"][:3]
        text = (f'With your priorities, "{top["name"]}" ({" → ".join(top["sequence"])}) scores highest '
                f'({top["score"]}/100). For single crops, the best match for local climate and soil is '
                + ", ".join(f'{c["crop_name"]} ({c["overall_score"]:.0f})' for c in crops)
                + ". These are decision-support indicators, not guarantees. See Compare for trade-offs.")
        topic = "strategy"
    elif re.search(r"temp|heat|hot|cold|weather|climate|rain", q):
        c = climate.summary(store)
        text = (f"Over {c['start'].year}–{c['end'].year} the mean temperature was {c['mean_temp_c']} °C, "
                f"rainfall averaged {c['avg_annual_rainfall_mm']:.0f} mm/year and heat stress is "
                f"{rk['heat']['level'].lower()} ({rk['heat']['method']}). The last 30 days averaged "
                f"{m['temperature']['display']}.")
        topic = "climate"
    elif re.search(r"ndvi|green|vegetation|health", q):
        n = vegetation.ndvi_series(store)
        text = (f"The latest MODIS NDVI is {n['latest']['ndvi_mean']:.2f} ({n['latest']['composite_date']}): "
                f"{n['health_status'].lower()}. The long-term average is {n['mean']:.2f}.")
        topic = "vegetation"
    else:
        text = ("I can explain water stress, soil health, pests, the weather, vegetation health, "
                "or which rotation suits your priorities. Try one of those.")
        topic = "help"
    return {"reply": text, "topic": topic}
