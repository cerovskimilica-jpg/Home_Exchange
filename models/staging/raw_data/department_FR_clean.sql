SELECT DISTINCT
  country,
  department,
    CASE
    WHEN department = 'Tarn-et-Garonne' THEN 'Tarn-Et-Garonne'
    WHEN department = '' THEN 'Saint-Leu'
    WHEN department = '' THEN 'Saint-Paul'
    WHEN department = 'Territoire de Belfort' THEN 'Territoire De Belfort'
    WHEN department = 'Val-d’Oise' THEN "Val-D'oise"
    WHEN department = 'Val-de-Marne' THEN 'Val-De-Marne'
    WHEN department = 'Hauts-de-Seine' THEN 'Hauts-De-Seine'
    WHEN department = 'Seine-et-Marne' THEN 'Seine-Et-Marne'
    WHEN department = 'Maine-et-Loire' THEN 'Maine-Et-Loire'
    WHEN department = 'Bouches-du-Rhône' THEN 'Bouches-Du-Rhône'
    WHEN department = 'Alpes-de-Haute-Provence' THEN 'Alpes-De-Haute-Provence'
    ELSE department
  END AS department_FR_clean
FROM {{ source('raw_data', 'subscription') }}
WHERE department IS NOT NULL
AND country = 'FRA';
