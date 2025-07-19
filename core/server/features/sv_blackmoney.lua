
local Mor = require("server.sv_lib")
local Points = require 'shared.cfg_blackmoney'
local cfg = require 'shared.cfg_core'
local Owner = cfg.BlackmoneyOwner
local OwnerStash = 'gwa_waschtresor'

lib.callback.register('GetMoneyCount', function()
    local count = exports.ox_inventory:GetItemCount(OwnerStash, 'money')
    return count
end)

lib.callback.register('GetCount', function()
    local count = exports.ox_inventory:GetItemCount(source, 'black_money')
    return count
end)

lib.callback.register('mor_blackmoney:einzahlung', function(source, group, amount)
    local player = Ox.GetPlayer(source)
    if not player then return false end
    Wait(50)
    local aktGroup = MySQL.query.await('SELECT name FROM character_groups WHERE `charId` = ? AND `isActive` = ?;',{player.charId, true})
    local now = os.date('%Y-%m-%d %H:%M:%S')
    Mor.Inv:remove(player.source,'black_money', amount)
    Mor.Inv:add(OwnerStash, 'black_money', amount)
    local id = MySQL.insert.await('INSERT INTO `mor_blackmoney` (groupname, charid, amount, art, ausgezahlt, timestamp) VALUES (?, ?, ?, ?, ?, ?)',{aktGroup[1].name, player.charId, amount, 'einzahlung', 0, now})
    if id then return true
    else return false
    end
end)

lib.callback.register('mor_blackmoney:auszahlung', function(source, group)
    local player = Ox.GetPlayer(source)
    local amounts = {}
    if not player then return false end

    local getamount = MySQL.query.await('SELECT * FROM mor_blackmoney WHERE TIMESTAMPDIFF(MINUTE, timestamp, NOW()) >= 5;')
    for _,v in pairs (getamount) do
        if v.amount and v.ausgezahlt == 0 then
            table.insert(amounts, {id = v.id, amount = v.amount})
        end
    end
    return amounts
end)

lib.callback.register('mor_blackmoney:abschluss', function(source, gesAmount, ausgezahltIds)
    local player = Ox.GetPlayer(source)
    local auszahlung = math.floor(gesAmount * cfg.BlackmoneyChange)
    Mor.Inv:add(player.source, 'money', auszahlung)
    Mor.Inv:remove(OwnerStash, 'money', auszahlung)
    for i=1, #ausgezahltIds do
        auszupdates = MySQL.update.await('UPDATE mor_blackmoney SET ausgezahlt = ? WHERE id = ?', {'1', ausgezahltIds[i].id})
    end
    if auszupdates then
        return true
    else
        return false
    end
end)

CreateThread(function()
    if cfg.BlackmoneyAktiv then
        while true do
            local bmCount = exports.ox_inventory:GetItemCount(OwnerStash, 'black_money')
            if bmCount >= (Points.ownerChangevolume + 500) then
                local changeAmount = Points.ownerChangevolume * Points.ownerChange
                Mor.Inv:remove(OwnerStash, 'black_money', Points.ownerChangevolume)
                Mor.Inv:add(OwnerStash, 'money', changeAmount)
            end
        Wait(Points.ownerChangetime*60000)
        end
    end
end)