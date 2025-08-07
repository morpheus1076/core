
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
    local group = player.getGroup(player.getGroups())

    local getFullname = MySQL.query.await('SELECT `fullName`,`firstname`, `lastname`, `dateOfBirth`, `gender` FROM `characters` WHERE `charId`= ?',{player.charId})
    local getAktGroup = MySQL.query.await('SELECT `name`, `grade` FROM `character_groups` WHERE `charId` = ? AND `isActive` = ?;',{player.charId, true})
    local groupLabel = MySQL.query.await('SELECT `label` FROM `ox_groups` WHERE `name`= ?',{getAktGroup[1].name})
    local getgradelabel = MySQL.query.await('SELECT `label` FROM `ox_group_grades` WHERE `group` = ? AND `grade` = ?;',{getAktGroup[1].name, getAktGroup[1].grade})
    local timeInSeconds = getFullname[1].dateOfBirth / 1000
    local charBirth = os.date("%d.%m.%Y", timeInSeconds)
    local setidcardid = (''..(userId+1000)..' '..(charId+1000)..'')
    local playerData = {
        firstname = getFullname[1].firstname,
        lastname = getFullname[1].lastname,
        fullname = getFullname[1].fullName,
        group = getAktGroup[1].name,
        grade = getAktGroup[1].grade,
        grouplabel = groupLabel[1].label,
        gradelabel = getgradelabel[1].label,
        birth = charBirth,
        idcardid = setidcardid,
        gender = getFullname[1].gender,
    }
    player.set('playerdata', playerData, true)
    if group == nil then SetGroup(userId) end
    local plyData = player.get('playerdata')
    local message = "Spieler: "..plyData.fullname.." ist jetzt in der Stadt aktiv."
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
    lib.print.info(playerId, groupName)
    local player = Ox.GetPlayer(playerId)

    local getFullname = MySQL.query.await('SELECT `fullName`,`firstname`, `lastname`, `dateOfBirth`, `gender` FROM `characters` WHERE `charId`= ?',{player.charId})
    Wait(500)
    local getAktGroup = MySQL.query.await('SELECT `name`, `grade` FROM `character_groups` WHERE `charId` = ? AND `isActive` = ?;',{player.charId, true})
    Wait(500)
    local groupLabel = MySQL.query.await('SELECT `label` FROM `ox_groups` WHERE `name`= ?',{getAktGroup[1].name})
    Wait(500)
    local getgradelabel = MySQL.query.await('SELECT `label` FROM `ox_group_grades` WHERE `group` = ? AND `grade` = ?;',{getAktGroup[1].name, getAktGroup[1].grade})
    Wait(500)
    local timeInSeconds = getFullname[1].dateOfBirth / 1000
    local charBirth = os.date("%d.%m.%Y", timeInSeconds)
    local setidcardid = (''..(player.userId+1000)..' '..(player.charId+1000)..'')
    local playerData = {
        firstname = getFullname[1].firstname,
        lastname = getFullname[1].lastname,
        fullname = getFullname[1].fullName,
        group = getAktGroup[1].name,
        grade = getAktGroup[1].grade,
        grouplabel = groupLabel[1].label,
        gradelabel = getgradelabel[1].label,
        birth = charBirth,
        idcardid = setidcardid,
        gender = getFullname[1].gender,
    }
    player.set('playerdata', playerData, true)
    Wait(5000)
    local testData = player.get('playerdata')
    lib.print.info(testData)
end)

AddEventHandler('ox:playerLogout', function(playerId, userId, charId)
    local message = "Spieler: CharId: "..charId.." hat sich ausgeloggt. "
    Mor.Log:add('quit', message, charId)
end)

AddEventHandler('ox:spawnedVehicle', function(entityId, id)
    if entityId and id then
        local message = "Fahrzeug spawned: Entity: "..entityId.." Id: "..id..""
        Mor.Log:add('vehspawn', message)
    end
end)

AddEventHandler('ox:despawnVehicle', function(entityId, id)
    if entityId and id then
        local message = "Fahrzeug despawned: Entity: "..entityId.." Id: "..id..""
        Mor.Log:add('vehdespawn', message)
    end
end)
