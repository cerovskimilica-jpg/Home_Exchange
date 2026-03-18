SELECT
  referral,
  CASE
    WHEN referral = 0 THEN  "Sans parrainage"
    ELSE "Avec parrainage"
  END AS referral_graph,
  COUNT(*) AS first_year_subscriptions,
  COUNTIF(renew = 0) AS churned,
  SAFE_DIVIDE(COUNTIF(renew = 0), COUNT(*)) AS churn_rate
FROM {{ ref('stg_raw_data_subscriptions_category_clean') }}
WHERE renew IS NOT NULL
AND country = "FRA"
AND DATE_DIFF(subscription_date, first_subscription_date, YEAR) = 0
GROUP BY referral
ORDER BY referral