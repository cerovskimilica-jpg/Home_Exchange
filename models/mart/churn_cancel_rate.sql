WITH subscriptions_enriched AS (
  SELECT
    user_id,
    subscription_date,
    renew,
    EXTRACT(YEAR FROM subscription_date) AS subscription_year,
    LEAD(subscription_date) OVER (
      PARTITION BY user_id
      ORDER BY subscription_date
    ) AS next_subscription_date
  FROM {{ ref('stg_raw_data_subscriptions_category_clean') }}
  WHERE country = 'FRA'
),

exchanges_per_subscription AS (
  SELECT
    s.user_id,
    s.subscription_date,
    s.subscription_year,
    s.renew,

    COUNT(DISTINCT CASE
      WHEN e.finalized_at IS NOT NULL
      THEN e.conversation_id
    END) AS exchanges_finalized_or_canceled,

    COUNT(DISTINCT CASE
      WHEN e.canceled_at IS NOT NULL
      THEN e.conversation_id
    END) AS exchanges_canceled

  FROM subscriptions_enriched s
  LEFT JOIN {{ ref('stg_raw_data__exchanges') }} e
    ON (s.user_id = e.guest_user_id OR s.user_id = e.host_user_id)
   AND e.start_on >= s.subscription_date
   AND e.start_on < COALESCE(
         s.next_subscription_date,
         DATE_ADD(s.subscription_date, INTERVAL 1 YEAR)
       )

  GROUP BY
    s.user_id,
    s.subscription_date,
    s.subscription_year,
    s.renew
),

subscriptions_with_cancel_rate AS (
  SELECT
    user_id,
    subscription_date,
    subscription_year,
    renew,
    exchanges_finalized_or_canceled,
    exchanges_canceled,
    SAFE_DIVIDE(exchanges_canceled, exchanges_finalized_or_canceled) AS cancel_rate
  FROM exchanges_per_subscription
),

churn_by_cancel_rate AS (
  SELECT
    subscription_year,

    CASE
      WHEN exchanges_finalized_or_canceled = 0 THEN 'no finalized exchange'
      WHEN cancel_rate = 0 THEN '0%'
      WHEN cancel_rate > 0 AND cancel_rate <= 0.25 THEN '0-25%'
      WHEN cancel_rate > 0.25 AND cancel_rate <= 0.50 THEN '25-50%'
      WHEN cancel_rate > 0.50 AND cancel_rate < 1 THEN '50-99%'
      WHEN cancel_rate = 1 THEN '100%'
      ELSE 'unknown'
    END AS cancel_rate_group,

    COUNT(*) AS subscriptions,
    AVG(CASE WHEN renew = 0 THEN 1 ELSE 0 END) AS churn_rate,
    AVG(CASE WHEN renew = 1 THEN 1 ELSE 0 END) AS renewal_rate,
    AVG(cancel_rate) AS avg_cancel_rate

  FROM subscriptions_with_cancel_rate
  GROUP BY
    subscription_year,
    cancel_rate_group
)

SELECT *
FROM churn_by_cancel_rate
ORDER BY
  subscription_year,
  CASE cancel_rate_group
    WHEN 'no finalized exchange' THEN 1
    WHEN '0%' THEN 2
    WHEN '0-25%' THEN 3
    WHEN '25-50%' THEN 4
    WHEN '50-99%' THEN 5
    WHEN '100%' THEN 6
    ELSE 7
  END