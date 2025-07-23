local Mor = require("server.sv_lib")
local jobs = require 'shared.cfg_jobs'
local tacoCount, sodaCount, burritoCount = 0,0,0

local function SetTacoInv()
    for _,v in pairs(jobs) do
        if v.id == 'thetacofarmer' then
            local lagerInv = exports.ox_inventory:GetInventoryItems(v.lagerid)
            if lagerInv == nil then return end
            local items = v.sellitems
            for i=1, #items do
                for k=1, #lagerInv do
                    if items[i] == lagerInv[k].name and lagerInv[k].count > 0 then
                        if items[i] == 'taco' then
                            tacoCount = lagerInv[k].count
                        end
                        if items[i] == 'burrito' then
                            burritoCount = lagerInv[k].count
                        end
                        if items[i] == 'sodajari' then
                            sodaCount = lagerInv[k].count
                        end
                        exports.ox_inventory:RegisterShop('thetacofarmer', {
                            name = 'The Faco Farmer',
                            inventory = {
                                { name = 'taco', price = 18, count = tacoCount },
                                { name = 'sodajari', price = 12, count = sodaCount },
                                { name = 'burrito', price = 16, count = burritoCount },
                            },
                            locations = {
                                vec3(8.223, -1602.971, 29.391),
                            },
                        })
                    end
                end
            end
        end
    end
    Wait(200)
    return true
end

RegisterNetEvent('TacoStart')
AddEventHandler('TacoStart', function()
    SetTacoInv()
end)

local hookId = exports.ox_inventory:registerHook('buyItem', function(payload)
    --print(json.encode(payload, { indent = true, sort_keys = true }))
    Mor.Inv:remove('ttf_lager', payload.itemName, payload.count)
    local moneyPais = payload.count * payload.price
    local groupAcc = Ox.GetGroupAccount('ttf')
    groupAcc.addBalance({amount = moneyPais, message = "Verkauf Geschäft", true})
    return true
end, {
    print = false,
    itemFilter = {
        taco = true,
        sodajari = true,
        burrito = true
	  },
})

lib.callback.register('ttfEinzahlung', function(source, amount)
    local player = Ox.GetPlayer(source)
    local groupAcc = Ox.GetGroupAccount('ttf')
    local count = amount[1]
    Mor.Inv:remove(source, 'money', count)
    groupAcc.addBalance({amount = amount, message = "Einzahlung durch "..player.username.." im Geschäft.", true})
    return true
end)

AddEventHandler('ox:playerLoaded', function(playerId, isNew)
    TriggerClientEvent('TacoStartServer', source)
end)