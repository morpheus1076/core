
local Mor = require("client.cl_lib")

local storage = StorageConfig.Storages
local Options = {}
local EnterLager = nil

function onEnter(self)
    EnterLager = self.lagername
end

function onExit(self)
    EnterLager = nil
end

for k, v in pairs(storage) do
    local blip = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
    SetBlipSprite(blip, 478)
    SetBlipColour(blip, 70)
    SetBlipScale(blip, 0.2)
    SetBlipDisplay(blip, 5)
    SetBlipAsShortRange(blip, true)
    SetBlipHiddenOnLegend(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(v.label)
    EndTextCommandSetBlipName(blip)
end

for _, v in pairs(storage) do
    local lagerlabel = ''..v.label..' betreten.'
    Options = {label = lagerlabel, name = v.name, distance = 3, onSelect = function() LagerZugriff1(v.id) end}
    exports.ox_target:addBoxZone({
        coords = v.coords,
        size = vector3(3.0, 3.0, 2.0),
        rotation = 0,
        debug = false,
        options = Options,
    })
    local sphere = lib.zones.sphere({
        coords = v.coords,
        radius = 5.0,
        debug = false,
        lagername = v.name,
        onEnter = onEnter,
        onExit = onExit
    })
end

function LagerZugriff1(storageid)
    local ownercheck = lib.callback.await('CheckStorageOwner', false, storageid)
    if ownercheck == true then
        LagerZugriff(storageid)
    else
        Mor.Notify('Dieser Lager ist nicht Deins.')
        LagerKauf(storageid)
    end
end

function LagerKauf(storeid)
    local lagerlabel = nil
    local lagername = nil
    local lagerpreis = nil
    local lagerslots = nil
    local lagerplatz = nil

    for k, v in pairs(storage) do
        if v.id == storeid then
            lagerlabel = v.label
            lagername = v.name
            lagerpreis = v.preis
            lagerslots = v.slots
            lagerplatz = v.maxweight /1000
        end
    end

    local alert = lib.alertDialog({
        header = 'Lager Kauf',
        content = ''..lagerlabel..'  \n\n Preis: $'..lagerpreis..' \\\n Stellplätze: '..lagerslots..' Stück. \\\n Maximalgewicht: '..lagerplatz..' KG.\n\nKauf bestätigen? (Nur Bares ist Wahres!!)',
        centered = true,
        size = 'md',
        cancel = true
    })
    if alert == 'confirm' then
        local player = Ox.GetPlayer(PlayerId())
        local charid = player.charId
        local buystorage = lib.callback.await('BuyStorage', false, storeid, lagerpreis)
        if buystorage == true then
            Mor.Notify('~w~Du hast ~y~'..lagername..' ~g~erfolgreich ~w~kauft.')
            exports.ox_inventory:openInventory('stash', lagername)
        else
            Mor.Notify('~r~Du hast nicht genug Geld oder Stellplätze im Inventar.')
        end
    else
        Mor.Notify('~r~Lagerkauf abgebrochen')
    end
end

function LagerVerkauf(storeid)
    local alert = lib.alertDialog({
        header = 'Lager Verkauf',
        content = 'Lager: '..storeid..'  \n\n Verkaufspreis: $3.000 \n\n Alles wird aus dem Lager entnommen/gelöscht. \n\nVerkauf bestätigen?',
        centered = true,
        size = 'md',
        cancel = true
    })
    if alert == 'confirm' then
        local sellprice = 3000
        local sellstorage = lib.callback.await('SellStorage', false, storeid, sellprice)
        if sellstorage == true then
            Mor.Notify('~w~Du hast ~y~Lager: '..storeid..' ~g~erfolgreich ~w~verkauft.')
        else
            Mor.Notify('~r~Du besitz das Lager nicht. (Ticket)')
        end
    end
end

function LagerZugriff(storeid)
    local lager = EnterLager
    lib.registerContext({
        id = 'storagemenu',
        title = 'Lagermenü',
        options = {
        {
            title = 'Lager öffnen',
            onSelect = function()
                Wait(50)
                exports.ox_inventory:openInventory('stash', lager)
            end,
        },
        {
            title = 'Lager verkaufen',
            onSelect = function()
                LagerVerkauf(storeid)
            end,
        },
        }
    })
    lib.showContext('storagemenu')
end
