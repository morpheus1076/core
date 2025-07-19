
lib.callback.register('CheckStorageOwner', function(source, storeid)
    local player = Ox.GetPlayer(source)
    local owner = MySQL.query.await('SELECT `charid` FROM `mor_storage` WHERE `id` = ?', {storeid})

    if owner[1].charid == player.charId then
        return true
    else
        return false
    end
end)

RegisterServerEvent('OpenStorage')
AddEventHandler('OpenStorage', function(storeid)
    print('In OpenStorage Serverside')
    local player = Ox.GetPlayer(source)
    local owner = MySQL.query.await('SELECT `charid` FROM `mor_storage` WHERE `id` = ?', {storeid})
    local storagename = MySQL.query.await('SELECT `name` FROM `mor_storage` WHERE `id` = ?', {storeid})

    if owner[1].charid == player.charId then
        TriggerClientEvent('OpenStorage', source, storeid, storagename)
    end
end)

lib.callback.register('BuyStorage', function(source, storeid, storagepreis)
    print(storagepreis)
    local player = Ox.GetPlayer(source)
    local charid = player.charId
    local money = exports.ox_inventory:GetItemCount(player.source , 'money')
    print(money)

    if money >= storagepreis then
        exports.ox_inventory:RemoveItem(player.source, 'money', storagepreis)
        local updateowner = MySQL.update.await('UPDATE mor_storage SET charid = ? WHERE `id` = ?', {charid , storeid})
        if updateowner then
            return true
        else
            return false
        end
    else
        TriggerClientEvent('Notify', source, '~r~Nicht genügend Geld dabei.')
    end
end)

lib.callback.register('SellStorage', function(source, storeid, price)
    local player = Ox.GetPlayer(source)
    local charid = 0
    exports.ox_inventory:AddItem(player.source, 'money', price)
    local updateowner = MySQL.update.await('UPDATE mor_storage SET charid = ? WHERE `id` = ?', {charid , storeid})
    if updateowner then
        return true
    else
        return false
    end
end)