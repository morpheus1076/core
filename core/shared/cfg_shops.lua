
return {
    liquor = {
		name = 'Rob´s Schnaps Laden',
        type = 'liquor',
        lager = 'liquor_lager_01',
        account = 'staat',
		blip = {
			id = 59, colour = 1, scale = 0.5, hidden = true
		},
        inventory = {
			{ name = 'bier', price = 12 },
			{ name = 'cola', price = 15 },
			{ name = 'sprunk', price = 14 },
		},
		targets = {
			{ ped = 'mp_m_shopkeep_01', scenario = 'WORLD_HUMAN_DRINKING', loc = vec3(-1486.7439, -377.5307, 39.1634), heading = 131.8548},
			{ ped = 'S_F_Y_Shop_LOW', scenario = 'WORLD_HUMAN_AA_SMOKE', loc = vec3(1134.3135, -983.2003, 44.4158), heading = 275.9501},
			{ ped = 'S_F_Y_Shop_MID', scenario = 'WORLD_HUMAN_DRINKING', loc = vec3(-1221.4283, -907.9989, 11.3263), heading = 33.5436},
			{ ped = 'mp_m_shopkeep_01', scenario = 'WORLD_HUMAN_CLIPBOARD', loc = vec3(-2966.3926, 391.5766, 14.0433), heading = 85.4508},
			{ ped = 'S_F_Y_Shop_LOW', scenario = 'WORLD_HUMAN_CLIPBOARD', loc = vec3(1166.8092, 2710.7844, 37.1577), heading = 181.9506},
			{ ped = 'mp_m_shopkeep_01', scenario = 'WORLD_HUMAN_DRINKING', loc = vec3(1392.4359, 3606.2634, 33.9809), heading = 197.8445},
			{ ped = 'S_M_Y_Shop_MASK', scenario = 'WORLD_HUMAN_SMOKE', loc = vec3(4466.2109, -4463.9351, 3.2490), heading = 201.4549},
		},
	},
    twenty = {
		name = '24/7',
        type = 'twenty',
        lager = 'twenty_lager_01',
        account = 'staat',
		blip = {
			id = 59, colour = 69, scale = 0.5, hidden = true,
		},
		inventory = {
			{ name = 'wasser', price = 9 },
			{ name = 'sprunk', price = 12 },
			{ name = 'cola', price = 13 },
			{ name = 'brot', price = 6 },
			{ name = 'sandwich', price = 9 },
			{ name = 'blaettchen', price = 7 },
		},
		targets = {
			{ ped = 'mp_m_shopkeep_01', scenario = 'WORLD_HUMAN_AA_SMOKE', loc = vec3(378.766, 328.890, 102.567), heading = 159.668},
			{ ped = 'S_F_Y_Shop_LOW', scenario = 'WORLD_HUMAN_AA_COFFEE', loc = vec3(29.525, -1343.552, 28.489), heading = 172.9123},
			{ ped = 'mp_m_shopkeep_01', scenario = 'WORLD_HUMAN_AA_COFFEE', loc = vec3(-3044.129, 588.557, 6.909), heading = 285.588},
			{ ped = 'S_F_Y_Shop_MID', scenario = 'WORLD_HUMAN_STAND_MOBILE', loc = vec3(-3245.546, 1005.773, 12.831), heading = 264.827},
			{ ped = 'S_F_Y_Shop_LOW', scenario = 'WORLD_HUMAN_CLIPBOARD', loc = vec3(1734.491, 6416.077, 34.037), heading = 149.496},
			{ ped = 'mp_m_shopkeep_01', scenario = 'WORLD_HUMAN_SMOKE', loc = vec3(1963.041, 3745.995, 32.344), heading = 205.228},
			{ ped = 'S_F_Y_Shop_MID', scenario = 'WORLD_HUMAN_AA_COFFEE', loc = vec3(544.105, 2666.991, 41.157), heading = 8.550},
			{ ped = 'mp_m_shopkeep_01', scenario = 'WORLD_HUMAN_STAND_MOBILE', loc = vec3(2677.166, 3286.065, 55.241), heading = 241.922},
			{ ped = 'S_F_Y_Shop_LOW', scenario = 'WORLD_HUMAN_CLIPBOARD', loc = vec3(2553.693, 386.332, 108.623), heading = 259.845},
			{ ped = 'mp_m_shopkeep_01', scenario = 'WORLD_HUMAN_AA_COFFEE', loc = vec3(159.9670, 6641.0176, 30.6985), heading = 225.7307},
			{ ped = 'S_F_Y_Shop_LOW', scenario = 'WORLD_HUMAN_AA_COFFEE', loc = vec3(2005.173, 3784.776, 32.201), heading = 113.284},
			{ ped = 'mp_m_shopkeep_01', scenario = 'WORLD_HUMAN_STAND_MOBILE', loc = vec3(191.782, -23.059, 68.920), heading = 249.125},
		}
	},
}