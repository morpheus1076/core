
local Mor = require("client.cl_lib")
local cfgCore = require("shared.cfg_core")

--[[local Ped = Mor.NPC:new({
    model = 'S_M_M_Warehouse_01',
    coords = vec3(360.239, 3405.728, 36.404),
    heading = 325.447,
    scenario = 'WORLD_HUMAN_SMOKING_POT',
    targetable = false,
})]]

local obj = Mor.Object:new({
    model = 'v_med_lab_filterb',
    coords = vec3(356.832, 3399.602, 36.404),
    heading = 27.895,
    freeze = true,
    autoz = false
})

AddEventHandler('ox:playerLoaded', function(playerId, isNew)
    Wait(10000)
    local obj = Mor.Object:new({
        model = 'v_med_lab_filterb',
        coords = vec3(356.832, 3399.602, 36.404),
        heading = 27.895,
        freeze = true,
        autoz = false
    })
end)