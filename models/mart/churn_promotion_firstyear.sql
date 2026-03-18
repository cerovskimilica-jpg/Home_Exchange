SELECT
  promotion,
  CASE
    WHEN promotion = 0 THEN  "Sans Promotion"
    ELSE "Avec promotion"
  END AS promotion_graphe,
  COUNT(*) AS first_year_subscriptions,
  COUNTIF(renew = 0) AS churned,
  SAFE_DIVIDE(COUNTIF(renew = 0), COUNT(*)) AS churn_rate
FROM {{ ref('stg_raw_data_subscriptions_category_clean') }}
WHERE renew IS NOT NULL
AND country = "FRA"
AND DATE_DIFF(subscription_date, first_subscription_date, YEAR) = 0
GROUP BY promotion
ORDER BY promotion