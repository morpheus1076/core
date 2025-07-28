
local import = require("shared.cfg_auftraggeber")
local cfgCore = require("shared.cfg_core")

local legalJobs = import.legaljobs
local abgabeCounter = {}

if cfgCore.AuftraggeberUse then
    RegisterNetEvent('auftraggeber:auftragspeichern', function(aid, atype)
        local player = Ox.GetPlayer(source)
        local plyData = player.get('playerdata')
        local charName = plyData.fullname
        local setverdienst, setname = 0, nil
        for _,k in ipairs(legalJobs) do
            if k.id == aid then
                setverdienst = k.earning
                setname = k.name
            end
        end
        local entry = MySQL.insert.await('INSERT INTO `mor_auftraggeber` (charid, id, type, verdienst, name, charname) VALUES (?,?,?,?,?,?)',{
            player.charId, aid, atype, setverdienst, setname, charName
        })
    end)

    RegisterNetEvent('auftraggeber:auftragabgeben', function(torderid)
        local player = Ox.GetPlayer(source)
        local currency = nil
        local order = MySQL.query.await('SELECT * FROM `mor_auftraggeber` WHERE `orderid`=?',{torderid})
        local charid = player.charId
        if not abgabeCounter[charid] then
            abgabeCounter[charid] = 0
        end
        if (abgabeCounter[charid] < import.maxOrders) then
            for _,k in ipairs(legalJobs) do
                if order[1].id == k.id then
                    local item = k.items.name
                    local amount = k.items.amount
                    local itemCount = exports.ox_inventory:GetItemCount(player.source, item)
                    print(itemCount, amount)
                    if itemCount >= amount then
                        if k.atype == 'legal' then
                            local account = player.getAccount()
                            local pay = account.addBalance({amount = k.earning, message = "Auftrag: "..k.title.."", true})
                            if pay.success then
                                local plyData = player.get('playerdata')
                                local charid = player.charId or 0
                                local groupaccount = Ox.GetGroupAccount(import.legalBuyer)
                                local delOrder = MySQL.query.await('DELETE FROM `mor_auftraggeber` WHERE `orderid`=? AND `charid`=?',{torderid, player.charId})
                                exports.ox_inventory:RemoveItem(player.source, item, amount)
                                exports.ox_inventory:AddItem(import.legalLager, item, amount)
                                groupaccount.removeBalance({amount = amount, message = "Ankauf Auftrag von "..plyData.fullname.."", true})
                                abgabeCounter[charid] = (abgabeCounter[charid] or 0) + 1
                                lib.print.info('Abgabecount: '..abgabeCounter[charid])
                            else
                                lib.print.warn('Fehler beim Auszahlen.')
                            end
                        else
                            currency = 'black_money'
                        end
                    else
                        TriggerClientEvent('auftraggeber:nichtgenug', player.source)
                    end
                end
            end
        else
            TriggerClientEvent('auftraggeber:maxorder', player.source)
        end
    end)

    RegisterNetEvent('auftraggeber:auftragloeschen', function(torderid)
        local player = Ox.GetPlayer(source)
        local delOrder = MySQL.query.await('DELETE FROM `mor_auftraggeber` WHERE `orderid`=? AND `charid`=?',{torderid, player.charId})
    end)

    lib.callback.register('auftraggeber:auftragabrufen', function()
        local player = Ox.GetPlayer(source)
        local allOrders = MySQL.query.await('SELECT * FROM `mor_auftraggeber` WHERE `charid`=?',{player.charId})
        return allOrders
    end)

end