-- Reemplaza :start_date y :end_date por tus fechas
WITH metrics AS (
  SELECT
    SUM(spend) AS total_spend,
    SUM(conversions) AS total_conversions,
    SUM(conversions) * 100.0 AS revenue
  FROM ads_spend
  WHERE date BETWEEN :start_date AND :end_date
)
SELECT
  total_spend,
  total_conversions,
  ROUND(total_spend / NULLIF(total_conversions,0), 2) AS CAC,
  ROUND(revenue / NULLIF(total_spend,0), 2) AS ROAS
FROM metrics;