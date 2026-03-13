-- Objectif: rajouter les isocodes FR pour les department_host à la table sub_exchanges_adresses
-- et d'ajouter via le case when les ISO code pour les department_host qui avaient des valeurs erronées

WITH jointure AS (
  SELECT *
  FROM {{ ref('sub_exchanges_adresses') }} AS exc
  LEFT JOIN {{ ref('stg_raw_data__department_FR') }} AS dep
  ON exc.department_host = dep.department_clean
),

cleaning AS (
SELECT * EXCEPT(department_isocode),
  CASE
    WHEN department_host = 'Puy-De-Dôme' THEN 'FR-63'
    WHEN department_host = 'Lot-Et-Garonne' THEN 'FR-47'
    WHEN department_host = 'Corse' THEN 'FR-2A'
    WHEN department_host = 'Puy-De-Dôme' THEN 'FR-63'
    WHEN department_host = 'Sainte-Anne' THEN 'FR-971'
    WHEN department_host = "Baie-Mahault" THEN 'FR-971'
    WHEN department_host = "Saint-François" THEN 'FR-971'
    WHEN department_host = "Entre-Deux" THEN 'FR-974'
    WHEN department_host = "Cayenne" THEN 'FR-973'
    WHEN department_host = "Arrondissement de Saint-Paul" THEN 'FR-974'
    WHEN department_host = "Saint-Joseph" THEN 'FR-974'
    WHEN department_host = "La Montagne" THEN 'FR-974'
    WHEN department_host = "Saint-Charles" THEN 'FR-974'
    WHEN department_host = "Case-Pilote" THEN 'FR-972'
    WHEN department_host = "Meurthe-Et-Moselle" THEN 'FR-54'
    WHEN department_host = "La Coulée" THEN 'FR-971'
    WHEN department_host = "Corsica" THEN 'FR-2A'
    WHEN department_host = "Fort-De-France" THEN 'FR-972'
    WHEN department_host = "Joseph" THEN 'FR-972'
    WHEN department_host = "Trois-Rivières" THEN 'FR-971'
    WHEN department_host = "Indre-Et-Loire" THEN 'FR-37'
    WHEN department_host = "Les Trois-Îlets" THEN 'FR-972'
    WHEN department_host = "Le Moule" THEN 'FR-971'
    WHEN department_host = "Le Robert" THEN 'FR-972'
    WHEN department_host = "Finisterre" THEN 'FR-29'
    WHEN department_host = "Le Diamant" THEN 'FR-972'
    WHEN department_host = "Le Francois" THEN 'FR-972'
    WHEN department_host = "Lamentin" THEN 'FR-972'
    WHEN department_host = "Seine-et-Marne" THEN 'FR-77'
    WHEN department_host = "Schoelcher" THEN 'FR-972'
    WHEN department_host = "Saône-Et-Loire" THEN 'FR-71'
    WHEN department_host = "Arrondissement De Paris" THEN '75'
    WHEN department_host = "Grand-Bourg" THEN 'FR-971'
    WHEN department_host = "Loir-Et-Cher" THEN 'FR-41'
    WHEN department_host = "Arrondissement de Cayenne" THEN 'FR-973'
    WHEN department_host = "Côte-D'or" THEN 'FR-21'
    WHEN department_host = "Deshaies" THEN 'FR-971'
    WHEN department_host = "Eure-Et-Loir" THEN 'FR-28'
    WHEN department_host = "Côtes-D'armor" THEN 'FR-22'
    WHEN department_host = "Piton Saint-Leu" THEN 'FR-974'
    WHEN department_host = "Ille-Et-Vilaine" THEN 'FR-35'
    WHEN department_host = "Les Avirons" THEN 'FR-974'
    WHEN department_host = "Vieux-Habitants" THEN 'FR-971'
    WHEN department_host = "Petit-Bourg" THEN 'FR-971'
    WHEN department_host = "Sainte-Marie" THEN 'FR-974'
    WHEN department_host = "Basse-Terre" THEN 'FR-971'
    WHEN department_host = "Dzaoudzi" THEN 'FR-976'
    WHEN department_host = "Corse-Du-Sud" THEN 'FR-2A'
    WHEN department_host = "Pas-De-Calais" THEN 'FR-62'
    WHEN department_host = "Le Gosier" THEN 'FR-971'
    WHEN department_host = "Rambouillet" THEN 'FR-78'
    WHEN department_host = "Alpes-de-Haute-Provence" THEN 'FR-04'
    WHEN department_host = "La Bouaye" THEN 'FR-44'
    WHEN department_host = "Landas" THEN 'FR-59'
    WHEN department_host = "Pointe-Noire" THEN 'FR-971'
    WHEN department_host = "Saint-Leu" THEN 'FR-974'
    WHEN department_host = "Convenance" THEN 'FR-971'
    WHEN department_host = "Saint-Paul" THEN 'FR-974'
    WHEN department_host = "Burat" THEN 'FR-971'
    WHEN department_host = "La Trinité" THEN 'FR-972'
    WHEN department_host = "Costa de Oro" THEN 'FR-21'
    WHEN department_host = "Saint-Denis" THEN 'FR-974'
    WHEN department_host = "Saint-Pierre" THEN 'FR-974'
    WHEN department_host = "Saint-Andre" THEN 'FR-974'
    ELSE department_isocode
  END AS department_host_isocode
FROM jointure
)

SELECT *
FROM cleaning