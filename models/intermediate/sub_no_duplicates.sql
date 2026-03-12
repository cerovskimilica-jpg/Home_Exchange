WITH subscriptions_user AS (
  SELECT
    user_id,

    MIN(first_subscription_date) AS first_subscription_date,
    MAX(subscription_date) AS last_subscription_date,

    COUNT(*) AS nb_subscriptions,

    CASE
      WHEN COUNT(*) > 1 THEN 1
      ELSE 0
    END AS returned_customer,

    MAX(CASE WHEN renew = 1 THEN 1 ELSE 0 END) AS renew,
    MAX(CASE WHEN promotion = 1 THEN 1 ELSE 0 END) AS promotion,
    MAX(CASE WHEN referral = 1 THEN 1 ELSE 0 END) AS referral,
    MAX(CASE WHEN payment2 = 1 THEN 1 ELSE 0 END) AS payment2,
    MAX(CASE WHEN payment3 = 1 THEN 1 ELSE 0 END) AS payment3,
    MAX(CASE WHEN payment3x = 1 THEN 1 ELSE 0 END) AS payment3x,

    ANY_VALUE(country) AS country,
    ANY_VALUE(region) AS region,
    ANY_VALUE(department) AS department,
    ANY_VALUE(city) AS city

  FROM {{ ref('stg_raw_data_subscriptions_category_clean') }}
  GROUP BY user_id
)

SELECT
  user_id,
  first_subscription_date,
  last_subscription_date,
  nb_subscriptions,
  returned_customer,
  renew,
  promotion,
  referral,
  payment2,
  payment3,
  payment3x,
  country,
  region,
  department,
  city,

FROM subscriptions_user