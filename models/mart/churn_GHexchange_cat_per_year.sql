-- calcul du churn sur le nombre d'échange “dont le séjour a lieu” pendant la souscription. 2 churn calculés
-- churn sur le nombre d'échange correspond aux nombre d'echange en tant que guest
-- churn sur le nombre d'échange correspond aux nombre d'echange en tant que host

-- Important: on regarde ici les échanges finalisés durant la souscription d'un an - cela correspond aux regles de Home echange (note: le sejour peut avoir lieu alors qu'on n'est plus membre à condition que l'echange soit finalisé alors qu'on est membre).

WITH subscriptions_enriched AS (
  SELECT
    user_id,
    subscription_date,
    renew,
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
    s.renew,

    COUNT(DISTINCT CASE
      WHEN e.guest_user_id = s.user_id
       AND e.finalized_at IS NOT NULL
       AND e.canceled_at IS NULL
      THEN e.exchange_id -- on prend ici la valeur de exchange_id et non pas conversation_id car on fait dans la query la distinction guest / host
    END) AS guest_exchanges_finalized,

    COUNT(DISTINCT CASE
      WHEN e.host_user_id = s.user_id
       AND e.finalized_at IS NOT NULL
       AND e.canceled_at IS NULL
      THEN e.exchange_id
    END) AS host_exchanges_finalized

  FROM subscriptions_enriched AS s
  LEFT JOIN {{ ref('stg_raw_data__exchanges') }} AS e
    ON (s.user_id = e.guest_user_id OR s.user_id = e.host_user_id)
   AND DATE(e.finalized_at) >= s.subscription_date
   AND DATE(e.finalized_at) < COALESCE(
         s.next_subscription_date,
         DATE_ADD(s.subscription_date, INTERVAL 1 YEAR)
       )
  GROUP BY
    s.user_id,
    s.subscription_date,
    s.renew
),

categorized AS (
  SELECT
    EXTRACT(YEAR FROM subscription_date) AS subscription_year,
    renew,

    CASE
      WHEN guest_exchanges_finalized = 0 THEN '0'
      WHEN guest_exchanges_finalized = 1 THEN '1'
      WHEN guest_exchanges_finalized BETWEEN 2 AND 3 THEN '2-3'
      WHEN guest_exchanges_finalized BETWEEN 4 AND 6 THEN '4-6'
      ELSE '7+'
    END AS guest_exchange_group,

    CASE
      WHEN host_exchanges_finalized = 0 THEN '0'
      WHEN host_exchanges_finalized = 1 THEN '1'
      WHEN host_exchanges_finalized BETWEEN 2 AND 3 THEN '2-3'
      WHEN host_exchanges_finalized BETWEEN 4 AND 6 THEN '4-6'
      ELSE '7+'
    END AS host_exchange_group

  FROM exchanges_per_subscription
),

guest_churn AS (
  SELECT
    subscription_year,
    guest_exchange_group AS exchange_group,
    AVG(CASE WHEN renew = 0 THEN 1 ELSE 0 END) AS churn_guest
  FROM categorized
  GROUP BY
    subscription_year,
    exchange_group
),

host_churn AS (
  SELECT
    subscription_year,
    host_exchange_group AS exchange_group,
    AVG(CASE WHEN renew = 0 THEN 1 ELSE 0 END) AS churn_host
  FROM categorized
  GROUP BY
    subscription_year,
    exchange_group
)

SELECT
  COALESCE(g.subscription_year, h.subscription_year) AS subscription_year,
  COALESCE(g.exchange_group, h.exchange_group) AS exchange_group,
  g.churn_guest,
  h.churn_host
FROM guest_churn AS g
FULL OUTER JOIN host_churn AS h
  ON g.subscription_year = h.subscription_year
 AND g.exchange_group = h.exchange_group
ORDER BY
  subscription_year,
  CASE COALESCE(g.exchange_group, h.exchange_group)
    WHEN '0' THEN 1
    WHEN '1' THEN 2
    WHEN '2-3' THEN 3
    WHEN '4-6' THEN 4
    WHEN '7+' THEN 5
  END