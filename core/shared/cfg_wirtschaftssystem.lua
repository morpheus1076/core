return {
    zentralLager = {
        einkauf = {
            id = 'einkauf_lager_01',
            type = 'stash',
            label = 'Einkaufslager 01',
            slots = 100,
            weight = 1000000,
            groups = ({["gwa"] = 1}),
            owner = false,
            coords = vec3(936.530518, -1466.695312, 29.249493),
            distance = 1.5,
            debug = false
        },
        einkauf2 = {
            id = 'einkauf_lager_02',
            type = 'stash',
            label = 'Einkaufslager 02 Illegal',
            slots = 100,
            weight = 1000000,
            groups = ({["gwa"] = 1}),
            owner = false,
            coords = vec3(936.530518, -1466.695312, 29.249493),
            distance = 1.5,
            debug = false
        },
        verteiler = {
            id = 'verteiler_lager_01',
            type = 'stash',
            label = 'Verteilerlager 01',
            slots = 100,
            weight = 1000000,
            groups = ({["gwa"] = 1}),
            owner = false,
            coords = vec3(945.070618, -1466.561523, 29.432899),
            distance = 1.5,
            debug = false
        },
        twenty = {
            id = 'twenty_lager_01',
            type = 'stash',
            label = 'Twenty Lager 01',
            slots = 100,
            weight = 1000000,
            groups = ({["gwa"] = 1}),
            owner = false,
            coords = vec3(945.070618, -1466.561523, 29.432899),
            distance = 1.5,
            debug = false
        },
        liquor = {
            id = 'liquor_lager_01',
            type = 'stash',
            label = 'Liquor Lager 01',
            slots = 100,
            weight = 1000000,
            groups = ({["gwa"] = 1}),
            owner = false,
            coords = vec3(945.070618, -1466.561523, 29.432899),
            distance = 1.5,
            debug = false
        },

    },
    maxLevels = {
        eating = {
            {item = 'brot', minAmount = 100},
            {item = 'sandwich', minAmount = 100},
            {item = 'burger', minAmount = 100},
            {item = 'hotdog', minAmount = 100},
        },
        drinking = {
            {item = 'wasser', minAmount = 200},
            {item = 'sprunk', minAmount = 200},
            {item = 'cola', minAmount = 200},
            {item = 'bier', minAmount = 120},
        },
        tools = {

        },
        stuff = {
            {item = 'blaettchen', minAmount = 50},
            {item = 'holzfasern', minAmount = 20},
            {item = 'eisenbarren', minAmount = 20},
        }
    },
    production = {
        {
            item = 'hotdog',
            zutaten = {
                getreide = 15,
                salat = 4,
                tomate = 8,
                amount = 20
            }
        },
        {
            item = 'burger',
            zutaten = {
                getreide = 20,
                salat = 4,
                tomate = 4,
                amount = 20
            }
        },
        {
            item = 'sandwich',
            zutaten = {
                getreide = 20,
                salat = 5,
                tomate = 5,
                amount = 20
            }
        },
        {
            item = 'brot',
            zutaten = {
                getreide = 20,
                salat = 5,
                amount = 30
            }
        },
        {
            item = 'wasser',
            zutaten = {
                wasser = 5,
                garbage = 5,
                amount = 20
            }
        },
        {
            item = 'bier',
            zutaten = {
                wasser = 5,
                getreide = 15,
                amount = 8
            }
        },
        {
            item = 'cola',
            zutaten = {
                wasser = 5,
                tomate = 5,
                amount = 10
            }
        },
        {
            item = 'sprunk',
            zutaten = {
                wasser = 5,
                orange = 5,
                amount = 10
            }
        },
        {
            item = 'eisenbarren',
            zutaten = {
                eisenerz = 30,
                amount = 10
            }
        },
        {
            item = 'holzfasern',
            zutaten = {
                holz = 2,
                amount = 5
            }
        },
        {
            item = 'blaettchen',
            zutaten = {
                holzfasern = 2,
                amount = 10
            }
        },
    }
}