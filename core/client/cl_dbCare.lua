
------------------------------------------------------------------------
local Notify = function(msg) exports['mor_nucleus']:Notify(msg) end
local InfoLog = function(msg) exports['mor_nucleus']:InfoLog(msg) end
local WarnLog = function(msg) exports['mor_nucleus']:WarnLog(msg) end
------------------------------------------------------------------------

local isAdmin = false

lib.callback.register('mor_dbcore:AllVehicleModels', function()
    local allModels = GetAllVehicleModels()
    return allModels
end)

local function StartVehDBCheck()
    local themodels = GetAllVehicleModels()
    Notify('Es gibt aktuell :'..#themodels..' Fahrzeugmodele insgesamt.')
    local allModels = lib.callback.await('vehmodels', source, themodels)
    if allModels == 'erledigt' then
        Notify('~g~Alle Modelle abgeglichen.  \n ~b~AlleWerte aktuallisiert.')
    end
end

RegisterNetEvent('StartDBVehModels')
AddEventHandler('StartDBVehModels', function()
    if isAdmin == true then
        local alertfrage = lib.alertDialog({
            header = 'ADMIN ::: ALLE Fahrzeuge in der DB prüfen!!!!!!',
            content = 'Achtung benötigt sehr viel Performance, da alle Fahrzeuge(ServerSide) mit der Datenbank abgeglichen werden.',
            centered = true,
            cancel = true,
            size = 'lg',
            labels = {
                cancel = 'Abbruch',
                confirm = 'Ausführen'
            }
        })
        if alertfrage == 'confirm' then
            StartVehDBCheck()
        else
            Notify('Abbruch')
        end
    else
        Notify("Du hast keine Berechtigung, diesen Befehl zu nutzen!")
    end
end)

AddEventHandler('ox:playerLoaded', function(playerId, isNew)
    local aceabfrage = lib.callback.await('AceCheck')
    isAdmin = aceabfrage
end)
