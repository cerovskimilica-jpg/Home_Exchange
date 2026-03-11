SELECT
  * EXCEPT(department),
  CASE
    WHEN department = 'Vandea' THEN 'Vendée'
    WHEN department = 'Pirineos Atlánticos' THEN 'Pyrénées-Atlantiques'
    WHEN department = 'Senna e Marna' THEN 'Seine-Et-Marne'
    WHEN department IN ('Parigi', 'Parijs', 'Arrondissement De Paris') THEN 'Paris'
    WHEN department IN ('Dordogna','Dordoña') THEN 'Dordogne'
    WHEN department = 'Maine-et-Loire' THEN 'Maine-Et-Loire'
    WHEN department = 'Alta Garonna' THEN 'Haute-Garonne'
    WHEN department IN ('Maritime Alps', 'Alpi Marittime') THEN 'Alpes Maritimes'
    WHEN department = 'Forest Of Rambouillet' THEN 'Rambouillet'
    WHEN department = 'Pirineos Orientales' THEN 'Pyrénées-Orientales'
    WHEN department = 'Senna Marittima' THEN 'Seine-Maritime'
    WHEN department IN ('Alta Saboya', 'Alta Savoia') THEN 'Haute-Savoie'   
    WHEN department = 'Val-de-Marne' THEN 'Val-De-Marne'
    WHEN department = 'Indre e Loira' THEN 'Indre-Et-Loire'
    WHEN department = 'Hauts-de-Seine' THEN 'Hauts-De-Seine'
    WHEN department = 'Gironda' THEN 'Gironde'
    WHEN department IN ('Bocche del Rodano','Bouches-du-Rhône') THEN 'Bouches-Du-Rhône'    
    WHEN department = 'arrondissement de Cayenne' THEN 'Arrondissement de Cayenne'     
    WHEN department = 'Loira Atlántico' THEN 'Loire-Atlantique'
    WHEN department = 'Mancha' THEN 'Manche'
    WHEN department = 'Ille-et-Vilaine' THEN 'Ille-Et-Vilaine'
    WHEN department = 'Mosel' THEN 'Moselle'
    WHEN department = 'Rodano' THEN 'Rhône'
    WHEN department = 'Saboya' THEN 'Savoie'
    WHEN department = 'Soma' THEN 'Somme'
    WHEN department = 'Rodano' THEN 'Rhône'
    WHEN department = 'Rodano' THEN 'Rhône'
    ELSE department
  END AS department_clean
FROM {{ ref('stg_raw_data__exchanges') }}  
