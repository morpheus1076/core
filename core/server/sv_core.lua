

local Mor = require("server.sv_lib")
local cfg = require("shared.cfg_core")

lib.callback.register('AceCheck', function()
    local playerace = IsPlayerAceAllowed(source, "admin")
    return playerace
end)

CreateThread(function()
    EnableEnhancedHostSupport(true)
end)

local function SetGroup(userId)
    local player = Ox.GetPlayerFromUserId(userId)
    player.setGroup('arbeitslos', 1)
    Wait(50)
    player.setActiveGroup('arbeitslos', false)
end

AddEventHandler('ox:spawnedVehicle', function(entityId, id)
    if cfg.VehSpawnInfo then
        local message = "Fahrzeug gespawned: Entity:"..entityId.." Datenbank ID: "..id..""
        Mor.Log:add('vehiclespawn', message)
    end
end)

AddEventHandler('ox:playerLoaded', function(playerId, userId, charId)
    local player = Ox.GetPlayerFromUserId(userId)
    local message = "Spieler: "..player.username.." ist jetzt in der Stadt aktiv."
    local group = player.getGroup(player.getGroups())
    local getFullname = MySQL.query.await('SELECT `fullName` FROM `characters` WHERE `charId`= ?',{player.charId})
    player.set('fullname', getFullname[1].fullName, true)
    if group == nil then SetGroup(userId) end
    Mor.Log:add('join', message, charId)
    CreateThread(function()
        while true do
            local allPlayers = Ox.GetPlayers()
            for i=1, #allPlayers do
                local player = Ox.GetPlayer(allPlayers[i].source)
                local statuses = player.getStatuses()
                if statuses == nil or (type(statuses) == "table" and next(statuses) == nil) then return end
                local getHealth = GetEntityHealth(player.ped)
                if (statuses.hunger >= 95) or (statuses.thirst >= 95) then
                    local setHealth = getHealth - cfg.HealthReduce
                    TriggerClientEvent('SettingNewHealth', player.source)
                end
            end
            Wait(cfg.StatusesCheckTime)
        end
    end)
end)

lib.callback.register('MessageClientStart', function(source, data)
    local src = source
    if data == true then
        print('[Client] Alle Steuerungen gestartet.')
    elseif data == false then
        print('[Client] Fehler beim Laden der Steuerungen.')
    else
        print('[Client] Fehler beim Übergabewert. data cb [MessageClientStart]')
    end
end)

AddEventHandler('ox:setActiveGroup', function(playerId, groupName)
    local message = "Spieler: "..playerId.." Gruppe: "..groupName.." aktiv gesetzt."
    Mor.Log:add('groupactiv', message, playerId)
end)

AddEventHandler('ox:playerLogout', function(playerId, userId, charId)
    local message = "Spieler: CharId: "..charId.." hat sich ausgeloggt. "
    Mor.Log:add('quit', message, charId)
end)

AddEventHandler('ox:spawnedVehicle', function(entityId, id)
    local message = "Fahrzeug spawned: Entity: "..entityId.." Id: "..id..""
    Mor.Log:add('vehspawn', message)
end)

AddEventHandler('ox:despawnVehicle', function(entityId, id)
    local message = "Fahrzeug despawned: Entity: "..entityId.." Id: "..id..""
    Mor.Log:add('vehdespawn', message)
end)
