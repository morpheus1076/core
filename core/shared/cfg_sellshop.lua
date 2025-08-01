CfgSellShop = {}

CfgSellShop.Shops = {
    export01 = {
        coords = vec3(1007.384, -2902.172, 5.901),
        heading = 197.936,
        ped = 'A_M_Y_Business_03',
        pedhash = 0xA1435105,
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        zonename = 'export01',
        label = 'Exporteur',
        blipsprite = 500,
        blipcolor = 2,
        blipscale = 0.5,
        bliphidden = false,
        items = {
            {item = 'salat', label = 'Salat', minprice = 2, maxprice = 6, currency = 'money', buyer = 'staat', lager = 'einkauf_lager_01'},
            {item = 'zwiebel', label = 'Zwiebel', minprice = 2, maxprice = 6, currency = 'money', buyer = 'staat', lager = 'einkauf_lager_01'},
            {item = 'orange', label = 'Orange', minprice = 2, maxprice = 6, currency = 'money', buyer = 'staat', lager = 'einkauf_lager_01'},
            {item = 'tomate', label = 'Tomate', minprice = 2, maxprice = 4, currency = 'money', buyer = 'staat', lager = 'einkauf_lager_01'},
            {item = 'getreide', label = 'Getreide', minprice = 2, maxprice = 4, currency = 'money', buyer = 'staat', lager = 'einkauf_lager_01'},
            {item = 'wolle', label = 'Wolle', minprice = 2, maxprice = 4, currency = 'money', buyer = 'staat', lager = 'einkauf_lager_01'},
            {item = 'aramidfasern', label = 'Aramidfasern', minprice = 2, maxprice = 5, currency = 'money', buyer = 'staat', lager = 'einkauf_lager_01'},
            {item = 'kautschuk', label = 'Kautschuk', minprice = 2, maxprice = 4, currency = 'money', buyer = 'staat', lager = 'einkauf_lager_01'},
            {item = 'farbe', label = 'Farbe', minprice = 2, maxprice = 5, currency = 'money', buyer = 'staat', lager = 'einkauf_lager_01'},
            {item = 'eisenerz', label = 'Eisenerz', minprice = 4, maxprice = 9, currency = 'money', buyer = 'staat', lager = 'einkauf_lager_01'},
            {item = 'eisenbarren', label = 'Eisenbarren', minprice = 10, maxprice = 25, currency = 'money', buyer = 'staat', lager = 'einkauf_lager_01'},
            {item = 'wasser', label = 'Wasser', minprice = 1, maxprice = 1, currency = 'money', buyer = 'staat', lager = 'einkauf_lager_01'},
        },
    },
    muellabgabe = {
        coords = vec3(-349.618, -1568.667, 25.227),
        heading = 335.995,
        ped = 'CS_Old_Man2',
        pedhash = 0x98F9E770,
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        zonename = 'muellabgabe',
        label = 'Müllverkauf',
        blipsprite = 500,
        blipcolor = 2,
        blipscale = 0.5,
        bliphidden = true,
        items = {
            {item = 'garbage', label = 'Müll', minprice = 1, maxprice = 2, currency = 'money', buyer = 'staat', lager = 'einkauf_lager_01'},
        },
    },
}