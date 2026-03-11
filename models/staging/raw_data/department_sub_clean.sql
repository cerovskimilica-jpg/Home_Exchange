SELECT
  * EXCEPT(department),
  CASE
    WHEN department = 'Maritime Alps' THEN 'Alpes-Maritimes'
    WHEN department IN ('Arrondissement De Paris', 'Parigi') THEN 'Paris'
    WHEN department IN ('Département Indre-et-Loire', 'Indre-et-Loire') THEN 'Indre-Et-Loire'
    WHEN department = 'Maine-et-Loire' THEN 'Maine-Et-Loire'
    ELSE department
  END AS department_clean
FROM {{ ref('stg_raw_data__subscriptions') }}