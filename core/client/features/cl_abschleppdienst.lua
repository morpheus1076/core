
local config = require("shared.cfg_abschlepphof")
local Mor = require("client.cl_lib")

local abschlappNpc = Mor.NPC:new({
    model = config.npcPed,
    coords = vec3(config.npcCoords.x, config.npcCoords.y, config.npcCoords.z),
    heading = config.npcCoords.w,
    scenario = config.npcScenario,
    targetable = true,
    targetoptions = {
        label = 'Fahrzeug einparken',
        name = 'lscauspark',
        groups = 'lsc',
        onSelect = function()
            local coords = vec3(config.npcCoords.x,config.npcCoords.y,config.npcCoords.z)
            local getVehicles = lib.getClosestVehicle(coords, 10, true)
            if not getVehicles then return end
            AbsEinparken(getVehicles)
        end
    },
})
local abschleppblip = Mor.Blip:new({
    coords = vec3(config.npcCoords.x, config.npcCoords.y, config.npcCoords.z),
    sprite = 68,
    color = 17,
    scale = 0.5,
    hidden = false,
    name = 'Abschlepphof',
})

local abstellzone = lib.zones.poly({
    points = config.einparkzone,
    thickness = 3,
    debug = config.zonedebug,
})

function AbsEinparken(vehicle)
    if vehicle == nil or (type(vehicle) == "table" and next(vehicle) == nil) then
        return
    else
        local getCoords = GetEntityCoords(vehicle)
        local netVehicle = NetworkGetNetworkIdFromEntity(vehicle)
        if abstellzone:contains(getCoords) then
            local IsVehicleInside = lib.callback.await('AbschleppEinparken', source, netVehicle)
            if IsVehicleInside then
                Mor.Notify('Fahrzeug ~g~eingeparkt')
            else
                Mor.Notify('~w~Fahrzeug ~r~nicht ~w~zugelassen')
            end
        end
    end
end
