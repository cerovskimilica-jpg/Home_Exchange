SELECT
  promotion,
  referral,
  COUNT(*) AS users,
  COUNTIF(renew=0) AS churned,
  SAFE_DIVIDE(COUNTIF(renew=0),COUNT(*)) AS churn_rate
FROM {{ ref('stg_raw_data_subscriptions_category_clean') }}
WHERE renew IS NOT NULL
and country = "FRA"
AND DATE_DIFF(subscription_date, first_subscription_date, YEAR) = 0
GROUP BY promotion, referral
ORDER BY promotion, referral