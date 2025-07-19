

lib.callback.register('mor_sellshop:verkauf', function(source, item, itemcount, currency, amount, buyer, lager, shoplabel)
    local player = Ox.GetPlayer(source)
    local account = player.getAccount()
    local groupaccount = Ox.GetGroupAccount(buyer)
    local label = shoplabel
    exports.ox_inventory:RemoveItem(player.source, item, itemcount)
    Wait(300)
    exports.ox_inventory:AddItem(lager, item, itemcount)
    Wait(300)
    account.addBalance({amount = amount, message = "Verkauf: "..item.."", true})
    Wait(300)
    groupaccount.removeBalance({amount = amount, message = "Ankauf von "..player.username.."", true})
    Wait(300)
end)


lib.callback.register('InvItemCount', function(source, inv, itemName)
    Wait(20)
    local src = source
    local itemCount = exports.ox_inventory:GetItemCount('trunk'..inv, itemName)
    --InfoLog('Item: '..itemName..'--- Count: '..itemCount..'')
    return itemCount
end)

lib.callback.register('mor_sellshop:verkaufVehicle', function(source, item, itemcount, currency, amount, buyer, lager, plate, shoplabel)
    local player = Ox.GetPlayer(source)
    local account = player.getAccount()
    local buyeraccount = Ox.GetGroupAccount(buyer)
    local label = shoplabel
    exports.ox_inventory:RemoveItem('trunk'..plate, item, itemcount)
    Wait(300)
    exports.ox_inventory:AddItem(lager, item, itemcount)
    Wait(300)
    account.addBalance({amount = amount, message = "Verkauf: "..item.."", true})
    Wait(300)
    buyeraccount.removeBalance({amount = amount, message = "Ankauf von "..player.username.."", true})
    Wait(300)
end)
