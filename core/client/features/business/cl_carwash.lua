
lib.locale()
local Mor = require("client.cl_lib")

local player = nil
local playergroup = nil
local zoneident = nil
local vehicle = nil

local keybind = lib.addKeybind({
    name = 'carwash',
    description = 'drücke E um die Wäsche zu aktivieren.',
    defaultKey = 'E',
    disabled = true,
    onPressed = function(self)
        if vehicle then
            local cash = exports.ox_inventory:GetItemCount('money')
            if cash >= 30 then
                SetVehicleEngineOn(vehicle, false, true, true)
                SetVehicleUndriveable(vehicle, true)
                Fahrzeugwaesche()
            else
                Mor.Notify('~w~Du hast ~r~keine $30 Bargeld ~w~dabei?')
            end
        end
    end
})

function zoneonEnter(self)
    vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    zoneident = self.ident
    local driver = GetPedInVehicleSeat(vehicle, -1)
    if (IsPedInAnyVehicle(PlayerPedId(), false)) and (driver == PlayerPedId()) then
        keybind:disable(false)
        lib.showTextUI('[E] - Fahrzeug waschen (Bar $30)', {
            position = "left-center",
            icon = 'car',
            style = {
                borderRadius = 0,
                backgroundColor = '	#00000080',
                color = 'white'
            }
        })
    end
    keybind:disable(false)
end

function zoneonExit(self)
    vehicle = nil
    zoneident = nil
    lib.hideTextUI()
end

function Fahrzeugwaesche()
    lib.hideTextUI()
    keybind:disable(true)
    AddTextEntry("CUSTOMLOADSTR", "Fahrzeugwäsche läuft...")
    BeginTextCommandBusyspinnerOn("CUSTOMLOADSTR")
    EndTextCommandBusyspinnerOn(4)
    Wait(20000)
    BusyspinnerOff()
    if vehicle then
        TriggerServerEvent('CarwashAbrechnung', zoneident)
        SetVehicleUndriveable(vehicle, false)
        SetVehicleEngineOn(vehicle, true, true, false)
        SetVehicleDirtLevel(vehicle, 0.0)
    end
end

if cfg_feat.carwash == true then
    for i=1, #Cfg_Carwash.Stations do
        ---Blip---
        local bl = Cfg_Carwash.Stations[i]
        local coords = bl.zonecoords
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, 100)
        SetBlipColour(blip, 3)
        SetBlipAsShortRange(blip, true)
        SetBlipHiddenOnLegend(blip, true)
        SetBlipScale(blip, 0.5)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString("Waschstraße")
        EndTextCommandSetBlipName(blip)
        ---Zone---
        local box = lib.zones.box({
            coords = Cfg_Carwash.Stations[i].zonecoords,
            size = vec3(5, 16, 4),
            rotation = Cfg_Carwash.Stations[i].zoneheading,
            debug = Cfg_Carwash.Stations[i].zonedebug,
            ident = Cfg_Carwash.Stations[i].id,
            onEnter = zoneonEnter,
            onExit = zoneonExit
        })
        ---NPC---
        local setting = Cfg_Carwash.Stations[i]
        local modelHash = setting.pedmodel
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
        Wait(0)
        end
        local npc = CreatePed(4, setting.pedmodel, setting.pointcoords.x, setting.pointcoords.y, setting.pointcoords.z-1, setting.pointheading, true, true)
        FreezeEntityPosition(npc, true)
        SetEntityHeading(npc, setting.pointheading)
        SetEntityInvincible(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        TaskStartScenarioInPlace(npc, setting.pedscenario, -1, true)
        SetModelAsNoLongerNeeded(setting.pedmodel)
        ---Target---
        exports.ox_target:addBoxZone({
            coords = setting.pointcoords,
            size = vec3(2,2,2),
            rotation = setting.pointheading,
            debug = setting.zonedebug,
            zone = setting.id,
            options = {
                label = 'Waschanlage Verwaltung',
                name = setting.id,
                icon = 'car',
                distance = setting.pointdistance,
                zone = setting.id,
                onSelect = function()
                    CWKauf()
                end
            }
        })
    end
end

function GetDistanceBetweenVec3(vecA, vecB)
    return #(vecA - vecB)
end

function CWKauf()
    player = Ox.GetPlayer(PlayerId())
    local playerCoords = GetEntityCoords(PlayerPedId())
    for i=1, #Cfg_Carwash.Stations do
        local pointCoords = Cfg_Carwash.Stations[i].pointcoords
        local distance = GetDistanceBetweenVec3(playerCoords, pointCoords)
        if distance <= 6 then
            local zone = Cfg_Carwash.Stations[i].id
            local cwlabel = Cfg_Carwash.Stations[i].label
            local cwprice = Cfg_Carwash.Stations[i].price
            local getowner = lib.callback.await('GetCarwashOwner', source, zone)

            if (getowner ~= 0) and not (getowner == player.charId) then
                Mor.Notify('Gehört schon jemand anderem. \n Nicht zu Verkaufen.')
            elseif getowner == player.charId then
                local sellprice = math.floor(cwprice / 1.5)
                local sellcontent = "Möchtest Du "..cwlabel.." für $"..sellprice.." verkaufen?"
                local sellcw = lib.alertDialog({
                    header = 'Waschanlage verkaufen',
                    content = sellcontent,
                    centered = true,
                    cancel = true,
                    size = 'xl',
                    labels = {
                        cancel = 'Abbrechen',
                        confirm = 'Verkaufen',
                    }
                })
                if sellcw == 'confirm' then
                    local setverkauf = lib.callback.await('CarwashVerkaufen', source, zone, sellprice, cwlabel)
                    if setverkauf == true then
                        Mor.Notify('~w~Waschanlage ~r~verkauft~w~.')
                    elseif setverkauf == false then
                        Mor.Notify('~r~Der Staat hat nicht genug Geld.')
                        Wait(3000)
                        Mor.Notify('~w~Verkauf ~r~abgebrochen.')
                    end
                else
                    Mor.Notify('Verkauf ~r~abgebrochen.')
                    lib.closeAlertDialog()
                end
            elseif getowner == 0 then
                local buycontent = "Möchtest Du "..cwlabel.." für $"..cwprice.." kaufen?  \n Der aktuelle Preis pro Wäsche beträgt $30.  \n Die Einnahmen werden Deinem Konto gutgeschrieben."
                local buycw = lib.alertDialog({
                    header = 'Waschanlage kaufen',
                    content = buycontent,
                    centered = true,
                    cancel = true,
                    size = 'xl',
                    labels = {
                        cancel = 'Abbrechen',
                        confirm = 'Kaufen',
                    }
                })
                if buycw == 'confirm' then
                    local setkauf = lib.callback.await('CarwashKaufen', source, zone, cwprice, cwlabel)
                    if setkauf == true then
                        Mor.Notify('~w~Waschanlage ~g~gekauft~w~.')
                    else
                        Mor.Notify('~w~Du hast ~r~nicht genug Geld ~w~auf Deinem Konto.')
                    end
                else
                    Mor.Notify('Kauf ~r~abgebrochen.')
                    lib.closeAlertDialog()
                end
            end
        end
    end
end

AddEventHandler('ox:playerLoaded', function(playerId, isNew)
    Wait(5000)
    player = Ox.GetPlayer(PlayerId())
    playergroup = player.getGroup(player.getGroups())
end)