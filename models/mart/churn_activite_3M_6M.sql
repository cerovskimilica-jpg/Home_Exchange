/* calcul du churn suivant que l'utilisateur a initié un echanges (au sens requete d'echange et non pas echnage finalisé) ou pas dans les 3-6 mois qui ont suivi son inscritpion
que l'echange soit initié en tant que Host ou Guest*/

WITH subscriptions_enriched AS (
  SELECT
    user_id,
    subscription_date,
    renew
  FROM {{ ref('stg_raw_data_subscriptions_category_clean') }}
  WHERE country = 'FRA'
    AND renew IS NOT NULL
),

initiated_exchanges AS (
  SELECT
    s.user_id,
    s.subscription_date,
    s.renew,

    COUNT(DISTINCT CASE
      WHEN e.creator_id = s.user_id
       AND DATE(e.created_at) >= s.subscription_date
       AND DATE(e.created_at) < DATE_ADD(s.subscription_date, INTERVAL 3 MONTH)
      THEN e.exchange_id
    END) AS initiated_exchanges_3m,

    COUNT(DISTINCT CASE
      WHEN e.creator_id = s.user_id
       AND DATE(e.created_at) >= s.subscription_date
       AND DATE(e.created_at) < DATE_ADD(s.subscription_date, INTERVAL 6 MONTH)
      THEN e.exchange_id
    END) AS initiated_exchanges_6m

  FROM subscriptions_enriched s
  LEFT JOIN {{ ref('stg_raw_data__exchanges') }} AS e
    ON s.user_id = e.creator_id
  GROUP BY
    s.user_id,
    s.subscription_date,
    s.renew
),

categorized AS (
  SELECT
    renew,
    CASE
      WHEN initiated_exchanges_3m = 0 THEN 'Aucun échange'
      ELSE "Plus d'1 échange"
    END AS initiation_group_3m,
    CASE
      WHEN initiated_exchanges_6m = 0 THEN 'Aucun échange'
      ELSE "Plus d'1 échange"
    END AS initiation_group_6m
  FROM initiated_exchanges
),

churn_3m AS (
  SELECT
    '3 mois' AS periode,
    initiation_group_3m AS initiation_group,
    COUNT(*) AS users,
    AVG(CASE WHEN renew = 0 THEN 1 ELSE 0 END) AS churn_rate
  FROM categorized
  GROUP BY initiation_group_3m
),

churn_6m AS (
  SELECT
    '6 mois' AS periode,
    initiation_group_6m AS initiation_group,
    COUNT(*) AS users,
    AVG(CASE WHEN renew = 0 THEN 1 ELSE 0 END) AS churn_rate
  FROM categorized
  GROUP BY initiation_group_6m
)

SELECT *
FROM churn_3m

UNION ALL

SELECT *
FROM churn_6m

/*ORDER BY
  CASE periode
    WHEN '3 mois' THEN 1
    WHEN '6 mois' THEN 2
  END,
  CASE initiation_group
    WHEN 'Aucun échange' THEN 1
    WHEN 'Au moins 1 échange initié à 3 mois' THEN 2
    WHEN 'Aucun échange initié à 6 mois' THEN 1
    WHEN 'Au moins 1 échange initié à 6 mois' THEN 2
  END
  */