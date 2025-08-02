
local Mor = require("client.cl_lib")
local Con = require("shared.cfg_secretselling")


local function generateOptionsMenu()

    local inpMenuOptions = {}

    for _,a in pairs (Con) do
        local shop = a.shoplabel
        local items = a.ankauf
        for _, item in pairs (items) do
            local count = exports.ox_inventory:Search('count', item.item)
            if not count then count = 0 end
            table.insert(inpMenuOptions, {type = 'number', label = item.label, description = 'Preis: $'..item.price, icon = 'hashtag', default = count, item = item.item, price = item.price, account = item.account})
        end
        if shop then
            local input = lib.inputDialog(shop..' (verkaufen)', inpMenuOptions)
            if not input then return end
            for i=1, #inpMenuOptions do
                Wait(100)
                local item = inpMenuOptions[i].item
                local label = inpMenuOptions[i].label
                local count = input[i]
                if count > 0 then
                    local price = inpMenuOptions[i].price
                    local currency = inpMenuOptions[i].currency
                    local buyer = inpMenuOptions[i].account
                    local amount = price * count
                    local itemcount = count
                    local lager = inpMenuOptions[i].lager
                    local verkauf = lib.callback.await('mor_sellshop:verkauf', source, item, itemcount, currency, amount, buyer, lager, shop)
                    local msg = {
                        title = '~w~Getreide Silo',
                        subtitle = "~b~Bankgutschrift erhalten.",
                        text = '~w~Du hast ~y~'..count..'x ~y~'..label..' ~w~für ~g~$'..price * count..' ~w~verkauft.',
                        duration = 0.4,
                        pict = 'CHAR_BANK_FLEECA',
                    }
                    Mor.PostFeed(msg)
                end
            end
        end
    end
end

for _,v in pairs (Con) do
    Mor.NPC:new({
        coords = vec3(v.pedCoords.x,v.pedCoords.y,v.pedCoords.z),
        heading = v.pedCoords.w,
        model = v.pedModel,
        anim = false,
        scenario = v.pedScenario,
        targetable = true,
        targetoptions = {
            label = 'Ansprechen',
            name = 'secSell01',
            icon = 'cash',
            distance = v.pedRadius,
            onSelect = function() generateOptionsMenu() end
        }
    })
end