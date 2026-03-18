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
       AND e.canceled_at IS NOT NULL
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

churn_by_canceled_exchanges AS (
  SELECT
    subscription_year,

    CASE
      WHEN exchanges_canceled = 0 THEN '0'
      WHEN exchanges_canceled = 1 THEN '1'
      WHEN exchanges_canceled = 2 THEN '2'
      ELSE '3+'
    END AS canceled_exchange_group,

    COUNT(*) AS subscriptions,
    AVG(CASE WHEN renew = 0 THEN 1 ELSE 0 END) AS churn_rate,
    AVG(CASE WHEN renew = 1 THEN 1 ELSE 0 END) AS renewal_rate

  FROM exchanges_per_subscription
  GROUP BY
    subscription_year,
    canceled_exchange_group
)

SELECT *
FROM churn_by_canceled_exchanges
ORDER BY
  subscription_year,
  CASE canceled_exchange_group
    WHEN '0' THEN 1
    WHEN '1' THEN 2
    WHEN '2' THEN 3
    WHEN '3+' THEN 4
  END