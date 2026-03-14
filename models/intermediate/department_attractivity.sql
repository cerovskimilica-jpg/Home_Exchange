-- Creation d'une table classant les departements en 3 categories d'attractivité.
-- Categorisation avec la methode des tercile (decoupage en 3 groupes egaux)
-- en se basant sur le nombre de nuités de l'année 2022 (statistiques INSEE)

WITH tercil_method AS (
  SELECT
    country,
    department_code,
    department_isocode,
    nb_nights,
    NTILE(3) OVER (ORDER BY nb_nights DESC) AS department_attractivity_2022
  FROM {{ ref('nights_year_dep') }} -- Cette table donne le nombre de nuitees par departements en france de 2011 à 2024
  WHERE year = '2022'
)

SELECT
  country,
  department_code,
  department_isocode,
  CASE
    WHEN department_attractivity_2022 = 1 THEN 'high'
    WHEN department_attractivity_2022 = 2 THEN 'medium'
    WHEN department_attractivity_2022 = 3 THEN 'low'
  END AS department_attractivity_cat,
  nb_nights
FROM tercil_method