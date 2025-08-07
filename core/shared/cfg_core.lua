return {
    weathercycle = true,

    StatusesCheckTime = 30000,       -- health etc. Checktime zum veringern von Health etc.
    HealthReduce = 1,                -- Wert der vom Health abgezogen wird, wenn zuviel Hunger oder Durst.

    weathercyclus = true,            -- true = 'Cyclus, false = 'Network'

    mapcomponents = true,            -- true = 'Farbliche Darstellung von Spots auf der Map'
    mapcomponentscolor = 27,         -- HudColor (27 = rot)

    trains = true,                   -- Züge auf der Map
    tramps = true,                   -- Straßenbahen auf der Map

    npcaktiv = true,                 -- NPC´s aktivieren
    NpcPopulationBudget = 3,         -- 3 =aktiv und max. , 0=deaktiviert
    VehiclePopulationBudget = 3,     -- 3 =aktiv und max. , 0=deaktiviert
    NumberOfParkedVehicles = 0,      -- 3 =aktiv und max. , 0=deaktiviert
    PedInteriotMultiplier = 0.2,     -- 0.0 bis 1.0
    PedExtiriorMultiplier = 0.2,     -- 0.0 bis 1.0
    PedMultiplier = 0.3,             -- 0.0 bis 1.0
    VehicleMultiplier = 0.3,         -- 0.0 bis 1.0
    RandomVehicleMultiplier = 0.2,   -- 0.0 bis 1.0
    ParkedVehicleMultiplier = 0.0,   -- 0.0 bis 1.0
    Scenarios = true,                -- Scenarios aktivieren/deaktivieren, NPC(Police, Gangs, Ambulance)

    MapAudioAus = true,              -- Schlatet alle bekannten AudioScenarios auf der Map aus.
    BigMap = true,                   -- Nutzen der BigMap-Funktion mit Taste "z"
    VehSpawnInfo = false,            -- ServerKonsolen Eintrag, wenn ein Fahrzeug aus der DB gespawnt wird?

    useGroupBlips = true,            -- Blips für die eigenen Gruppenmitglieder anzeigen, nicht bei Arbeitslos.
    useGroupProduction = true,       -- Produktionen der Gruppen nutzen, wie Trocknung Afghanen(Vagos) etc.
    groupProductionTime = 20,        -- Dauer der Gruppen-Produktionen in Minuten.
    BlackmoneyAktiv = true,          -- Schwarzgeldumtausch aktiv?
    BlackmoneyChange = 0.7,          -- 70% vom Schwarzgeld als Money auszahlen.
    BlackmoneyOwner = 'gwa',         -- Besitzer des Schwarzgeldumtauschs

    FarmingAktiv = true,             -- Farming aktivieren?
    --ObjectFarminAktiv = true,        -- Objekte zum Farmen aktivieren?
    FarmingBlipsAktiv = true,        -- FarmBlips ?

    PointsystemUse = true,           -- Use Craft-, Farm-, Business-, Crime- --- Pointsystem
    Vehshop = true,                  -- Fahrzeuggeschäft nutzen
    PaycheckUse = true,              -- Paychecksystem nutzen
    PaycheckTime = 30,               -- Minuten bis zur nächsten Auszahlung.
    FreeGargeUse = true,             -- Eigenes Garagensystem nutzen
    HousingUse = true,               -- Eigenes Housing System nutzen
    HospitalUse = true,              -- Hospital NPCs für Heilung gegen Geld.
    AuftraggeberUse = true,          -- Auftraggeber für Framjobs etc. nutzen?
    ElevatorsUse = true,             -- Fahrstuhlsystem nutzen?
    VehicleDealershipUse = true,     -- VehicleDealer nutzen?

    commandlist = {
        {command = 'commands', nutzen = 'Liste aller eigenen Commands.'},
        {command = 'dropPlayer', nutzen = 'Kick von einem Spieler(arg1) mit Angabe des Grundes(arg2).'},
        {command = 'nuifocusoff', nutzen = 'Bei Fehler mit NuiFocus und Curser.'},
    },

    Class = {
        { id = 0, name = 'compacts', label = 'Kompakt' },
        { id = 1, name = 'sedans', label = 'Limousine' },
        { id = 2, name = 'suvs', label = 'SUV' },
        { id = 3, name = 'coupes', label = 'Coupe' },
        { id = 4, name = 'muscle', label = 'Musle Car' },
        { id = 5, name = 'sportsclassic', label = 'Sportler Klassik' },
        { id = 6, name = 'sports', label = 'Sportwagen' },
        { id = 7, name = 'super', label = 'Super Sportler' },
        { id = 8, name = 'motorcycles', label = 'Motorräder' },
        { id = 9, name = 'off-road', label = 'Off-Road' },
        { id = 10, name = 'industrial', label = 'Industrie' },
        { id = 11, name = 'utility', label = 'Arbeit' },
        { id = 12, name = 'vans', label = 'Van' },
        { id = 13, name = 'cycles', label = 'Fahrrad' },
        { id = 14, name = 'boats', label = 'Boot' },
        { id = 15, name = 'helicopters', label = 'Helikopter' },
        { id = 16, name = 'planes', label = 'Flugzeug' },
        { id = 17, name = 'service', label = 'Einsatz' },
        { id = 18, name = 'emergency', label = 'Einsatz' },
        { id = 19, name = 'military', label = 'Militär' },
        { id = 20, name = 'commercial', label = 'Kommerziell' },
        { id = 21, name = 'trains', label = 'Zug' },
        { id = 22, name = 'openwheel', label = 'Formel' },
    },

    Trunk = {
        {category = 0, trunk = 168000},		-- Compact
        {category = 1, trunk = 328000},		-- Sedan
        {category = 2, trunk = 408000},		-- SUV
        {category = 3, trunk = 248000},		-- Coupe
        {category = 4, trunk = 328000},		-- Muscle
        {category = 5, trunk = 248000},		-- Sports Classic
        {category = 6, trunk = 248000},		-- Sports
        {category = 7, trunk = 168000},		-- Super
        {category = 8, trunk = 40000},		-- Motorcycle
        {category = 9, trunk = 408000},		-- Offroad
        {category = 10, trunk = 408000},	-- Industrial
        {category = 11, trunk = 328000},	-- Utility
        {category = 12, trunk = 488000},	-- Van
        {category = 14, trunk = 0},         -- Boats
        {category = 15, trunk = 0},         -- Helicopter
        {category = 16, trunk = 0},         -- Plane
        {category = 17, trunk = 328000},	-- Service
        {category = 18, trunk = 328000},	-- Emergency
        {category = 19, trunk = 328000},	-- Military
        {category = 20, trunk = 328000},	-- Commercial
    },

    Glovebox = {
        {category = 0, glovebox = 8000},		-- Compact
        {category = 1, glovebox = 8000},		-- Sedan
        {category = 2, glovebox = 8000},		-- SUV
        {category = 3, glovebox = 8000},		-- Coupe
        {category = 4, glovebox = 8000},		-- Muscle
        {category = 5, glovebox = 8000},		-- Sports Classic
        {category = 6, glovebox = 8000},		-- Sports
        {category = 7, glovebox = 8000},		-- Super
        {category = 8, glovebox = 4000},		-- Motorcycle
        {category = 9, glovebox = 8000},		-- Offroad
        {category = 10, glovebox = 8000},		-- Industrial
        {category = 11, glovebox = 8000},		-- Utility
        {category = 12, glovebox = 8000},		-- Van
        {category = 14, glovebox = 148000},	    -- Boat
        {category = 15, glovebox = 122000},	    -- Helicopter
        {category = 16, glovebox = 241000}, 	-- Plane
        {category = 17, glovebox = 8000},		-- Service
        {category = 18, glovebox = 8000},		-- Emergency
        {category = 19, glovebox = 8000},   	-- Military
        {category = 20, glovebox = 8000},		-- Commercial (trucks)
    },

    GtaIplBlips = {
        {name = 'Apartment Low Small', door = 'yes', coords = vec3(-111.71161,-11.91202,69.52825), gebiet = 'Vinewood West'},
        {name = 'Tequilala', door = 'yes', coords = vec3(-555.251, 285.452, 82.176), gebiet = 'Vinewood West'},
        {name = 'Floor to Roof', door = 'yes', coords = vec3(-1570.908, -3226.749, 26.336), gebiet = 'Flughafen City'},
        {name = 'Office NICE Door must closed', door = 'no', coords = vec3(-1006.687, -479.259, 50.027), gebiet = 'Rockford Hills'}, -- prüfen in Bob74
        {name = 'Michael Villa', door = 'yes', coords = vec3(-810.840, 179.724, 72.153), gebiet = 'Rockford Hills'},
        {name = 'Lifeinvader', door = 'yes', coords = vec3(-1080.252, -250.062, 37.763), gebiet = 'Rockford Hills'},
        {name = 'House under Construction', door = 'yes', coords = vec3(-587.171, -286.010, 35.455), gebiet = 'Rockford Hills'},
        {name = 'Garage Carpark', door = 'yes', coords = vec3(-36.944, -615.718, 35.100), gebiet = 'Pillbox Hill'},
        {name = 'Recycling Halle', door = 'yes', coords = vec3(-587.459, -1607.905, 27.011), gebiet = 'La Puerta'},
        {name = 'Maze Bank Arena', door = 'yes', coords = vec3(-257.823, -2024.001, 30.146), gebiet = 'Maze Bank Arena'},
        {name = 'Bahama Mama', door = 'yes', coords = vec3(-1395.681, -600.032, 30.315), gebiet = 'Del Perro'}, -- prüfen in Bob74, da kein interior Möbel geladen
        {name = 'Juwelier City', door = 'yes', coords = vec3(-622.220, -230.617, 38.062), gebiet = 'Rockford Hills'},
        {name = 'Textielfabrik', door = 'yes', coords = vec3(717.092, -964.731, 30.395), gebiet = 'La Mesa'},
        {name = 'Dock Kontrollraum', door = 'yes', coords = vec3(568.851, -3124.156, 18.769), gebiet = 'Elysian Island'},
        {name = 'Kleiner Keller', door = 'yes', coords = vec3(144.163, -2201.703, 4.688), gebiet = 'Banning'},
        {name = 'ChopShop Fahrzeug Diebstahl', door = 'yes', coords = vec3(478.996, -1316.762, 29.204), gebiet = 'Strawberry'},
        {name = 'Coroner', door = 'no', coords = vec3(250.412, -1368.321, 24.538), gebiet = 'Strawberry'}, -- Fahrstuhl funktional?
        {name = 'Unicorn', door = 'yes', coords = vec3(128.314, -1291.409, 29.270), gebiet = 'Strawberry'},
        {name = 'Franklins House', door = 'yes', coords = vec3(-14.190, -1436.320, 31.119), gebiet = 'Strawberry'},
        {name = 'Garage klein', door = 'yes', coords = vec3(-1078.716, -1678.836, 4.575), gebiet = 'La Puerta'},
        {name = 'Farmhouse / Lab im Keller', door = 'yes', coords = vec3(2440.583, 4977.333, 46.811), gebiet = 'Grapeseed'},
        {name = 'Fort Zancudo Tower 1', door = 'yes', coords = vec3(-2344.501, 3267.155, 32.811), gebiet = 'Fort Zancudo'},
        {name = 'MethLab über Liqour', door = 'yes', coords = vec3(1392.358, 3604.838, 34.981), gebiet = 'Sandy Shores'},
        {name = 'Sheriff Office Sandy', door = 'yes', coords = vec3(1853.548, 3685.560, 34.267), gebiet = 'Sandy Shores'},
        {name = 'Yellow Jacks', door = 'yes', coords = vec3(1985.933, 3051.505, 47.215), gebiet = 'Grand Senora Wüste'},
        {name = 'Trailer Dirty', door = 'yes', coords = vec3(1972.725, 3816.970, 33.429), gebiet = 'Sandy Shores'},
        {name = 'Human Labs Wasserzugang', door = 'yes', coords = vec3(3526.192, 3710.401, 20.992), gebiet = 'Human Labs'},
        {name = 'Franklins Villa', door = 'yes', coords = vec3(7.324, 536.405, 176.028), gebiet = 'Vinewood Hills'},
        {name = 'Cyber Garage', door = 'yes', coords = vec3(2330.311, 2572.371, 46.679), gebiet = 'Ron Alternates Windpark'},
        {name = 'Land Act Staudamm', door = 'yes', coords = vec3(1660.938, 0.852, 166.118), gebiet = 'Land Act Staudamm'},
        {name = 'Chicken Fabrik', door = 'yes', coords = vec3(-67.226, 6242.493, 31.080), gebiet = 'Paleto Bay'},
        {name = 'Sheriff Office Paleto', door = 'yes', coords = vec3(-445.013, 6014.639, 31.716), gebiet = 'Paleto Bay'},
        {name = 'Trevors Appartment', door = 'yes', coords = vec3(-1152.045, -1517.892, 10.633), gebiet = 'La Puerta'},
        {name = 'Feuerwache', door = 'yes', coords = vec3(1200.689, -1471.466, 34.860), gebiet = 'El Burro Heights'},
        {name = 'Feuerwache2', door = 'yes', coords = vec3(202.989, -1655.668, 29.803), gebiet = 'Davis'},
        {name = 'Bennys Tuning', door = 'yes', coords = vec3(-212.390, -1324.382, 30.890), gebiet = 'Strawberry'},
    },

    CustomMloBlips = {
        {name = 'Taco Laden', inuse = 'yes', coords = vec3(16.766, -1602.194, 29.391), gebiet = 'Strawberry', datei = "mlo_crux-thetacofarmer"},
        {name = 'Bahama Mama West', inuse = 'no', coords = vec3(-1394.974, -598.660, 30.320), gebiet = 'Sel Perro', datei = "mlo_Bahama_Mamas"},
        {name = 'Mansion 18', inuse = 'no', coords = vec3(-1569.811, 26.496, 59.554), gebiet = 'Richman', datei = "mlo_brofx_mansion_18"},
        {name = 'Little Seoul Kleidungsladen', inuse = 'no', coords = vec3(-804.126, -599.382, 30.275), gebiet = 'Little Seoul', datei = "mlo_korean_patoche_shop"},
        {name = 'Lucky Plucker', inuse = 'no', coords = vec3(-586.214, -876.175, 25.918), gebiet = 'Little Seoul', datei = "mlo_pablito_lucky_plucker"},
        {name = 'Cayo Shops', inuse = 'yes', coords = vec3(4484.085, -4471.842, 4.222), gebiet = 'Cayo Perico', datei = "mlo_Perico_Shops"},
        {name = 'Taxi Office', inuse = 'no', coords = vec3(910.190, -172.317, 74.201), gebiet = 'East Vinewood', datei = "mlo_TaxiOffice"},
        {name = 'Tequilala Box Bar', inuse = 'no', coords = vec3(-566.066, 284.214, 77.677), gebiet = 'Vinewood West', datei = "mlo_tequilala"},
        {name = 'Medical Center LS', inuse = 'no', coords = vec3(1145.810, -1534.932, 35.381), gebiet = 'El Burro Heights', datei = "mlo_thunder_medicalcenter"},
        {name = 'Vagos Hood', inuse = 'yes', coords = vec3(979.092, -1824.349, 31.180), gebiet = 'La Mesa', datei = "mlo_vagos"},
        {name = '24/7 Vinewood Plaza', inuse = 'yes', coords = vec3(191.782, -23.059, 69.920), gebiet = 'Hawick', datei = "mlo_vwp_247shop"},
        {name = 'Wiwang Tower', inuse = 'no', coords = vec3(-820.124, -713.455, 123.284), gebiet = 'Little Seoul', datei = "mlo_wiwangtower"},
        {name = 'Arbeitsbereich', inuse = 'no', coords = vec3(2524.370, 4119.965, 38.918), gebiet = 'Grapeseed', datei = "mlo_gcom_workshop"},
        {name = 'Antique Bar', inuse = 'no', coords = vec3(-543.893, -48.952, 42.420), gebiet = 'Burton', datei = "mlo_ds_antique_bar"},
        {name = 'Waschsalon', inuse = 'no', coords = vec3(892.221, -1039.358, 35.252), gebiet = 'La Mesa', datei = "mlo_lev_laundromat"},
        {name = 'Haus', inuse = 'no', coords = vec3(1105.320, -411.420, 67.606), gebiet = 'Mirror Park', datei = "mlo_mrp_house"},
        {name = 'Haus', inuse = 'no', coords = vec3(904.248, -485.282, 59.470), gebiet = 'Mirror Park', datei = "mlo_mrp_house"},
        {name = 'Haus', inuse = 'no', coords = vec3(957.673, -671.112, 58.489), gebiet = 'Mirror Park', datei = "mlo_mrp_house"},
        {name = 'Haus', inuse = 'no', coords = vec3(918.080, -566.466, 58.412), gebiet = 'Mirror Park', datei = "mlo_mrp_house"},
        {name = 'Pharmacy', inuse = 'no', coords = vec3(-509.751, 285.866, 83.388), gebiet = 'Vinewood West', datei = "mlo_dip_pharmacyy"},
        {name = '24/7', inuse = 'no', coords = vec3(-499.306, 285.569, 83.386), gebiet = 'Vinewood West', datei = "mlo_dip_store"},
        {name = 'Luxury Car Dealer', inuse = 'no', coords = vec3(-187.395, -1155.023, 23.048), gebiet = 'Pillbox Hill', datei = "mlo_dip_cardealer"},
        {name = 'Motorrad Dealer', inuse = 'no', coords = vec3(-870.731, -193.782, 37.837), gebiet = 'Rockford Hills', datei = "mlo_MotoDealer"},
    },

    Multiplier = {
        {type = 'farm', range = 0, multiplier = 0.0},
        {type = 'farm', range = 1, multiplier = 0.1},
        {type = 'farm', range = 2, multiplier = 0.2},
        {type = 'farm', range = 3, multiplier = 0.4},
        {type = 'farm', range = 4, multiplier = 0.6},
        {type = 'farm', range = 5, multiplier = 0.8},
    }
}