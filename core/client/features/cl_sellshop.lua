
local Mor = require("client.cl_lib")

local shops = CfgSellShop.Shops
local aktivzone = nil
local OptionItems = {}
local lastVehicle = nil

function onEnter(self)
    aktivzone = self.zone
end

function onExit(self)
    aktivzone = nil
end

function inside(self)
    --aktivzone = self.zone
end


for _,v in pairs(shops) do
    lib.zones.sphere({
        coords = v.coords,
        radius = 8,
        debug = false,
        inside = inside,
        onEnter = onEnter,
        onExit = onExit,
        zone = v.zonename,
    })
end
CreateThread(function()
    for _,v in pairs(shops) do
        local coords = v.coords
        local heading = v.heading
        local pedhash = v.pedhash
        local zonename = v.zonename
        local label = v.label

        RequestModel(GetHashKey(v.ped))
            while not HasModelLoaded(GetHashKey(v.ped)) do
                Wait(1)
            end

        local blip = AddBlipForCoord(coords.x,coords.y,coords.z)
            SetBlipSprite(blip, v.blipsprite)
            SetBlipColour(blip, v.blipcolor)
            SetBlipAsShortRange(blip, true)
            SetBlipHiddenOnLegend(blip, v.bliphidden)
            SetBlipScale(blip, v.blipscale)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(label)
            EndTextCommandSetBlipName(blip)

        local npc = CreatePed(4, pedhash, coords.x, coords.y, coords.z-1, heading, true, true)
            FreezeEntityPosition(npc, true)
            SetEntityHeading(npc, heading)
            SetEntityInvincible(npc, true)
            SetBlockingOfNonTemporaryEvents(npc, true)
            TaskStartScenarioInPlace(npc, v.scenario, -1, true)

        local vkzone = exports.ox_target:addSphereZone({
            coords = coords,
            radius = 2,
            debag = false,
            options = {
                label = ''..label..' anprechen',
                icon = "dollar",
                distance = 2.0,
                onSelect = function()
                    AuswahlMenu()
                end
            },
        })
    end
end)

function AuswahlMenu()
    lib.registerContext({
        id = 'auswahlmenu',
        title = 'Verkaufsauswahl',
        options = {
            {
                title = 'Persönlicher Verkauf',
                description = 'Aus Deinen Taschen verkaufen.',
                icon = 'face',
                onSelect = function()
                    SellShopEnter()
                end

            },
            {
                title = 'Verkauf aus Kofferraum.',
                description = 'Kofferraum DEINES letzten Fahrzeugs.',
                icon = 'car',
                onSelect = function()
                    SellShopVehicleEnter()
                end
            }
        },
    })
    lib.showContext('auswahlmenu')
end

function SellShopEnter()
    OptionItems = {}
    for _,v in pairs(shops) do
        if aktivzone == v.zonename then
            local items = v.items
            for _,item in pairs(items) do
                local count = exports.ox_inventory:Search('count', item.item)
                if count >= 1 then
                    local price = math.random(item.minprice, item.maxprice)
                    local currency = item.currency
                    local buyer = item.buyer
                    local lager = item.lager
                    table.insert(OptionItems, {item = item.item, label = item.label, price = price, currency = currency, buyer = buyer, shoplabel = v.label, lager = lager})
                end
            end
        end
    end
    SellShopMenu()
end

function SellShopVehicleEnter()
    OptionItems = {}
    local vehicle = GetPlayersLastVehicle()
    local plate = GetVehicleNumberPlateText(vehicle)
    for _,v in pairs(shops) do
        if aktivzone == v.zonename then
            local items = v.items
            for _,item in pairs(items) do
                Wait(20)
                local count = lib.callback.await('InvItemCount', source, plate, item.item)
                if count == nil or (type(count) == "table" and next(count) == nil) then
                    --Notify('Fehler beim Verkauf.')
                else
                    if count > 0 then
                        local price = math.random(item.minprice, item.maxprice)
                        local currency = item.currency
                        local buyer = item.buyer
                        local lager = item.lager
                        table.insert(OptionItems, {item = item.item, label = item.label, price = price, currency = currency, buyer = buyer, shoplabel = v.label, lager = lager, count = count})
                    end
                end
            end
        end
    end
    SellShopVehicleMenu()
end

function SellShopMenu()
    local InputMenus = {}
    local shoplabel = nil
    for _,v in pairs(OptionItems) do
        shoplabel = v.shoplabel
        local item = v.item
        local label = v.label
        local price = v.price
        local count = exports.ox_inventory:Search('count', item)
        table.insert(InputMenus, {type = 'number', label = label, description = 'Preis: $'..price, icon = 'hashtag', default = count})
    end
    if shoplabel then
        local input = lib.inputDialog(shoplabel..' (verkaufen)', InputMenus)
        if not input then return end
        for i=1, #InputMenus do
            Wait(100)
            local item = OptionItems[i].item
            local label = OptionItems[i].label
            local count = input[i]
            if count > 0 then
                local price = OptionItems[i].price
                local currency = OptionItems[i].currency
                local buyer = OptionItems[i].buyer
                local amount = price * count
                local itemcount = count
                local lager = OptionItems[i].lager
                local verkauf = lib.callback.await('mor_sellshop:verkauf', source, item, itemcount, currency, amount, buyer, lager, shoplabel)
                local msg = {
                    title = '~w~Müllabgabe',
                    subtitle = "~b~Bankgutschrift erhalten.",
                    text = '~w~Du hast ~y~'..count..'x ~y~'..label..' ~w~für ~g~$'..price * count..' ~w~verkauft.',
                    duration = 0.4,
                    pict = 'CHAR_BANK_FLEECA',
                }
                Mor.PostFeed(msg)
            end
        end
    else
        local msg = {
            title = '~w~Müllabgabe',
            subtitle = "",
            text = '~y~Du hast nix was mich interessiert!',
            duration = 0.4,
            pict = 'CHAR_JIMMY_BOSTON',
        }
        Mor.PostFeed(msg)
    end
end

function SellShopVehicleMenu()
    local InputMenus = {}
    local shoplabel = nil
    local vehicle = GetPlayersLastVehicle()
    local plate = GetVehicleNumberPlateText(vehicle)
    for _,v in pairs(OptionItems) do
        shoplabel = v.shoplabel
        local item = v.item
        local label = v.label
        local price = v.price
        local count = v.count
        Wait(100)
        table.insert(InputMenus, {type = 'number', label = label, description = 'Preis: $'..price, icon = 'hashtag', default = count})
    end
    if shoplabel then
        local input = lib.inputDialog(shoplabel..' (verkaufen)', InputMenus)
        if not input then return end
        for i=1, #InputMenus do
            Wait(100)
            local item = OptionItems[i].item
            local label = OptionItems[i].label
            local count = input[i]
            if count > 0 then
                local price = OptionItems[i].price
                local currency = OptionItems[i].currency
                local buyer = OptionItems[i].buyer
                local amount = price * count
                local itemcount = count
                local lager = OptionItems[i].lager
                local verkauf = lib.callback.await('mor_sellshop:verkaufVehicle', source, item, itemcount, currency, amount, buyer, lager, plate, shoplabel)
                local msg = {
                    title = '~w~Müllabgabe',
                    subtitle = "~b~Bankgutschrift erhalten.",
                    text = '~w~Du hast ~y~'..count..'x ~y~'..label..' ~w~für ~g~$'..price * count..' ~w~verkauft.',
                    duration = 0.4,
                    pict = 'CHAR_JIMMY_BOSTON',
                }
                Mor.PostFeed(msg)
            end
        end
    else
        local msg = {
            title = '~w~Müllabgabe',
            subtitle = "",
            text = '~y~Du hast nix was mich interessiert!',
            duration = 0.4,
            pict = 'CHAR_JIMMY_BOSTON',
        }
        Mor.PostFeed(msg)
    end
end