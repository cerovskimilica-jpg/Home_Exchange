-- Extraction des données des raw data de loc_touristic pour obtenir sur le nombre de nuitées par departement pour differentes années

WITH NUI_temp AS (
  SELECT *
  FROM {{ ref('stg_raw_data__loc_touristic') }}
  WHERE FREQ = 'A' --  A pour année - OBS_VALUE_corrected est mesurée par an
    AND GEO_OBJECT = 'DEP' --  DEP pour departement - OBS_VALUE_corrected est mesurée par departement
    AND TOUR_MEASURE = 'NUI' -- TOUR_MEASURE = de qui est mesuré - NUI = nb de nuités
    AND OBS_STATUS_FR = 'D' --  D = version définitive
    AND UNIT_LOC_RANKING = '_T' --  Classement de l'établissement touristique (etoiles) - _T = Total
),


Dep_code AS (    -- ajout d'une colonne avec le code du département au bon format (string avec 01, 0 devant le 1 pour l'Ain)
  SELECT *,
      CAST(
      CASE
        WHEN GEO IN ('2A', '2B') THEN GEO
        WHEN LENGTH(CAST(GEO AS STRING)) = 1
          THEN LPAD(CAST(GEO AS STRING), 2, '0')  -- 1 → 01, 9 → 09
        ELSE CAST(GEO AS STRING)                  -- 2 chiffres (75) ou 3 chiffres (971)
      END
    AS STRING) AS department_code,
  FROM NUI_temp
)

SELECT 
  TIME_PERIOD AS year,
  'France' AS country,
  department_code,
  CONCAT('FR-', department_code) AS department_isocode, -- code ISO est utilisé pas Looker studio pour une heatmap Geo (country subdivision (1st level)
  ROUND(SUM(obs_value_corrected), 0) AS nb_nights
FROM Dep_code
GROUP BY TIME_PERIOD, department_code
ORDER BY TIME_PERIOD DESC, nb_nights DESC
