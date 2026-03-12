-- CTE: calcul des annulations, taux annulation

WITH base AS (
  SELECT
    EXTRACT(YEAR FROM finalized_at) AS finalization_year,
    EXTRACT(YEAR FROM canceled_at) AS cancelation_year,
    canceled_at,
    cancel_start_duration,
    finalize_cancel_duration
  FROM {{ ref('finalyzed_exchange') }}
),

year_annulation_agg AS (
  SELECT
  finalization_year AS year,
  COUNT(*) AS nb_finalized_exchanges,
  COUNTIF(canceled_at IS NOT NULL) AS nb_annulations,
  ROUND(
    COUNTIF(canceled_at IS NOT NULL) * 100.0 / COUNT(*),
    2
  ) AS pct_annulation,
  ROUND(AVG(cancel_start_duration),0) AS AVG_cancel_start_duration,
  ROUND(AVG(finalize_cancel_duration),0) AS AVG_finalize_cancel_duration,
FROM base
GROUP BY year
ORDER BY year
)

SELECT *
FROM year_annulation_agg