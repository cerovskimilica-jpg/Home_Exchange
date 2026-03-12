WITH temp1 AS (
    SELECT
        subscription_date,
        user_id,
        renew,
        first_subscription_date,
        first_subscription,
        referral,
        promotion,
        payment3x,
        payment2,
        payment3,
        country,
        region,
        department,
        city
     FROM `home-exchange-489808.raw_data.subscriptions`
)

SELECT
    * EXCEPT(region, city),

    CASE
        WHEN region = 'Alsace-Champagne-Ardenne-Lorraine' THEN 'Grand Est'

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
        ) THEN 'Nouvelle-Aquitaine'

        WHEN region IN (
            'Alvernia-Rodano-Alps',
            'Auvergne',
            'Auvernia-Ródano-Alpes',
            'Alvernia-Rodano-Alpi'
        ) THEN 'Auvergne-Rhône-Alpes'

        WHEN region IN (
            'Borgoña-Franco-Condado',
            'Bourgogne',
            'Burgundy',
            'Burgundy-Franche-Comte',
            'Franche-Compté',
            'Burgund-Franche-Comté'
        ) THEN 'Bourgogne-Franche-Comté'

        WHEN region IN ('Bretaña', 'Brittany') THEN 'Bretagne'

        WHEN region IN ('Centre', 'Centro-Valle della Loira') THEN 'Centre-Val de Loire'

        WHEN region IN ('Corsica', 'Córcega') THEN 'Corse'

        WHEN region = 'French Guiana' THEN 'Guyane'

        WHEN region IN (
            'Ile-of-France',
            'Ilha-de-França',
            'Isla De Francia',
            'Regione Parigina',
            'Île-de-France'
        ) THEN 'Île-de-France'

        WHEN region IN (
            'Languedoc',
            'Languedoc-Roussillon Midi-Pyrénées',
            'Occitania',
            'Okzitanien'
        ) THEN 'Occitanie'

        WHEN region IN ('Loire Region', 'Países del Loira') THEN 'Pays de la Loire'

        WHEN region IN (
            'Nord-Pas-De-Calais Picardie',
            'Nord-Pas-De-Calais',
            'Picardie',
            'Upper France'
        ) THEN 'Hauts-de-France'

        WHEN region IN ('Normandia', 'Normandy') THEN 'Normandie'

        WHEN region IN (
            'Provenza-Alpes-Costa Azul',
            'Provenza-Costa Azzurra',
            'Provença-Alpes-Costa Azul'
        ) THEN "Provence-Alpes-Côte d’Azur"

        ELSE region
    END AS region,

    CASE
        WHEN city = 'Chamb½uf' THEN 'Chamboeuf'
        WHEN city = 'H½nheim' THEN 'Hoenheim'
        WHEN city = 'H½rdt' THEN 'Hoerdt'
        WHEN city = 'Bergholtz?Zell' THEN 'Bergholtzzell'
        WHEN city = 'Fr½ningen' THEN 'Froeningen'
        WHEN city = 'Vand½uvre-Lès-Nancy' THEN 'Vandoeuvre-lès-Nancy'
        WHEN city = 'J½uf' THEN 'Joeuf'
        WHEN city = 'Vasc½uil' THEN 'Vascoeuil'
        WHEN city = 'Escorneb½uf' THEN 'Escorneboeuf'
        WHEN city IN ('St.-Ouen', 'Saint-Ouen') THEN 'Saint-Ouen-sur-Seine'
        WHEN city = 'Marcq-En-Bar½ul' THEN 'Marcq-En-Baroeul'
        WHEN city = 'Mons-En-Bar½ul' THEN 'Mons-En-Baroeul'
        WHEN city = 'Paimb½uf' THEN 'Paimboeuf'
        WHEN city = 'Salleb½uf' THEN 'Salleboeuf'
        ELSE city
    END AS city

FROM temp1