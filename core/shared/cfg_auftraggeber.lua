
return {
    maxOrders = 5,
    legalCount = 3,
    illegalCount = 3,
    legalBuyer = 'staat',
    illegalBuyer = 'staat',
    legalLager = 'einkauf_lager_01',
    illegalLager = 'einkauf_lager_02',

    legalPed = {
        model = 'IG_WarehouseBoss',
        coords = vec3(961.203, -1550.415, 30.742),
        heading = 291.813,
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        targetable = true,
    },

    legalBlip = {
        name = 'Auftragsgeber',
        sprite = 650,
        color = 43,
        scale = 0.5,
        hidden = false,
    },

    legaljobs = {
        {
            id = 1,
            name = 'salaternte',
            title = 'Salaternte',
            description = 'Liefere 120x Salat, von den Feldern',
            earning = 810,
            items = {name = 'salat', amount = 100, label = 'Salat'},
            atype = 'legal'
        },
        {
            id = 2,
            name = 'wollernte',
            title = 'Wollernte',
            description = 'Liefere Wolle, von den Feldern',
            earning = 890,
            items = {name = 'wolle', amount = 120, label = 'Wolle'},
            atype = 'legal'
        },
        {
            id = 3,
            name = 'getreideernte',
            title = 'Getreideernte',
            description = 'Unterstütze den Bauern und liefere Getreide',
            earning = 820,
            items = {name = 'getreide', amount = 215, label = 'Getreide'},
            atype = 'legal'
        },
        {
            id = 4,
            name = 'tomatenernte',
            title = 'Tomatenernte',
            description = 'Unterstütze den Bauern und liefere Tomaten',
            earning = 972,
            items = {name = 'tomate', amount = 193, label = 'Tomaten'},
            atype = 'legal'
        },
        {
            id = 5,
            name = 'zwiebelernte',
            title = 'Zwiebelernte',
            description = 'Unterstütze den Bauern und liefere Zwiebeln',
            earning = 750,
            items = {name = 'zwiebel', amount = 180, label = 'Zwiebeln'},
            atype = 'legal'
        },
        {
            id = 6,
            name = 'orangenernte',
            title = 'Orangenernte',
            description = 'Unterstütze den Bauern und liefere Orangen',
            earning = 890,
            items = {name = 'orange', amount = 400, label = 'Orangen'},
            atype = 'legal'
        },
        {
            id = 7,
            name = 'gewuerzlieferung',
            title = 'Gewürzlieferung',
            description = 'Liefer bitte Gewürze.',
            earning = 2300,
            items = {name = 'gewuerz', amount = 155, label = 'Gewürze'},
            atype = 'legal'
        },
    }
}