cfg_vehicles = {}

cfg_vehicles.saveInterval = 15 -- Saveintervall für alle Fahrzeuge in Minuten
cfg_vehicles.aktiv = true
cfg_vehicles.antishuffle = true --automatischen Sitzplatzwechsel unterbinden und anti-helmet und Vehicle Radio aus.

cfg_vehicles.impound = {
    coords = vec3(407.270, -1625.990, 29.292),
    heading = 232.048,
    pedhash = 0x9AB35F63,
    pedmodel = 'CSB_Cop',
    scenario = 'WORLD_HUMAN_AA_COFFEE',
    spawnpoints =
    {
        {coords = vec3(406.880, -1644.333, 29.292), heading = 226.221},
        {coords = vec3(411.864, -1637.558, 29.292), heading = 230.091}
    }
}