WITH subadresse AS (
  SELECT
    se.*, 
    ad.* EXCEPT(country_host, region_host, city_host, department_host, host_user_id, last_subscription_date, residence_type),
  
  -- JOIN la table adresse et sub_exchange sur la base du guest ID (où l'on cherche l'adresse) auquel on renvoie l'adresse du host_ID provenant de la table Adresse
    ad.country_host as country_guest2,
    ad.region_host as region_guest2,
    ad.department_host as department_guest2,
    ad.city_host as city_guest2

      FROM {{ ref('sub_exchange') }} AS se
        LEFT JOIN {{ ref('adresse_host') }} AS ad
        ON se.guest_user_id = ad.host_user_id  
)

SELECT
  subadresse.* EXCEPT(
    country_guest, department_guest, region_guest, city_guest,
    country_guest2, department_guest2, region_guest2, city_guest2
  ),

  COALESCE(country_guest, country_guest2) AS country_guestdf, -- remplacement des valeurs nulles d'adresse de guest par leur adresse en tant que Host si disponible
  COALESCE(region_guest, region_guest2) AS region_guestdf,
  COALESCE(department_guest, department_guest2) AS department_guestdf,
  COALESCE(city_guest, city_guest2) AS city_guestdf

FROM subadresse