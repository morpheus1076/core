
local Mor = require("@core.server.sv_lib")
local cfg = require('shared.cfg_core')
local allHouses = {}

-- Spielerzustand speichern
local function savePlayerState(charId, houseId, bucket, position)
    MySQL.insert.await('INSERT INTO `player_housing_state` (charId, currentHouseId, currentBucket, lastPosition) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE currentHouseId = VALUES(currentHouseId), currentBucket = VALUES(currentBucket), lastPosition = VALUES(lastPosition)',
    {charId, houseId, bucket, json.encode(position)})
end

-- Spielerzustand zurücksetzen
local function resetPlayerState(charId)
    MySQL.update.await('DELETE FROM `player_housing_state` WHERE `charId` = ?', {charId})
end

lib.callback.register('GetAllHouses', function()
    allHouses = MySQL.query.await('SELECT * FROM `housing`')
    return allHouses
end)


CreateThread(function()
    allHouses = MySQL.query.await('SELECT * FROM `housing`')
    for i=1, #allHouses do
        local stashbucket = allHouses[i].id+1000
        local stashcoords = allHouses[i].stash
        local stashId = 'house'..stashbucket
        local stash = {
            id = stashId,
            label = 'Lager',
            slots = 50,
            weight = 100000,
            owner = false
        }
        exports.ox_inventory:RegisterStash(stash.id, stash.label, stash.slots, stash.weight, stash.owner)
    end
end)

lib.callback.register('OpenDoor', function(id)
    local openDoor = MySQL.update.await('UPDATE `housing` SET `closed` = ? WHERE `id` = ?',{ 0 , id })
    if openDoor then
        return true
    else
        return false
    end
end)

lib.callback.register('CloseDoor', function(id)
    local closeDoor = MySQL.update.await('UPDATE `housing` SET `closed` = ? WHERE `id` = ?',{ 1 , id })
    if closeDoor then
        return true
    else
        return false
    end
end)

lib.callback.register('BuyHouse', function(source, id, price)
    local src = source
    local player = Ox.GetPlayer(src)
    local account = player.getAccount()
    local accountbalance = account.get('balance')
    local sellaccount = Ox.GetGroupAccount('staat')
    if accountbalance >= price then
        local buyHouse = MySQL.update.await('UPDATE `housing` SET `charId` = ? WHERE `id` = ?',{ player.charId, id })
        account.removeBalance({amount = price, message = "Immobilienkauf", true})
        sellaccount.addBalance({amount = price, message = "Immobilienverkauf : Char: "..player.charId.." ImmoId: "..id.."", true})
        return true
    else
        return false
    end
end)

lib.callback.register('SellHouse', function(source, id, sellprice)
    local src = source
    local player = Ox.GetPlayer(src)
    local account = player.getAccount()
    local accountbalance = account.get('balance')
    local sellaccount = Ox.GetGroupAccount('staat')
    local sellbalance = sellaccount.get('balance')
    if sellbalance >= sellprice then
        local sellHouse = MySQL.update.await('UPDATE `housing` SET `charId` = ? WHERE `id` = ?',{ 0 , id })
        sellaccount.removeBalance({amount = sellprice, message = "Immobilienkauf: Char: "..player.charId.." ImmoId: "..id.."", true})
        account.addBalance({amount = sellprice, message = "Immobilienverkauf", true})
        local closeDoor = MySQL.update.await('UPDATE `housing` SET `closed` = ? WHERE `id` = ?',{ 1 , id })
        return true
    else
        return false
    end
end)

RegisterNetEvent('housing:enterHouse', function(bucket, currentPosition)
    local src = source
    local player = Ox.GetPlayer(src)
    if not player then return end

    local houseId = bucket - 1000  -- Bucket-ID zurück in Haus-ID umwandeln
    SetPlayerRoutingBucket(src, bucket)

    -- Zustand speichern
    savePlayerState(player.charId, houseId, bucket, currentPosition)
    print(("Spieler %s hat Haus %d betreten (Bucket %d)"):format(player.charId, houseId, bucket))
end)

-- Beim Verlassen des Hauses aufrufen
RegisterNetEvent('housing:leaveHouse', function()
    local src = source
    local player = Ox.GetPlayer(src)
    if not player then return end

    resetPlayerState(player.charId)
    SetPlayerRoutingBucket(src, 0)
end)

-- Warte bis der Spieler vollständig geladen ist
AddEventHandler('ox:playerLoaded', function(playerId, userId, charId)
    local src = source
    local player = Ox.GetPlayerFromUserId(userId)
    -- Warte 1 Sekunde um Spielerspawn zu garantieren
    SetTimeout(3000, function()
        local state = MySQL.single.await('SELECT * FROM `player_housing_state` WHERE `charId` = ?', {charId})
        if state and state.currentHouseId then
            -- Bucket setzen
            Wait(3000)
            SetPlayerRoutingBucket(src, state.currentBucket)
            Wait(10)
            local istBucket = GetPlayerRoutingBucket(src)
            print(("Spieler %s in Bucket %d gesetzt (Haus %d)"):format(player.charId, state.currentBucket, state.currentHouseId))

            -- Position an Client senden
            local position = 0
            TriggerClientEvent('housing:restorePosition', src, position, state.currentHouseId)
        end
    end)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    -- Warte bis alle Abhängigkeiten geladen sind
    Wait(3000)
    print("Housing-System vollständig initialisiert")
end)