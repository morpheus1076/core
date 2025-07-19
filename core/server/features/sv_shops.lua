
local Mor = require("server.sv_lib")
local Wirt = require("shared.cfg_wirtschaftssystem")
local Shops = require("shared.cfg_shops")

RegisterNetEvent('CreateShops', function(type)
    local inventar = {}
    local name = ''
    for _,k in pairs(Shops) do
        if k.type == type then
            local shopItems = k.inventory
            name = k.name
            for _,v in pairs(shopItems) do
                local bestand = exports.ox_inventory:GetItemCount(k.lager, v.name)
                if bestand >=1 then
                    table.insert(inventar,{name = v.name, price = v.price, lager = k.lager, account = k.account, count = bestand})
                end
            end
            Wait(50)
        end
    end
    Wait(50)
    exports.ox_inventory:RegisterShop(type, {
        name = name,
        inventory = inventar
    })
end)

local hookId = exports.ox_inventory:registerHook('buyItem', function(payload)
    --print(json.encode(payload, { indent = true, sort_keys = true }))
    for _,k in pairs(Shops) do
        if k.type == payload.shopType then
            local groupAcc = Ox.GetGroupAccount(k.account)
            local amount = payload.count * payload.price
            Mor.Inv:remove(k.lager, payload.itemName, payload.count)
            groupAcc.addBalance({amount = amount, message = "Verkauf im Geschäft: "..k.name..". Produkt: "..payload.itemName..". Menge:"..payload.count..".", true})
        end
    end
    return true
end, {
    print = false,
    itemFilter = {
        sprunk = true,
        bier = true,
        cola = true,
        sandwich = true,
        brot = true,
        blaettchen = true,
        wasser = true,
	  },
})

AddEventHandler('ox:playerLoaded', function(playerId, userId, charId)
    Wait(2000)
    TriggerClientEvent('ClCreateShops', playerId)
end)