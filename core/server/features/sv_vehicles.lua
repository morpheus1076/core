
local Mor = require("server.sv_lib")
local Util = require("shared.sh_util")

--- Alle NPC Fahrzeuge verschließen und alle 10sek. aktuallisieren, wegen der neu gespawnten.
local function LockAllNpcVehicles()
    Wait(2000)
    local vehicles = GetGamePool('CVehicle')

    for _, vehicle in ipairs(vehicles) do
        if DoesEntityExist(vehicle) then
            local driver = GetPedInVehicleSeat(vehicle, -1)
            if not IsPedAPlayer(driver) and not HasVehicleBeenOwnedByPlayer(vehicle) then
                SetVehicleDoorsLocked(vehicle, 2)
            end
        end
    end
end

AddEventHandler('ox:playerLoaded', function(playerId, userId, charId)
    LockAllNpcVehicles()
    while true do
        Wait(10000)
        LockAllNpcVehicles()
    end
end)

RegisterServerEvent('VehItemRemove', function(item, amount)
    Mor.Inv:remove(source, item, amount)
end)