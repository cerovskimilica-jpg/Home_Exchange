WITH pro AS (
  SELECT
    s.* EXCEPT(country, region, city, department),
    e.* EXCEPT(country, region, city, department),
    

    -- host
    s.country AS country_exc,
    e.country AS country_sub,
    s.region AS region_exc,
    e.region AS region_sub,
    s.city AS city_exc,
    e.city AS city_sub,
    s.department AS department_exc,
    e.department AS department_sub,

    -- guest : on prend seulement les colonnes utiles
    sguest.country AS country_guest,
    sguest.region AS region_guest,
    sguest.city AS city_guest,
    sguest.department AS department_guest,

    -- adresse unique des host à partir de la table adresse (pour compléter les adresses des guest incomplètes ensuite) 
    ad.country_host as country_guest2,
    ad.region_host as region_guest2,
    ad.department_host as department_guest2,
    ad.city_host as city_guest2
   

  FROM {{ ref('stg_raw_data__exchanges') }} AS s
  LEFT JOIN {{ ref('sub_no_duplicates') }} AS e
    ON e.user_id = s.host_user_id
  LEFT JOIN {{ ref('sub_no_duplicates') }} AS sguest
    ON s.guest_user_id = sguest.user_id
  LEFT JOIN {{ ref('adresse_host') }} AS ad
    ON s.guest_user_id = ad.host_user_id  
)

SELECT
  pro.* EXCEPT(
    country_exc, country_sub,
    region_exc, region_sub,
    city_exc, city_sub,
    department_exc, department_sub,
    country_guest, department_guest, region_guest, city_guest,
    country_guest2, department_guest2, region_guest2, city_guest2
  ),
 
  COALESCE(country_exc, country_sub) AS country_host,
  COALESCE(region_exc, region_sub) AS region_host,
  COALESCE(department_exc, department_sub) AS department_host,
  COALESCE(city_exc, city_sub) AS city_host,


  COALESCE(country_guest, country_guest2) AS country_guestdf, -- remplacement des valeurs nulles d'adresse de guest par leur adresse en tant que Host si disponible
  COALESCE(region_guest, region_guest2) AS region_guestdf,
  COALESCE(department_guest, department_guest2) AS department_guestdf,
  COALESCE(city_guest, city_guest2) AS city_guestdf

FROM pro