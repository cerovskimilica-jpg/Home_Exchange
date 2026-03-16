-- Requete pour catégoriser chaque User en 3 catégorie : 1/ propose une primary home seulement 2/ propose 1 secondary home seulement 3/ propose une primary et une secondary home

SELECT
  user_id,
  CASE
    WHEN COUNT(DISTINCT CASE WHEN residence_type = 'primary' THEN 'primary' END) = 1
     AND COUNT(DISTINCT CASE WHEN residence_type = 'secondary' THEN 'secondary' END) = 0
      THEN 'Only Primary'

    WHEN COUNT(DISTINCT CASE WHEN residence_type = 'primary' THEN 'primary' END) = 0
     AND COUNT(DISTINCT CASE WHEN residence_type = 'secondary' THEN 'secondary' END) = 1
      THEN 'Only Secondary'

    WHEN COUNT(DISTINCT CASE WHEN residence_type = 'primary' THEN 'primary' END) = 1
     AND COUNT(DISTINCT CASE WHEN residence_type = 'secondary' THEN 'secondary' END) = 1
      THEN 'Primary + Secondary'
  END AS home_category
FROM {{ ref('sub_exchange') }}
GROUP BY user_id