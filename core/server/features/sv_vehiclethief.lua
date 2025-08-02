
------------------------------------------------------------------------
local Notify = function(msg) exports['mor_core']:Notify(msg) end
local InfoLog = function(msg) exports['mor_core']:InfoLog(msg) end
local WarnLog = function(msg) exports['mor_core']:WarnLog(msg) end
------------------------------------------------------------------------
local Mor = require("server.sv_lib")

local spawnedthiefVehicle = nil
local belohnung = 0
local strafe = 0
local auftragnehmer = 0
local bliplist = {}
local model = nil

lib.callback.register('vehiclethief:SpawnThiefVehicle', function(source)
    if CfgVehThief.aktiv then
        local src = source
        for i=1, #CfgVehThief.startCoords do
            local spots = CfgVehThief.startCoords[i]
            local coords = spots.coords
            local vehicle = lib.getClosestVehicle(coords, 5, true)
            if vehicle == nil or (type(vehicle) == "table" and next(vehicle) == nil) then
            else DeleteEntity(vehicle)
            end
        end
        Wait(100)

        local randomModel = math.random(1, #CfgVehThief.models)
        local randomStart = math.random(1, #CfgVehThief.startCoords)
        model = CfgVehThief.models[randomModel]

        if model then
            local start = CfgVehThief.startCoords[randomStart]
            strafe = model.strafe

            if CheckMoneyStrafe(src) == true then

                spawnedthiefVehicle = Ox.CreateVehicle(model.model, start.coords, start.heading)
                if spawnedthiefVehicle ~= nil then
                    local player = Ox.GetPlayer(src)
                    if player ~= nil then
                        local vehnetentity = spawnedthiefVehicle.netId
                        SetVehicleDoorsLocked(spawnedthiefVehicle.entity, 1)
                        Notify("~g~Auftrag in "..start.gebiet.." , ~w~angenommen: ~y~Prüfe Deine Karte um Dein Ziel zu sehen.")
                        Wait(100)
                        auftragnehmer = player.source
                        local spawncoords = spawnedthiefVehicle.getCoords()
                        local test = lib.callback.await('vehiclethief:ZoneUnLock',source, spawncoords)
                        local blipset = lib.callback.await('vehiclethief:SetVehicleBlip', source, spawncoords, vehnetentity)
                    end

                else
                    WarnLog('Player nicht gefunden Thief sv Z53')
                end
            else
                Notify("Du hast nicht genügend Bargeld dabei. Falls Du eine Strafe zahlen musst")
            end
        else
            Notify("~r~Fehler, ~w~kein aktueller Auftrag vorhanden.")
        end
        return auftragnehmer
    end
end)

lib.callback.register('GetModelThief', function()
    local sendmodel = model
    return sendmodel
end)

function DespawnThiefVehicle(netId)
    local vehicle = Ox.GetVehicleFromNetId(netId)
    Wait(100)
    vehicle.despawn(false)
    if spawnedthiefVehicle then
        DeleteEntity(spawnedthiefVehicle.entity)
    end
end

function CheckMoneyStrafe(source)
    local src = source
    local player = Ox.GetPlayer(src)
    Wait(200)
    if player.source ~= 0 then
        local playermoney = exports.ox_inventory:GetItemCount(player.source, 'money')
        if playermoney >= strafe then
            return true
        else
            return false
        end
    else
        WarnLog('Fehler: Player nicht gefunden')
    end
end

local function GetDistanceBetweenVec3(vecA, vecB)
    return #(vecA - vecB)
end

lib.callback.register('vehiclethief:auftragsabgabe', function(source, belohnung)
    local src = source
    local player = Ox.GetPlayer(src)
    if spawnedthiefVehicle then
        local vehicle = Ox.GetVehicleFromNetId(spawnedthiefVehicle.netId)
        local vehcoords = vehicle.getCoords()
        local plycoords = player.getCoords()
        local distance = GetDistanceBetweenVec3(vehcoords, plycoords)
        if distance <= 25.0 then
            local ausz = exports.ox_inventory:AddItem(source, 'black_money', belohnung)
            spawnedthiefVehicle = nil
            belohnung = 0
            strafe = 0
            vehicle.despawn(false)
            return 'AbgabeErledigt'
        else
            Notify('~w~Fahrzeug ~r~nicht ~w~nahe genug am Auftraggeber.')
            return 'AbgabeFehler'
        end
    end
end)

lib.callback.register('vehiclethief:getauftragnehmer', function(source)
    return auftragnehmer
end)

lib.callback.register('vehiclethief:resetauftragnehmer', function(source)
    auftragnehmer = 0
    if spawnedthiefVehicle then
        local vehicle = Ox.GetVehicleFromNetId(spawnedthiefVehicle.netId)
        if vehicle then
            vehicle.despawn(false)
            Wait(500)
            spawnedthiefVehicle = nil
        end
    end
    strafe = 0
    return 'reset'
end)

lib.callback.register('vehiclethief:strafzahlung', function(source)
    local strafzahlung = exports.ox_inventory:RemoveItem(source, 'money', strafe)
    Wait(100)
    strafe = 0
    if strafzahlung then
        return 'strafe'
    end
end)

lib.callback.register('MessageToThief', function(source, phoneNumber)
    local src = source
    exports.npwd:emitMessage({
        senderNumber = 'Auftraggeber',
        targetNumber = phoneNumber,
        message = 'Bin zurück. Zum Glück ist nix passiert.  \n \nKann Dir das Fahrzeug nun Abnehmen.',
        embed = {
            type = "location",
            coords = { 474.975, -1310.110, 29.207 },
            phoneNumber = phoneNumber
        }
    })
end)

lib.callback.register('MessageToThief2', function(source, phoneNumber)
    local src = source
    exports.npwd:emitMessage({
        senderNumber = 'Auftraggeber',
        targetNumber = phoneNumber,
        message = 'Polizei überall, ich mache mich kurz vom Acker. \nMelde mich, wenn ich das Fahrzeug annehmen kann.  \nWird nicht lange dauern, hoffe ich.',
    })
end)