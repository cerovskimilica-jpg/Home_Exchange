-- Creation d'une table classant les departements categories d'attractivité (10 categories 10= attractif, 1 = pas attractif).
-- Categorisation avec la methode des tercile (decoupage en 10 groupes egaux)
-- en se basant sur le nombre de nuités de l'année 2022 (statistiques INSEE)

SELECT
    country,
    department_code,
    department_isocode,
    NTILE(10) OVER (ORDER BY nb_nights) AS department_attractivity_2022_decile,
    nb_nights
FROM {{ ref('nights_year_dep') }} -- Cette table donne le nombre de nuitees par departements en france de 2011 à 2024
WHERE year = '2022'


-- code a garder au cas ou il faudrait modifier les categories
-- SELECT
--   country,
--   department_code,
--  department_isocode,
--   CASE
--     WHEN department_attractivity_2022 = 1 THEN 'low'
--     WHEN department_attractivity_2022 = 2 THEN 'medium'
--     WHEN department_attractivity_2022 = 3 THEN 'high' et completer
--   END AS department_attractivity_cat,
--   nb_nights
-- FROM decile_method