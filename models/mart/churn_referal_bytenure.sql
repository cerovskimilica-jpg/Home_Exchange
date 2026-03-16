-- Analyser le churn selon l’ancienneté (tenure) est le beaucoup plus informatif
-- Il évite le bias que les nouveaux entrants churnent plus que les anciens et qu'on a generalement bcp de nouveaux.

SELECT
  CASE
    WHEN DATE_DIFF(subscription_date, first_subscription_date, YEAR) = 0 THEN 'Year 1'
    WHEN DATE_DIFF(subscription_date, first_subscription_date, YEAR) = 1 THEN 'Year 2'
    WHEN DATE_DIFF(subscription_date, first_subscription_date, YEAR) = 2 THEN 'Year 3'
    WHEN DATE_DIFF(subscription_date, first_subscription_date, YEAR) = 3 THEN 'Year 4'
    ELSE 'Year 5+'
  END AS tenure_bucket,
  referral,
  COUNT(*) AS users,
  COUNTIF(renew = 0) AS churners,
  SAFE_DIVIDE(COUNTIF(renew = 0), COUNT(*)) AS churn_rate
FROM {{ ref('stg_raw_data_subscriptions_category_clean') }}
WHERE renew IS NOT NULL
GROUP BY tenure_bucket, referral
ORDER BY tenure_bucket;