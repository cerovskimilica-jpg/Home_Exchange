WITH colonne AS (
    SELECT
        conversation_id,
        exchange_id,
        created_at,
        creator_id,
        guest_user_id,
        host_user_id,
        finalized_at,
        canceled_at,
        start_on,
        end_on,
        guest_countguest_count,
        night_count,
        user_cancellation_id,
        exchange_type,
        home_type,
        residence_type,
        capacity,
        country,
        region,
        department,
        city
    FROM `home-exchange-489808.raw_data.exchanges`
)

SELECT
    * EXCEPT(region, department),

    -- Nettoyage REGION
    CASE
        WHEN region = 'Alsace-Champagne-Ardenne-Lorraine'
            THEN 'Grand Est'

        WHEN region IN (
            'Aquitaine Limousin Poitou-Charentes',
            'Neu-Aquitanien',
            'Limousin',
            'New-Aquitaine',
            'Nova-Aquitânia',
            'Nueva Aquitania',
            'Nueva-Aquitania',
            'Nuova-Aquitania',
            'Aquitaine-Limousin-Poitou-Charentes',
            'Poitou-Charentes',
            'New Aquitaine',
            'Aquitaine'
        )
            THEN 'Nouvelle-Aquitaine'

        WHEN region IN (
            'Alvernia-Rodano-Alps',
            'Auvergne',
            'Auvernia-Ródano-Alpes',
            'Alvernia-Rodano-Alpi'
        )
            THEN 'Auvergne-Rhône-Alpes'

        WHEN region IN (
            'Borgoña-Franco-Condado',
            'Bourgogne',
            'Burgundy',
            'Burgundy-Franche-Comte',
            'Franche-Compté',
            'Burgund-Franche-Comté'
        )
            THEN 'Bourgogne-Franche-Comté'

        WHEN region IN ('Bretaña', 'Brittany')
            THEN 'Bretagne'

        WHEN region IN ('Centre', 'Centro-Valle della Loira')
            THEN 'Centre-Val de Loire'

        WHEN region IN ('Corsica', 'Córcega')
            THEN 'Corse'

        WHEN region = 'French Guiana'
            THEN 'Guyane'

        WHEN region IN (
            'Ile-of-France',
            'Ilha-de-França',
            'Isla De Francia',
            'Regione Parigina',
            'Île-de-France'
        )
            THEN 'Île-de-France'

        WHEN region IN (
            'Languedoc',
            'Languedoc-Roussillon Midi-Pyrénées',
            'Occitania',
            'Okzitanien'
        )
            THEN 'Occitanie'

        WHEN region IN ('Loire Region', 'Países del Loira')
            THEN 'Pays de la Loire'

        WHEN region IN (
            'Nord-Pas-De-Calais Picardie',
            'Nord-Pas-De-Calais',
            'Picardie',
            'Upper France'
        )
            THEN 'Hauts-de-France'

        WHEN region IN ('Normandia', 'Normandy')
            THEN 'Normandie'

        WHEN region IN (
            'Provenza-Alpes-Costa Azul',
            'Provenza-Costa Azzurra',
            'Provença-Alpes-Costa Azul'
        )
            THEN "Provence-Alpes-Côte d’Azur"

        ELSE region
    END AS region,

    -- Nettoyage DEPARTMENT
    CASE
        WHEN department = 'Vandea' THEN 'Vendée'
        WHEN department = 'Pirineos Atlánticos' THEN 'Pyrénées-Atlantiques'
        WHEN department = 'Senna e Marna' THEN 'Seine-Et-Marne'
        WHEN department IN ('Parigi','Parijs','Arrondissement De Paris') THEN 'Paris'
        WHEN department IN ('Dordogna','Dordoña') THEN 'Dordogne'
        WHEN department = 'Maine-et-Loire' THEN 'Maine-Et-Loire'
        WHEN department = 'Alta Garonna' THEN 'Haute-Garonne'
        WHEN department IN ('Maritime Alps','Alpi Marittime') THEN 'Alpes-Maritimes'
        WHEN department = 'Forest Of Rambouillet' THEN 'Rambouillet'
        WHEN department = 'Pirineos Orientales' THEN 'Pyrénées-Orientales'
        WHEN department = 'Senna Marittima' THEN 'Seine-Maritime'
        WHEN department IN ('Alta Saboya','Alta Savoia') THEN 'Haute-Savoie'
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
        ELSE department
    END AS department

FROM colonne