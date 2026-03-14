-- CTE clean: retirer les colonnes 'country, department_code, region_name, department_clean' qui ont été ajoutées en trop durant une jointure
-- Jointure avec la table department_attractivity -> rajouter uniquement la colonne 'department_attractivity_2022'


WITH clean AS (
    SELECT
        * EXCEPT(country, department_code, region_name, department_clean)
    FROM {{ ref('sub_exchanges_adresses') }}
)

SELECT
clean.*,
attract.department_attractivity_cat AS department_host_attractivity_cat
FROM clean
LEFT JOIN {{ ref('department_attractivity') }} AS attract
    ON clean.department_host_isocode = attract.department_isocode
