
local Mor = require("server.sv_lib")

local player = nil
local playergroup = nil
local allstations = {}

AddEventHandler('ox:playerLoaded', function(playerId, isNew)
    Wait(5000)
    player = Ox.GetPlayer(playerId)
    playergroup = player.getGroup(player.getGroups())
    allstations = MySQL.query.await('SELECT * FROM mor_carwash')
end)

RegisterNetEvent('CarwashAbrechnung')
AddEventHandler('CarwashAbrechnung', function(zone)
    local src = source
    player = Ox.GetPlayer(src)
    allstations = MySQL.query.await('SELECT * FROM mor_carwash')
    for i=1, #allstations do
        if zone == allstations[i].station and allstations[i].charId ~= 0 then
            local cost = allstations[i].cost
            local owneraccount = Ox.GetCharacterAccount(allstations[i].charId)
            exports.ox_inventory:RemoveItem(player.source, 'money', cost)
            owneraccount.addBalance({amount = cost, message = "Waschanlage: Einnahme", true})
        elseif zone == allstations[i].station and allstations[i].charId == 0 then
            local owneraccount = Ox.GetGroupAccount('staat')
            local cost = allstations[i].cost
            exports.ox_inventory:RemoveItem(player.source, 'money', cost)
            owneraccount.addBalance({amount = cost, message = "Waschanlage: Einnahme", true})
        end
    end
end)



lib.callback.register('GetCarwashOwner', function(source, zone)
    local src = source
    allstations = MySQL.query.await('SELECT * FROM mor_carwash')
    for i=1, #allstations do
        if zone == allstations[i].station then
            local owner = allstations[i].charId
            return owner
        end
    end
end)

lib.callback.register('CarwashKaufen', function(source, zone, price, label)
    local src = source
    local player = Ox.GetPlayer(src)
    local account = Ox.GetCharacterAccount(player.charId)
    local sellaccount = Ox.GetGroupAccount('staat')
    local accountbalance = account.get('balance')
    if accountbalance >= price then
        account.removeBalance({amount = price, message = "Waschanlage: "..label.." gekauft", true})
        sellaccount.addBalance({amount = price, message = "Waschanlage: "..label.." verkauft", true})
        local station = MySQL.update.await('Update mor_carwash SET charId = ? WHERE station = ?', {player.charId, zone})
        return true
    else
        return false
    end
end)

lib.callback.register('CarwashVerkaufen', function(source, zone, sellprice, label)
    local src = source
    local player = Ox.GetPlayer(src)
    local sellaccount = Ox.GetCharacterAccount(player.charId)
    local buyaccount = Ox.GetGroupAccount('staat')
    local accountbalance = buyaccount.get('balance')
    if accountbalance >= sellprice then
        buyaccount.removeBalance({amount = sellprice, message = "Waschanlage: "..label.." gekauft", true})
        sellaccount.addBalance({amount = sellprice, message = "Waschanlage: "..label.." verkauft", true})
        local station = MySQL.update.await('Update mor_carwash SET charId = ? WHERE station = ?', {0, zone})
        return true
    else
        return false
    end
end)

function Datenbankabgleich()
    if cfg_feat.carwash == true then
        local cfgStationen = Cfg_Carwash.Stations
        local dbStations = MySQL.query.await('SELECT station FROM mor_carwash')
        for i=1, #cfgStationen do
            local station = cfgStationen[i].id
            for k=1, #dbStations do
                if dbStations[k].station == station then
                    Wait(5000)
                    lib.print.info('Waschstraßen: Config und DB sind abgeglichen.')
                else
                    Wait(5000)
                    lib.print.info('StationId: '..station..', ist NICHT in DB vorhanden.')
                    local id = MySQL.insert.await('INSERT INTO `mor_carwash` (station, charId, cost, owneraccount) VALUES (?, ?, ?, ?)', {station, 0, 30, 0})
                    Wait(1000)
                    lib.print.info('StationId: '..station..', wurde der DB hinzugefügt. ID: '..id..'')
                end
            end
        end
    end
end

Datenbankabgleich()