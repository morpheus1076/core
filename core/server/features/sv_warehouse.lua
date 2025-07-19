
local maxStufe = 14

lib.callback.register('CheckWH', function(source)
    local player = Ox.GetPlayer(source)
    local owner = MySQL.query.await('SELECT * FROM `mor_chardata` WHERE `charId` = ?', {player.charId})
    if owner == nil or (type(owner) == "table" and next(owner) == nil) then
        return 0
    else
        return owner
    end
end)

RegisterServerEvent('WHInventory')
AddEventHandler('WHInventory', function()
    local src = source
    local player = Ox.GetPlayer(src)
    local stufe = 14
    for i = 1, stufe do
        local cfgPlz = WHConfig.Lager[i]
        if cfgPlz then
            local charId = player.charId
            exports.ox_inventory:RegisterStash(cfgPlz.id, cfgPlz.label, cfgPlz.slots, cfgPlz.maxWeight, charId, false, cfgPlz.coords ) --
        end
    end
end)

lib.callback.register('Bankeinzug', function(source)
    local player = Ox.GetPlayer(source)
    local account = player.getAccount()
    local accountbalance = account.get('balance')
    local sellaccount = Ox.GetGroupAccount('staat')
    local price = 200000
    local owner = MySQL.query.await('SELECT * FROM `mor_chardata` WHERE `charId` = ?', {player.charId})
    if accountbalance >= price then
        if owner == nil or (type(owner) == "table" and next(owner) == nil) then
            local id = MySQL.insert.await('INSERT INTO `mor_chardata` (charId, whstufe, whowner) VALUES (?, ?, ?)', {player.charId, 1, 1})
            account.removeBalance({amount = price, message = "Kauf Lagerraum", true})
            sellaccount.addBalance({amount = price, message = "Verkauf Lagerraum : "..player.username.."", true})
            return 'kauf'
        elseif owner[1].whowner == 0 then
            local id2 = MySQL.update('UPDATE mor_chardata SET whowner = @whowner WHERE charId = @charId', {['@whowner'] = 1, ['@charId'] = player.charId })
            account.removeBalance({amount = price, message = "Kauf Lagerraum", true})
            sellaccount.addBalance({amount = price, message = "Verkauf Lagerraum : "..player.username.."", true})
            return 'kauf'
        else
            return 'fehler'
        end
    end
end)

lib.callback.register('Barzahlung', function(source)
    local player = Ox.GetPlayer(source)
    local account = player.getAccount()
    local accountbalance = account.get('balance')
    local sellaccount = Ox.GetGroupAccount('staat')
    local price = 200000
    local owner = MySQL.query.await('SELECT * FROM `mor_chardata` WHERE `charId` = ?', {player.charId})
    if owner == nil or (type(owner) == "table" and next(owner) == nil) then
        exports.ox_inventory:RemoveItem(player.source, 'money', price)
        sellaccount.addBalance({amount = price, message = "BAR-Verkauf Lagerraum : "..player.username.."", true})
        local id = MySQL.insert.await('INSERT INTO `mor_chardata` (charId, whstufe, whowner) VALUES (?, ?, ?)', {player.charId, 1, 1})
        return 'kauf'
    else
        exports.ox_inventory:RemoveItem(player.source, 'money', price)
        sellaccount.addBalance({amount = price, message = "BAR-Verkauf Lagerraum : "..player.username.."", true})
        local id2 = MySQL.update('UPDATE mor_chardata SET whowner = @whowner WHERE charId = @charId', {['@whowner'] = 1, ['@charId'] = player.charId })
        return 'kauf'
    end
end)

lib.callback.register('UpdateWH', function(source)
    local player = Ox.GetPlayer(source)
    local account = player.getAccount()
    local accountbalance = account.get('balance')
    local sellaccount = Ox.GetGroupAccount('staat')
    local price = 20000
    local owner = MySQL.query.await('SELECT * FROM `mor_chardata` WHERE `charId` = ?', {player.charId})
    if owner == nil or (type(owner) == "table" and next(owner) == nil) then
        return 'fehler'
    else
        if owner[1].whstufe <= maxStufe then
            if accountbalance >= price then
                local oldstufe = owner[1].whstufe
                local newstufe = oldstufe + 1
                account.removeBalance({amount = price, message = "Lagerraum Update", true})
                sellaccount.addBalance({amount = price, message = "Lagerraum Update : "..player.username.."", true})
                local idstufe = MySQL.update('UPDATE mor_chardata SET whstufe = @whstufe WHERE charId = @charId', {['@whstufe'] = newstufe, ['@charId'] = player.charId })
                return newstufe
            else
                return 'fehler'
            end
        end
    end
end)

lib.callback.register('DowngradeWH', function(source)
    local player = Ox.GetPlayer(source)
    local account = player.getAccount()
    local accountbalance = account.get('balance')
    local sellaccount = Ox.GetGroupAccount('staat')
    local price = 10000
    local owner = MySQL.query.await('SELECT * FROM `mor_chardata` WHERE `charId` = ?', {player.charId})
    if owner == nil or (type(owner) == "table" and next(owner) == nil) and owner[1].whstufe == 1 then
        return 'fehler'
    else
        if owner[1].whstufe > 1 then
            local oldstufe = owner[1].whstufe
            local newstufe = oldstufe - 1
            account.addBalance({amount = price, message = "Lagerraum Stufe verkauft : ", true})
            sellaccount.removeBalance({amount = price, message = "Lagerraum Downgrade : "..player.username.."", true})
            local idstufe = MySQL.update('UPDATE mor_chardata SET whstufe = @whstufe WHERE charId = @charId', {['@whstufe'] = newstufe, ['@charId'] = player.charId })
            return newstufe
        else
            return 'fehler'
        end
    end
end)

lib.callback.register('VerkaufWH', function(source)
    local player = Ox.GetPlayer(source)
    local account = player.getAccount()
    local accountbalance = account.get('balance')
    local sellaccount = Ox.GetGroupAccount('staat')
    local price = 150000
    local owner = MySQL.query.await('SELECT * FROM `mor_chardata` WHERE `charId` = ?', {player.charId})
    if owner == nil or (type(owner) == "table" and next(owner) == nil) and owner[1].whstufe == 1 then
        return 'fehler'
    else
        if owner[1].whstufe >= 1 and owner[1].whowner == 1 then
            account.addBalance({amount = price, message = "Lagerraum verkauft : ", true})
            sellaccount.removeBalance({amount = price, message = "Lagerraum Downgrade : "..player.username.."", true})
            local idstufe = MySQL.update('UPDATE mor_chardata SET whstufe = @whstufe WHERE charId = @charId', {['@whstufe'] = 1, ['@charId'] = player.charId })
            local idstufe2 = MySQL.update('UPDATE mor_chardata SET whowner = @whowner WHERE charId = @charId', {['@whowner'] = 0, ['@charId'] = player.charId })
            return 'verkauft'
        else
            return 'fehler'
        end
    end
end)

lib.callback.register('ClearInvComplete', function()
    local player = Ox.GetPlayer(source)
    local invs = WHConfig.Lager
    local owner = MySQL.query.await('SELECT * FROM `mor_chardata` WHERE `charId` = ?', {player.charId})
    for i = 1, #invs do
        local cfgPlz = WHConfig.Lager[i]
        local charId = player.charId
        --exports.ox_inventory:ClearInventory({cfgPlz.id, charId})
        local clean = MySQL.update('UPDATE ox_inventory SET data = ? WHERE name = ? AND owner = ?', {NULL, cfgPlz.id, charId})
        --print('clean inventory')
    end
end)