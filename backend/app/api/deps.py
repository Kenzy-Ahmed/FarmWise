from datetime import date

from fastapi import Query

from app.data.store import DataStore, get_store


def store() -> DataStore:
    return get_store()


class DateFilter:
    def __init__(
        self,
        start: date | None = Query(None, description="Start date (YYYY-MM-DD)"),
        end: date | None = Query(None, description="End date (YYYY-MM-DD)"),
    ):
        self.start = start
        self.end = end
