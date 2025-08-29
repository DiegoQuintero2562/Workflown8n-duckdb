from fastapi import FastAPI, Query
import duckdb
from typing import Optional

app = FastAPI()

@app.get("/metrics")
def get_metrics(
    start: str = Query(..., description="Start date YYYY-MM-DD"),
    end: str = Query(..., description="End date YYYY-MM-DD")
):
    con = duckdb.connect("./my_warehouse.duckdb")
    query = f"""
        SELECT
            SUM(spend) AS total_spend,
            SUM(conversions) AS total_conversions,
            ROUND(SUM(spend) / NULLIF(SUM(conversions),0), 2) AS CAC,
            ROUND((SUM(conversions) * 100.0) / NULLIF(SUM(spend),0), 2) AS ROAS
        FROM ads_spend
        WHERE date BETWEEN '{start}' AND '{end}'
    """
    result = con.execute(query).fetchone()
    con.close()
    return {
        "total_spend": result[0],
        "total_conversions": result[1],
        "CAC": result[2],
        "ROAS": result[3]
    }