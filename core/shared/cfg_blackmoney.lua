return {
    ownerChange = 0.8,          -- Change black_money zo money 0.8 = 80% vom black_money.
    ownerChangetime = 60,       -- Zeitschleife alle Minuten.
    ownerChangevolume = 5000,   -- das Volumen an black_money das getauscht wird.

    Points = {
        {
            name = 'waschsalon',
            label = 'Waschsalon',
            coords = vec4(894.464, -1040.918, 35.252, 34.151),
            pedModel = GetHashKey('A_F_O_Indian_01'),
            pedCoords = vec3(890.301331, -1037.181641, 35.252876),
            pedHeading = 222.529,
            pedScenario = 'WORLD_HUMAN_AA_COFFEE',
        },
    }
}