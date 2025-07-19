ConfigVehShop = {}

ConfigVehShop.Trunks = {
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
    {category = 14, trunk = 0}, -- Boats
    {category = 15, trunk = 0},-- Helicopter
    {category = 16, trunk = 0}, -- Plane
    {category = 17, trunk = 328000},	-- Service
    {category = 18, trunk = 328000},	-- Emergency
    {category = 19, trunk = 328000},	-- Military
    {category = 20, trunk = 328000},	-- Commercial
}

ConfigVehShop.Glovebox = {
    {category = 0, trunk = 8000},		-- Compact
    {category = 1, trunk = 8000},		-- Sedan
    {category = 2, trunk = 8000},		-- SUV
    {category = 3, trunk = 8000},		-- Coupe
    {category = 4, trunk = 8000},		-- Muscle
    {category = 5, trunk = 8000},		-- Sports Classic
    {category = 6, trunk = 8000},		-- Sports
    {category = 7, trunk = 8000},		-- Super
    {category = 8, trunk = 4000},		-- Motorcycle
    {category = 9, trunk = 8000},		-- Offroad
    {category = 10, trunk = 8000},		-- Industrial
    {category = 11, trunk = 8000},		-- Utility
    {category = 12, trunk = 8000},		-- Van
    {category = 14, trunk = 148000},	-- Boat
    {category = 15, trunk = 122000},	-- Helicopter
    {category = 16, trunk = 241000}, 	-- Plane
    {category = 17, trunk = 8000},		-- Service
    {category = 18, trunk = 8000},		-- Emergency
    {category = 19, trunk = 8000},   	-- Military
    {category = 20, trunk = 8000},		-- Commercial (trucks)
}

ConfigVehShop.Vehshops = {
    {
        id = 'pdmcity',
        name = 'PDM City',
        type = 'car',
        coords = vec3(-56.8223, -1098.7139, 26.4224),
        category = {'sedans', 'sports', 'super', 'compacts', 'muscle'},
        --- BLIP
        sprite = 524,
        color = 28,
        scale = 0.5,
        hidden = true,
        blipenabled = true,
        --- PED
        ped ='IG_Car3guy1',
        pedhash = 0x84F9E937,
        scenario = 'WORLD_HUMAN_AA_SMOKE',
        pedenabled = true,
        pedheading = 26.6334,
        --- TARGET
        size = {1.5,1.5,1.5},
        heading = 0,
        options = {name ='Fahrzeughandel', onSelect = function() lib.showContext('pdmcitymenu')  end , icon ='fas fa-dollar', iconColor ='#008000', label ='Verkäufer ansprechen'},
        --- Fahrzeug spawn
        spawnpoint = {coords = {-44.5762, -1098.6865, 26.4224}, heading = 249.1384},
        shopmenu = 'pdmcitymenu',
    },
    {
        id = 'harmony',
        name = 'Harmony',
        type = 'car',
        coords = vec3(1224.7585, 2728.0542, 38.0048),
        category = {'off-road', 'motorcycles', 'suvs'},
        --- BLIP
        sprite = 524,
        color = 28,
        scale = 0.5,
        hidden = true,
        blipenabled = true,
        --- PED
        ped ='IG_Car3guy1',
        pedhash = 0x84F9E937,
        scenario = 'WORLD_HUMAN_AA_SMOKE',
        pedenabled = true,
        pedheading = 167.244,
        --- TARGET
        size = {1.5,1.5,1.5},
        heading = 0,
        options = {name = 'Offroadhandel', onSelect = function() lib.showContext('harmonymenu')  end, icon = 'fas fa-dollar', iconColor = '#008000', label = 'Verkäufer ansprechen'},
        --- Fahrzeug spawn
        spawnpoint = {coords = {1224.8740, 2715.5986, 38.0058}, heading = 177.9416},
        shopmenu = 'harmonymenu'
    },
    {
        id = 'trucks',
        name = 'Trucks and Vans',
        type = 'car',
        coords = vec3(801.3896, -2502.3550, 22.1329),
        category = {'vans', 'commercial'},
        --- BLIP
        sprite = 524,
        color = 28,
        scale = 0.5,
        hidden = true,
        blipenabled = true,
        --- PED
        ped ='IG_Car3guy1',
        pedhash = 0x84F9E937,
        scenario = 'WORLD_HUMAN_AA_SMOKE',
        pedenabled = true,
        pedheading = 90.70,
        --- TARGET
        size = {1.5,1.5,1.5},
        heading = 0,
        options = {name = 'Truckshandel', onSelect = function() lib.showContext('truckmenu')  end, icon = 'fas fa-dollar', iconColor = '#008000', label = 'Verkäufer ansprechen'},
        --- Fahrzeug spawn
        spawnpoint = {coords = {795.8745, -2483.2068, 21.2925}, heading = 103.5331},
        shopmenu = 'truckmenu'
    },
    {
        id = 'boats',
        name = 'Boote',
        type = 'boats',
        coords = vec3(-718.195, -1327.053, 1.596),
        category = {'boats'},
        --- BLIP
        sprite = 410,
        color = 3,
        scale = 0.5,
        hidden = true,
        blipenabled = true,
        --- PED
        ped ='a_m_y_business_02',
        pedhash = 0xB3B3F5E6,
        scenario = 'WORLD_HUMAN_AA_SMOKE',
        pedenabled = true,
        pedheading =  55.130,
        --- TARGET
        size = {1.5,1.5,1.5},
        heading = 0,
        options = {name = 'Bootshandel', onSelect = function() lib.showContext('boatsmenu')  end, icon = 'fas fa-dollar', iconColor = '#008000', label = 'Verkäufer ansprechen'},
        --- Fahrzeug spawn
        spawnpoint = {coords = {-728.277, -1356.242, 2.112}, heading = 135.012},
        shopmenu = 'boatsmenu'
    },
}

ConfigVehShop.Menu = {
    {category = 'muscle', menulabel = 'Muscle', shopmenu = 'pdmcitymenu', hmenu = 'PDM City'},
    {category = 'compacts', menulabel = 'Kompaktwagen', shopmenu = 'pdmcitymenu', hmenu = 'PDM City'},
    {category = 'sports', menulabel = 'Sportwagen', shopmenu = 'pdmcitymenu', hmenu = 'PDM City'},
    {category = 'sportsclassics', menulabel = 'Sport Classics', shopmenu = 'pdmcitymenu', hmenu = 'PDM City'},
    {category = 'super', menulabel = 'Super Sportler', shopmenu = 'pdmcitymenu', hmenu = 'PDM City'},
    {category = 'sedans', menulabel = 'Limousinen', shopmenu = 'pdmcitymenu', hmenu = 'PDM City'},
    {category = 'off-road', menulabel = 'Offroad', shopmenu = 'harmonymenu', hmenu = 'Harmony'},
    {category = 'suvs', menulabel = 'SUV', shopmenu = 'harmonymenu', hmenu = 'Harmony'},
    {category = 'motorcycles', menulabel = 'Motorrad', shopmenu = 'harmonymenu', hmenu = 'Harmony'},
    {category = 'vans', menulabel = 'Vans', shopmenu = 'truckmenu', hmenu = 'Trucks and Vans'},
    {category = 'commercial', menulabel = 'LKW', shopmenu = 'truckmenu', hmenu = 'Trucks and Vans'},
    {category = 'boats', menulabel = 'Boote', shopmenu = 'boatsmenu', hmenu = 'Bootshandel'},
    {category = 'coupes', menulabel = 'Coupes', shopmenu = 'pdmcitymenu', hmenu = 'PDM City'},
    {category = 'cycles', menulabel = 'Fahrräder', shopmenu = 'pdmcitymenu', hmenu = 'PDM City'},
    {category = 'emergency', menulabel = 'Einsatzfahrzeuge', shopmenu = 'pdmcitymenu', hmenu = 'PDM City'},
    {category = 'helicopters', menulabel = 'Helikopter', shopmenu = 'pdmcitymenu', hmenu = 'PDM City'},
    {category = 'industrial', menulabel = 'Industrial', shopmenu = 'pdmcitymenu', hmenu = 'PDM City'},
    {category = 'military', menulabel = 'Militär', shopmenu = 'pdmcitymenu', hmenu = 'PDM City'},
    {category = 'openwheel', menulabel = 'Open Wheel', shopmenu = 'pdmcitymenu', hmenu = 'PDM City'},
    {category = 'planes', menulabel = 'Flugzeuge', shopmenu = 'pdmcitymenu', hmenu = 'PDM City'},
    {category = 'service', menulabel = 'Service', shopmenu = 'pdmcitymenu', hmenu = 'PDM City'},
    {category = 'trains', menulabel = 'Züge', shopmenu = 'pdmcitymenu', hmenu = 'PDM City'},
    {category = 'utility', menulabel = 'Utility', shopmenu = 'pdmcitymenu', hmenu = 'PDM City'},
}