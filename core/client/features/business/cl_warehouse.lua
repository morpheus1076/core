

local Mor = require("client.cl_lib")

local parameters = {}
local paralaptop = {}
local ownerWH = {}
local WHstufe = 1
local maxStufe = 12
local spawnedObj = {}
local targetZones = {}
local ziel = nil

lib.hideTextUI()

-- Menüs --

lib.registerContext({
    id = 'eingang',
    title = 'Lagerräume',
    options = {
        {
            title = 'Kaufen',
            description = 'Lagerraum kaufen, da noch keiner gekauft wurde.',
            icon = 'circle',
            onSelect = function()
                local input = lib.inputDialog('Lagerraum(min. 500KG ('..maxStufe..'fach aufrüstbar)) kaufen für $200.000', {
                    {type = 'select', label = '$200.000 zahlen per:',
                    options = {
                        {label = 'Barzahlung', value = '1'},
                        {label = 'Bankeinzug', value = '2'},
                        },
                    description = 'Zahlungsart auswählen.',
                    required = true,
                    default = '2',
                    placeholder = 'Zahlungsart'
                    },
                })
                if input[1] == "2" then
                    local kauf = lib.callback.await('Bankeinzug', source)
                    if kauf == 'kauf' then
                        Mor.Notify('~r~Lagerraum:~g~ Kauf per Bankeinzug')
                    else
                        Mor.Notify('~r~Lagerraum:~g~ Kauf fehlgeschlagen. Man kann nur ein Lagerraum besitzen')
                    end
                elseif input[1] == "1" then
                    local count = exports.ox_inventory:Search('count', 'money')
                    if count < 200000 then
                        Mor.Notify('~r~Lagerraum:~g~ Kauf fehlgeschlagen. Nicht genügend Bargeld?')
                    else
                        local whbar = lib.callback.await('Barzahlung', source)
                        if whbar == 'kauf' then
                            Mor.Notify('~r~Lagerraum:~g~ Kauf per Barzahlung')
                        else
                            Mor.Notify('~r~Lagerraum:~g~ Kauf fehlgeschlagen.')
                        end
                    end
                else
                    Mor.Notify('~r~Fehler:~g~ Kauf fehlgeschlagen.(Ticket)')
                end
            end
        },
    }
})

-- Spawning --

function SpawnObj(data)
    local stufe = data
    RemoveZones()
    if spawnedObj == nil or (type(spawnedObj) == "table" and next(spawnedObj) == nil) then
        for i = 1, stufe do
            local cfgObj = WHConfig.Platz[i]
            local cfgPlz = WHConfig.Lager[i]
            if cfgObj then

                local obj = CreateObjectNoOffset(cfgObj.prophash, cfgObj.coords.x, cfgObj.coords.y, cfgObj.coords.z-1.0, true, false, false)
                table.insert(spawnedObj, obj )
                local newHeading = (cfgObj.heading + 180.0) % 360
                SetEntityHeading(obj, newHeading)
                FreezeEntityPosition(obj, true)
                SetEntityAsMissionEntity(obj, true, true)
                TriggerServerEvent('WHInventory', source)
                parameters = {
                    coords = cfgPlz.coords,
                    name = cfgPlz.id,
                    id = cfgPlz.id,
                    radius = 1.5,
                    options = {
                        label = cfgPlz.label,
                        distance = 3.0,
                        onSelect = function()
                            exports.ox_inventory:openInventory('stash', {cfgPlz.id, player.charId})
                        end
                    }
                }
            end
            local zoneid = exports.ox_target:addSphereZone(parameters)
            table.insert(targetZones, zoneid)
        end
    else
        for i = 1, stufe do
            local cfgObj = WHConfig.Platz[i]
            local cfgPlz = WHConfig.Lager[i]
            if cfgObj then
                local obj = CreateObjectNoOffset(cfgObj.prophash, cfgObj.coords.x, cfgObj.coords.y, cfgObj.coords.z-1.0, true, false, false)
                table.insert( spawnedObj, obj )
                local newHeading = (cfgObj.heading + 180.0) % 360
                SetEntityHeading(obj, newHeading)
                FreezeEntityPosition(obj, true)
                SetEntityAsMissionEntity(obj, true, true)
                TriggerServerEvent('WHInventory', source)
                parameters = {
                    coords = cfgPlz.coords,
                    name = cfgPlz.id,
                    id = cfgPlz.id,
                    radius = 1.5,
                    options = {
                        label = cfgPlz.label,
                        distance = 3.0,
                        onSelect = function()
                            exports.ox_inventory:openInventory('stash', cfgPlz.id)
                        end
                    }
                }
            end
            local zoneid = exports.ox_target:addSphereZone(parameters)
            table.insert(targetZones, zoneid)
        end
    end
end

-- Teleport --

CreateThread(function()
    local cfgTele = WHConfig.Tele
    parameters = {}
    paralaptop = {}
    for i = 1, #cfgTele do
        local coords = cfgTele[i].coords
        Wait(300)
        local sphere = lib.zones.sphere({
            coords = coords,
            radius = 2.0,
            debug = false,
            name = cfgTele[i].name,
            label = cfgTele[i].label,
            ziel = cfgTele[i].ziel,
            zielheading = cfgTele[i].heading,
            inside = inside,
            onExit = onexit,
            onEnter = onenter
        })
        Wait(300)
        if cfgTele[i].blipenabled then
            blip = AddBlipForCoord(cfgTele[i].coords.x,cfgTele[i].coords.y,cfgTele[i].coords.z)
            SetBlipSprite(blip, 478)
            SetBlipColour(blip, 16)
            SetBlipAsShortRange(blip, true)
            SetBlipHiddenOnLegend(blip, true)
            SetBlipScale(blip, 0.5)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString('Lagerräume')
            EndTextCommandSetBlipName(blip)
        end
    end
end)

function inside(self)
    local taste = IsControlJustPressed(0, 51)
    if taste and IsPedOnFoot(PlayerPedId()) then
        ownerWH = lib.callback.await('CheckWH', source)
        parameters = {}
        paralaptop = {}
        if ownerWH == 0 or ownerWH[1].whowner == 0 then
            lib.hideTextUI()
            lib.showContext('eingang')
        elseif ownerWH[1].whowner ~= 0 then
            SpawnObj(ownerWH[1].whstufe)
            local tziel = ziel
            StartPlayerTeleport(PlayerId(), tziel.x, tziel.y, tziel.z, self.zielheading, false, true, true)
            Laptop()
            lib.hideTextUI()
        end
    end
end

function onexit(self)
    lib.hideTextUI()
    ziel = nil
end

function onenter(self)
    ziel = self.ziel
    ownerWH = lib.callback.await('CheckWH', source)
    lib.showTextUI('[E] - '..self.label..'', {
        position = 'left-center',
        icon = 'hand',
        style = {
            borderRadius = 1,
            backgroundColor = 'black',
            color = 'white'
        }
    })
    --WHstufe = ownerWH[1].whstufe
end

function Laptop()
    exports.ox_target:removeZone("laptopWH")
    paralaptop = {}
    ReLoad()
    CreateMenu()
    local lapcoords = vec3(1087.741, -3101.304, -39.200)
    paralaptop = {
        coords = lapcoords,
        name = "laptopWH",
        radius = 1.0,
        options = {
            label = 'Lagerraum Verwaltung',
            name = 'laptoptarget',
            distance = 3.0,
            onSelect = function()
                ReLoad()
                CreateMenu()
                lib.showContext('laptop')
            end
        }
    }
    exports.ox_target:addSphereZone(paralaptop)
    lib.hideTextUI()
end

function CreateMenu()
    lib.registerContext({
        id = 'laptop',
        title = 'Lagererweiterung',
        options = {
            {
                title = 'Aktuelle Stufe: '..WHstufe..' von '..maxStufe..' möglichen.',
                description = 'Alle Transaktionen laufen über Dein Bankkonto',
                disabled = true
            },
            {
                title = 'Update Kaufen',
                description = 'Lagerraumerweiterung kaufen.',
                icon = 'circle',
                onSelect = function()
                    local updateWH = lib.callback.await('UpdateWH', source)
                    if updateWH == 'fehler' then
                        Mor.Notify('~r~Update Fehler:~g~ Nicht genügend Geld auf dem Bakkonto vorhanden.')
                        ReLoad()
                    else
                        ReLoad()
                        Mor.Notify('~g~Update erfolgreich:~r~ Lagerraumerweiterung erfolgreich gekauft.')
                        local testWH = lib.callback.await('CheckWH', source)
                        WHstufe = testWH[1].whstufe
                        SpawnObj(testWH[1].whstufe)
                    end
                end,
                metadata = {
                    'Kaufpreis:', '$20.000'
                },
            },
            {
                title = 'Update Verkaufen',
                description = 'Lagerraumerweiterung verkaufen.',
                icon = 'circle',
                onSelect = function()
                    local downgradeWH = lib.callback.await('DowngradeWH', source)
                    if downgradeWH == 'fehler' then
                        Mor.Notify('~r~Verkaufen Fehler:~g~ Minimum Stufe erreicht (min Stufe 1).')
                        ReLoad()
                    else
                        DelObj()
                        RemoveZones()
                        ReLoad()
                        local testWH = lib.callback.await('CheckWH', source)
                        WHstufe = testWH[1].whstufe
                        SpawnObj(testWH[1].whstufe)
                        Mor.Notify('~g~Update erfolgreich:~r~ Lagerraumerweiterung erfolgreich verkauft.')
                    end
                end,
                metadata = {
                    'Verkaufspreis:', '$10.000'
                },
            },
            {
                title = 'Lagerraum Verkaufen für $150.000',
                description = 'Lagerraum verkaufen.',
                icon = 'circle',
                onSelect = function()
                    local verkaufWH = lib.callback.await('VerkaufWH', source)
                    if verkaufWH == 'fehler' then
                        Mor.Notify('~r~Verkaufen Fehler:~g~ Minimum Stufe erreicht (min Stufe 1).')
                        ReLoad()
                        StartPlayerTeleport(PlayerId(), 913.974, -1273.473, 27.096, 217.940, false, true, true)
                        lib.hideTextUI()
                    else
                        local verkauf = lib.callback.await('ClearInvComplete', source)
                        if verkauf == 'fehler' then
                            Mor.Notify('~r~Verkaufen Fehler:~g~ Fehler')
                        else
                            Mor.Notify('~g~Verkaufen erfolgreich:~r~ Lagerraum erfolgreich verkauft.')
                            DelObj()
                            StartPlayerTeleport(PlayerId(), 913.974, -1273.473, 27.096, 217.940, false, true, true)
                            lib.hideTextUI()
                        end
                    end
                end,
                metadata = {
                    'Verkaufspreis:', '$150.000'
                },
            },
        }
    })
end

function ReLoad()
    ownerWH = lib.callback.await('CheckWH', source)
    Wait(20)
    if ownerWH then
        WHstufe = ownerWH[1].whstufe
        Wait(50)
        SpawnObj(ownerWH[1].whstufe)
    else
        Wait(50)
    end
end

function DelObj()
    if spawnedObj == nil or (type(spawnedObj) == "table" and next(spawnedObj) == nil) then
        return
    else
        for i = 1, #spawnedObj do
            DeleteEntity(spawnedObj[i])
        end
        spawnedObj = {}
    end
    Wait(100)
end

function RemoveZones()
    if targetZones == nil or (type(targetZones) == "table" and next(targetZones) == nil) then
        return
    else
        for i = 1, #targetZones do
            exports.ox_target:removeZone(targetZones[i])
        end
        targetZones = {}
    end
    Wait(100)
end