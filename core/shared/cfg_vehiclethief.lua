CfgVehThief = {}

CfgVehThief.aktiv = true
CfgVehThief.auftragsCooldownMin = 60   -- in Minuten, bis ein neuer Auftrag zur Verfügung steht, nach Abgabe des letzten. (Random min max, damit keine festen Zeiten.)
CfgVehThief.auftragsCooldownMax = 120   -- in Minuten, bis ein neuer Auftrag zur Verfügung steht, nach Abgabe des letzten. (Random min max, damit keine festen Zeiten.
CfgVehThief.abgabecooldown = 5      -- in Minuten, bis der Auftrag abgegeben werden kann, Zeitaufwand als Ausgleich, bei langen Fahrtwegen.

CfgVehThief.models = {
    [1] = {model = 'adder', minamout = 1000, maxamout = 1800, waittime = 10, maxtime = 20, strafe = 300}, --waittime = Wartezeit, bis Verkauf möglich ist.
    [2] = {model = 'felon', minamout = 1500, maxamout = 1700, waittime = 5, maxtime = 20, strafe = 300}, --waittime = Wartezeit, bis Verkauf möglich ist.
    [3] = {model = 'cogcabrio', minamout = 1800, maxamout = 3500, waittime = 5, maxtime = 20, strafe = 400}, --waittime = Wartezeit, bis Verkauf möglich ist.
}

CfgVehThief.startCoords = {
    [1] = {coords = vec3(-32.888, -1236.635, 29.335), heading = 179.480, gebiet = "Strawberry"},
    [2] = {coords = vec3(15.720, -1342.985, 29.287), heading = 182.327, gebiet = "Strawberry"},
    [3] = {coords = vec3(-420.991, 1197.853, 325.642), heading = 235.874, gebiet = "Observatorium"},
    [4] = {coords = vec3(-2218.759, 4234.517, 47.274), heading = 37.067, gebiet = "North Chumash"},
}

CfgVehThief.auftraggeber = {
    coords = vec3(474.975, -1310.110, 29.207),
    heading = 178.115,
    pedhash = 0x4DA6E849,
    pedmodel = 'IG_LesterCrest',
    scenario = 'WORLD_HUMAN_CLIPBOARD',
}