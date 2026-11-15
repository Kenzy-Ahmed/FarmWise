from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import RedirectResponse

from app.api.routes import climate, crops, dashboard, meta, soil, vegetation
from app.core.config import get_settings
from app.data.store import get_store


@asynccontextmanager
async def lifespan(_: FastAPI):
    get_store()  # warm the in-memory data cache at startup
    yield


def create_app() -> FastAPI:
    settings = get_settings()
    app = FastAPI(
        title=settings.app_name,
        version=settings.version,
        description="Satellite-driven crop recommendations for El-Zankalon, Egypt "
                    "(NASA POWER, GPM, SMAP, MODIS + SoilGrids, FAO GAEZ/ECOCROP).",
        lifespan=lifespan,
    )
    origins = settings.cors_origin_list
    app.add_middleware(
        CORSMiddleware,
        allow_origins=origins,
        allow_credentials="*" not in origins,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    for r in (meta, climate, soil, vegetation, crops, dashboard):
        app.include_router(r.router, prefix=settings.api_prefix)

    @app.get("/", include_in_schema=False)
    def root():
        return RedirectResponse("/docs")

    return app


app = create_app()
