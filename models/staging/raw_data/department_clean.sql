SELECT DISTINCT
  country,
  department,
  CASE
    WHEN department = 'Maritime Alps' THEN 'Alpes-Maritimes'
    WHEN department = 'Département Indre-et-Loire' THEN 'Indre-et-Loire'
    WHEN department = 'Arrondissement De Paris' THEN 'Paris'
    ELSE department
  END AS department_clean
FROM {{ source('raw_data', 'subscription') }}
WHERE department IS NOT NULL
AND country = 'FRA';
