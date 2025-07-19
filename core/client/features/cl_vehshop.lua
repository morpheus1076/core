local Mor = require("client.cl_lib")
local Ox = require '@ox_core/lib/init'

local isRunningWorkaround = false
local shops = ConfigVehShop.Vehshops
local categories = ConfigVehShop.Menu
local openvehicle = {}
local ashop = nil
local sign = {}
local cfg = require("shared.cfg_core")

CreateThread(function()
    if cfg.Vehshop == true then
        for _, shopdata in ipairs(shops) do
            if shopdata.blipenabled then
                blip = AddBlipForCoord(shopdata.coords.x,shopdata.coords.y,shopdata.coords.z)
                SetBlipSprite(blip, shopdata.sprite)
                SetBlipColour(blip, shopdata.color)
                SetBlipAsShortRange(blip, true)
                SetBlipHiddenOnLegend(blip, shopdata.hidden)
                SetBlipScale(blip, shopdata.scale)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(shopdata.name)
                EndTextCommandSetBlipName(blip)
            end
            if shopdata.pedenabled then
                RequestModel(GetHashKey(shopdata.ped))
                while not HasModelLoaded(GetHashKey(shopdata.ped)) do
                    Wait(1)
                end
                local npc = CreatePed(4, shopdata.pedhash, shopdata.coords.x, shopdata.coords.y, shopdata.coords.z-1, shopdata.pedheading, false, true)
                FreezeEntityPosition(npc, true)
                SetEntityHeading(npc, shopdata.pedheading)
                SetEntityInvincible(npc, true)
                SetBlockingOfNonTemporaryEvents(npc, true)
                TaskStartScenarioInPlace(npc, shopdata.scenario, -1, true)
            end
            for _, catdata in ipairs(categories) do
                local Options = CreateOptions(catdata.category)
                lib.registerContext({id = catdata.category, title = catdata.menulabel, menu = catdata.shopmenu, options = Options})
            end
            exports.ox_target:addBoxZone({coords = shopdata.coords, size = shopdata.size, rotation = shopdata.heading, options = shopdata.options})
            lib.zones.box({coords = shopdata.coords, size = vec3(8, 8, 8), rotation = 0, tshopid = shopdata.shopmenu, debug = false, onEnter = OnEnter, onExit = OnExit})
        end
    end
end)

CreateThread(function()
    lib.registerContext({
        id = 'pdmcitymenu',
        title = 'PDM City',
        options = {
        {title = 'Kompaktwagen', menu = 'compacts', icon = 'bars', arrow = true},
        {title = 'Limousinen', menu = 'sedans', icon = 'bars', arrow = true},
        {title = 'Sportwagen', menu = 'sports', icon = 'bars', arrow = true},
        {title = 'Super Sportler', menu = 'super', icon = 'bars', arrow = true},
        {title = 'Muscle', menu = 'muscle', icon = 'bars', arrow = true},
        }
    })
    lib.registerContext({
        id = 'harmonymenu',
        title = 'Harmony Off-Road',
        options = {
        {title = 'Off-Road', menu = 'off-road', icon = 'bars', arrow = true},
        {title = 'Motorräder', menu = 'motorcycles', icon = 'bars', arrow = true},
        {title = 'SUVs', menu = 'suvs', icon = 'bars', arrow = true,},
        }
    })
    lib.registerContext({
        id = 'truckmenu',
        title = 'Trucks und Vans',
        options = {
        {title = 'Vans', menu = 'vans', icon = 'bars', arrow = true},
        {title = 'LKW', menu = 'commercial', icon = 'bars', arrow = true},
        }
    })
    lib.registerContext({
        id = 'boatsmenu',
        title = 'Bootshandel',
        options = {
        {title = 'Boote', menu = 'boats', icon = 'bars', arrow = true},
        }
    })
end)

CreateThread(function()
    lib.registerMenu({
        id = 'vorschaumenu',
        title = 'Vorschau',
        position = 'top-right',
        options = {
            {label = 'Privat BAR kaufen', description = 'Für Dich selber kaufen, Du musst das Geld bei Dir haben'},
            {label = 'Privat per Bank/Rechnung kaufen', description = 'Für Dich selber kaufen, Du musst das Geld auf der Bank haben. Kein Kredit'},
            {label = 'Geschäftlich BAR kaufen', description = 'Für Deine Firma kaufen, Du musst das Geld bei Dir haben'},
            {label = 'Geschäftlich per Bank/Rechnung kaufen', description = 'Für Deine Firma kaufen, Du musst das Geld auf der Bank haben. Kein Kredit'},
            {label = 'Abbrechen', description = 'Vorschau Abbrechen'},
        },
        onClose = function(keyPressed)
            if keyPressed then
                lib.callback.await('VehicleDelete', source, openvehicle)
                Mor.Notify('~r~Fahrzeugkauf abgebrochen.')
            end
        end,
        onSelect = function(selected)
            --print(selected)
        end,
    }, function(selected)
        if selected == 1 then
            local count = exports.ox_inventory:Search('count', 'money')
            local price = sign.price
            local vehicleProps = lib.getVehicleProperties(GetVehiclePedIsUsing(PlayerPedId()))
            Wait(50)
            if count >= price then
                local barprivat = lib.callback.await('PrivatBarKauf', source, price, openvehicle, vehicleProps)
                if barprivat == 'verkauft' then
                    Mor.Notify('~w~Herzlichen Glükwunsch zum ~g~neuen ~w~Fahrzeug.')
                else
                    Mor.Notify('~r~Fehler 1.1 :: Barkauf Privat.')
                    lib.callback.await('VehicleDelete', source, openvehicle)
                end
            else
                Mor.Notify('~r~Du hast nicht genugend Bargeld dabei.')
                lib.callback.await('VehicleDelete', source, openvehicle)
            end
        elseif selected == 2 then
            local price = sign.price
            local vehicleProps = lib.getVehicleProperties(GetVehiclePedIsUsing(PlayerPedId()))
            local bankprivat = lib.callback.await('PrivatBank', source, price, openvehicle, vehicleProps)
            if bankprivat then
                Mor.Notify('~w~Herzlichen Glükwunsch zum ~g~neuen ~w~Fahrzeug.')
            else
                Mor.Notify('~r~Fehler 1.2 :: Barkauf Firma.')
                lib.callback.await('VehicleDelete', source, openvehicle)
            end
        elseif selected == 3 then
            local price = sign.price
            local vehicleProps = lib.getVehicleProperties(GetVehiclePedIsUsing(PlayerPedId()))
            local barjob = lib.callback.await('JobBar', source, price, openvehicle, vehicleProps)
            if barjob then
                Mor.Notify('~w~Herzlichen Glükwunsch zum ~g~neuen ~w~Fahrzeug.')
            else
                Mor.Notify('~r~Fehler 1.3 :: Barkauf Firma.')
                lib.callback.await('VehicleDelete', source, openvehicle)
            end
        elseif selected == 4 then
            local price = sign.price
            local vehicleProps = lib.getVehicleProperties(GetVehiclePedIsUsing(PlayerPedId()))
            local bankjob = lib.callback.await('JobBank', source, price, openvehicle, vehicleProps)
            if bankjob then
                Mor.Notify('~w~Herzlichen Glükwunsch zum ~g~neuen ~w~Fahrzeug.')
            else
                Mor.Notify('~r~Fehler 1.4 :: Barkauf Firma.')
                lib.callback.await('VehicleDelete', source, openvehicle)
            end
        elseif selected == 5 then
            lib.callback.await('VehicleDelete', source, openvehicle)
            Mor.Notify('~r~Fahrzeugkauf abgebrochen.')
        end
    end)
end)

function CreateOptions(data)
    local models = lib.callback.await('GetAllVehicles', source)
    Wait(5)
    local Options = {}
    local vehicleProps = nil
    for i=1, #models do
        if models[i].category == data then
            if models[i].freigegeben == 1 then
                local getvehicle = models[i].model
                local vehdata = Ox.GetVehicleData(getvehicle)
                if vehdata == nil then return end
                models[i].trunk = models[i].trunk / 1000
                models[i].glovebox = models[i].glovebox / 1000
                local speed = math.floor(vehdata.speed)
                local geschw = math.floor(speed * 3.6)
                table.insert(Options, {title = vehdata.name, description = 'Preis: $'..vehdata.price,
                    image = "nui://core/images/"..models[i].model..".png",
                    metadata = {
                        {label = 'Geschwindigkeit: ', value = ''..geschw..' km/h'},
                        {label = 'Kofferraum: ', value = ''..models[i].trunk..' kg'},
                        {label = 'Handschufach: ', value = ''..models[i].glovebox.. ' kg'},
                        {label = 'Kategorie: ', value = models[i].category},
                        {label = 'Sitze: ', value = vehdata.seats},
                        {label = 'Hersteller: ', value = vehdata.make},
                    },
                    onSelect = function()
                        sign = {name = models[i].model, price = vehdata.price, hers = vehdata.make, catl = models[i].category, vehprops = vehicleProps, vlabel = vehdata.name}
                        Vorschau()
                    end,
                })
            end
        end
    end
    return Options
end

function OnEnter(self)
	ashop = self.tshopid
end

function OnExit(self)
	ashop = nil
end

function Vorschau(data)
    local model = sign.name
    local coords = {}
    local heading = 0
    for _, shopdata in ipairs(shops) do
        if ashop == shopdata.shopmenu then
            coords = shopdata.spawnpoint.coords
            heading = shopdata.spawnpoint.heading
        end
    end
    local getcall = lib.callback.await('VorschauVehicle', source, model, coords, heading)
    openvehicle = getcall
    lib.showMenu('vorschaumenu')
end