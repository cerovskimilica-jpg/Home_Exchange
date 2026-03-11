SELECT
  * EXCEPT(department),
    CASE
    WHEN department = 'Maritime Alps' THEN 'Alpes-Maritimes'
    WHEN department = 'Arrondissement De Paris' THEN 'Paris'
    WHEN department = 'Parigi' THEN 'Paris'
    WHEN department = 'Département Indre-et-Loire' THEN 'Indre-et-Loire'
    ELSE department
  END AS department_clean
FROM {{ ref('stg_raw_data__subscriptions') }}
