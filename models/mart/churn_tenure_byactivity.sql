-- calcul du churn sur l'ancienneté sur la platforme (tenure en 4 categories <1y, 1-2y, 2-3y, 3+y) des utilisateurs Francais
-- a nombre d'échanges identiques (nb echanges en tant que host ou Guest - pas de differentiation car on sait que les 2 sont impactant)
-- On reprend ici les categories d'activité définies precedemment. Il est important de prendre 'activité en compte car c'est in facteur important qui pourrait les analyses globales

-- Important: on regarde ici les échanges finalisés durant la souscription d'un an - cela correspond aux regles de Home echange (note: le sejour peut avoir lieu alors qu'on n'est plus membre à condition que l'echange soit finalisé alors qu'on est membre).

WITH subscriptions_enriched AS (
  SELECT
    user_id,
    subscription_date,
    first_subscription_date,
    renew,
    DATE_DIFF(subscription_date, first_subscription_date, DAY) AS tenure_days,
    LEAD(subscription_date) OVER (
      PARTITION BY user_id
      ORDER BY subscription_date
    ) AS next_subscription_date
  FROM {{ ref('stg_raw_data_subscriptions_category_clean') }}
  WHERE renew IS NOT NULL AND country = 'FRA'
),

activity_per_subscription AS (
  SELECT
    s.user_id,
    s.subscription_date,
    s.renew,
    s.tenure_days,

    COUNT(DISTINCT CASE
      WHEN e.finalized_at IS NOT NULL
       AND e.canceled_at IS NULL
      THEN e.conversation_id
    END) AS exchanges_finalized

  FROM subscriptions_enriched s
  LEFT JOIN {{ ref('stg_raw_data__exchanges') }} AS e
    ON (s.user_id = e.guest_user_id OR s.user_id = e.host_user_id)
   AND e.start_on >= s.subscription_date
   AND e.start_on < COALESCE(
         s.next_subscription_date,
         DATE_ADD(s.subscription_date, INTERVAL 1 YEAR)
       )

  GROUP BY
    s.user_id,
    s.subscription_date,
    s.renew,
    s.tenure_days
),

categorized AS (
  SELECT
    renew,

    CASE
      WHEN tenure_days < 365 THEN '<1y'
      WHEN tenure_days < 730 THEN '1-2y'
      WHEN tenure_days < 1095 THEN '2-3y'
      ELSE '3y+'
    END AS tenure_group,

    CASE
      WHEN exchanges_finalized = 0 THEN '0'
      WHEN exchanges_finalized = 1 THEN '1'
      WHEN exchanges_finalized BETWEEN 2 AND 3 THEN '2-3'
      WHEN exchanges_finalized BETWEEN 4 AND 6 THEN '4-6'
      ELSE '7+'
    END AS activity_group

  FROM activity_per_subscription
)

SELECT
  tenure_group,
  activity_group,
  COUNT(*) AS nb_subscriptions,
  ROUND(AVG(CASE WHEN renew = 0 THEN 1 ELSE 0 END), 3) AS churn_rate,
  ROUND(AVG(CASE WHEN renew = 1 THEN 1 ELSE 0 END), 3) AS renewal_rate
FROM categorized
GROUP BY
  tenure_group,
  activity_group
ORDER BY
  CASE tenure_group
    WHEN '<1y' THEN 1
    WHEN '1-2y' THEN 2
    WHEN '2-3y' THEN 3
    WHEN '3y+' THEN 4
  END,
  CASE activity_group
    WHEN '0' THEN 1
    WHEN '1' THEN 2
    WHEN '2-3' THEN 3
    WHEN '4-6' THEN 4
    WHEN '7+' THEN 5
  END