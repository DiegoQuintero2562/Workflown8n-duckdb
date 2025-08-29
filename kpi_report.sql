WITH date_bounds AS (
  SELECT MAX(date) AS max_date FROM ads_spend
),
periods AS (
  SELECT
    max_date,
    max_date - INTERVAL 29 DAY AS last_30_start,
    max_date - INTERVAL 59 DAY AS prev_30_start,
    max_date - INTERVAL 30 DAY AS prev_30_end
  FROM date_bounds
),
kpis AS (
  SELECT
    CASE
      WHEN date >= p.last_30_start AND date <= p.max_date THEN 'last_30'
      WHEN date >= p.prev_30_start AND date < p.prev_30_end THEN 'prev_30'
      ELSE NULL
    END AS period,
    SUM(spend) AS total_spend,
    SUM(conversions) AS total_conversions
  FROM ads_spend, periods p
  WHERE date >= p.prev_30_start AND date <= p.max_date
  GROUP BY period
)
SELECT
  last_30.total_spend AS spend_last_30,
  prev_30.total_spend AS spend_prev_30,
  last_30.total_conversions AS conv_last_30,
  prev_30.total_conversions AS conv_prev_30,
  ROUND(last_30.total_spend / NULLIF(last_30.total_conversions,0), 2) AS CAC_last_30,
  ROUND(prev_30.total_spend / NULLIF(prev_30.total_conversions,0), 2) AS CAC_prev_30,
  ROUND(100.0 * (ROUND(last_30.total_spend / NULLIF(last_30.total_conversions,0), 2) - ROUND(prev_30.total_spend / NULLIF(prev_30.total_conversions,0), 2)) / NULLIF(ROUND(prev_30.total_spend / NULLIF(prev_30.total_conversions,0), 2),0), 2) AS CAC_delta_pct,
  ROUND((last_30.total_conversions * 100.0) / NULLIF(last_30.total_spend,0), 2) AS ROAS_last_30,
  ROUND((prev_30.total_conversions * 100.0) / NULLIF(prev_30.total_spend,0), 2) AS ROAS_prev_30,
  ROUND(100.0 * (ROUND((last_30.total_conversions * 100.0) / NULLIF(last_30.total_spend,0), 2) - ROUND((prev_30.total_conversions * 100.0) / NULLIF(prev_30.total_spend,0), 2)) / NULLIF(ROUND((prev_30.total_conversions * 100.0) / NULLIF(prev_30.total_spend,0), 2),0), 2) AS ROAS_delta_pct
FROM
  (SELECT * FROM kpis WHERE period = 'last_30') last_30,
  (SELECT * FROM kpis WHERE period = 'prev_30') prev_30;