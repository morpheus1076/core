
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


--- Mileage, OilLevel .... Wheels/Tyres???
local vehicleMileage = {}

RegisterNetEvent("mileage:update")
AddEventHandler("mileage:update", function(plate, distance)
    if not plate then return end
    local getMileage = MySQL.query.await('SELECT mileage FROM `vehicles` WHERE `plate` = ?', {plate})
    if getMileage == nil or (type(getMileage) == "table" and next(getMileage) == nil) then return end
    if not vehicleMileage[plate] then
        vehicleMileage[plate] = 0
    end
    vehicleMileage[plate] = getMileage[1].mileage + distance
    MySQL.update('UPDATE vehicles SET mileage = @mileage WHERE plate = @plate', {['@mileage'] = vehicleMileage[plate], ['@plate'] = plate})
end)

RegisterNetEvent("mileage:oillevelupdate")
AddEventHandler("mileage:oillevelupdate", function(plate, oilLevel)
    if not plate then return end
    MySQL.update('UPDATE vehicles SET oillevel = @oillevel WHERE plate = @plate', {['@oillevel'] = oilLevel, ['@plate'] = plate})
end)

lib.callback.register('GetVehicleOilLevel', function(source, plate)
    local src = source
    local getOilLevel = MySQL.query.await('SELECT oillevel FROM `vehicles` WHERE `plate` = ?', {plate})
    if getOilLevel == nil or (type(getOilLevel) == "table" and next(getOilLevel) == nil) then return end
    if getOilLevel then
        return getOilLevel[1].oillevel
    end
end)

lib.callback.register("mileage:get", function(source, plate)
    return vehicleMileage[plate] or 0
end)