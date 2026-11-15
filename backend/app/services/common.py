import calendar
import math

import pandas as pd

MONTH_NAMES = {i: calendar.month_abbr[i] for i in range(1, 13)}


def clean(value, ndigits: int = 3):
    """Convert numpy/pandas scalars to JSON-safe Python floats (NaN -> None)."""
    if value is None:
        return None
    try:
        if pd.isna(value):
            return None
    except (TypeError, ValueError):
        pass
    f = float(value)
    if math.isinf(f):
        return None
    return round(f, ndigits)
