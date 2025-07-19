
local Mor = require("client.cl_lib")
local cfg = require('shared.cfg_core')

local housingData = {}
local housingBlips = {}
local housingMarkers = {}
local housingPoints = {}

local currentBucket = 0
local currentHouseId = nil
local currentHouseData = {
    enter = nil,
    leave = nil,
    id = 0,
    price = nil,
    charID = 0,
    closed = 1
}

-- vec4 Parser
local function parseVec4(vec4String)
    local x, y, z, h = vec4String:match("vec4%(([%d%.%-]+), ([%d%.%-]+), ([%d%.%-]+), ([%d%.%-]+)%)")
    return vec4(tonumber(x), tonumber(y), tonumber(z), tonumber(h))
end

-- Beim Betreten/Verlassen des Hauses den Zustand speichern
local function teleportPlayer(coords, houseId, isEntering)
    local ped = PlayerPedId()
    local playerPos = GetEntityCoords(ped)

    -- Fade out
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do Wait(10) end

    if isEntering then
        currentBucket = 1000 + houseId
        currentHouseId = houseId
        -- Aktuelle Position an Server senden zum Speichern
        TriggerServerEvent('housing:enterHouse', currentBucket, vec4(playerPos.x, playerPos.y, playerPos.z, GetEntityHeading(ped)))
    else
        currentBucket = 0
        currentHouseId = nil
        TriggerServerEvent('housing:leaveHouse')
    end

    -- Teleport
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    SetEntityHeading(ped, coords.w or coords.h)

    -- Fade in
    DoScreenFadeIn(500)
end

local function CreateLeaveMenu()
    local player = Ox.GetPlayer(PlayerId())
    if currentHouseData.charID == player.charId then
        lib.registerContext({
            id = 'housingmenu_leave',
            title = 'Gebäude Menü',
            options = {
                {
                    title = 'Tür aufschließen',
                    description = 'Tür aufschließen. (Kann jeder rein)',
                    onSelect = function()
                        currentHouseData.closed = 0
                        local openDoor = lib.callback.await('OpenDoor', currentHouseData.id )
                        if openDoor == true then
                            Mor.Notify('~g~Aufgeschlossen.')
                        else
                            Mor.Notify('~r~Fehler.')
                        end
                        TriggerEvent('housing:updateMarkers')
                    end,
                    icon = 'door-open'
                },
                {
                    title = 'Tür abschließen',
                    description = 'Tür wieder verschließen.',
                    onSelect = function()
                        currentHouseData.closed = 1
                        local closeDoor = lib.callback.await('CloseDoor', currentHouseData.id )
                        if closeDoor == true then
                            Mor.Notify('~y~Abgeschlossen.')
                        else
                            Mor.Notify('~r~Fehler.')
                        end
                        TriggerEvent('housing:updateMarkers')
                    end,
                    icon = 'door-closed'
                },
                {
                    title = 'Verlassen',
                    description = 'Zum Verlassen',
                    onSelect = function()
                        if currentHouseData.id ~= 0 then
                            teleportPlayer(currentHouseData.enter, currentHouseData.id, false)
                            Wait(2000)
                            currentHouseData.id = 0
                        else
                            Mor.Notify('~r~Haus verschlossen.')
                        end
                    end,
                    icon = 'house',
                    iconcolor = 'green',
                },
            }
        })
    else
        lib.registerContext({
            id = 'housingmenu_leave',
            title = 'Gebäude Menü',
            options = {
                {
                    title = 'Verlassen',
                    description = 'Zum Verlassen',
                    onSelect = function()
                        if currentHouseData.id ~= 0 then
                            teleportPlayer(currentHouseData.enter, currentHouseData.id, false)
                            Wait(2000)
                            currentHouseData.id = 0
                        else
                            Mor.Notify('~r~Haus verschlossen.')
                            teleportPlayer(currentHouseData.enter, currentHouseData.id, false)
                        end
                    end,
                    icon = 'house',
                    iconcolor = 'green',
                },
            }
        })
    end
    lib.showContext('housingmenu_leave')
end

local function CreateEnterMenu()
    TriggerEvent('housing:updateMarkers')
    local player = Ox.GetPlayer(PlayerId())
    if currentHouseData.charID == player.charId then
        local sellprice = math.floor(currentHouseData.price/2)
        lib.registerContext({
            id = 'housingmenu_enter',
            title = 'Gebäude Menü',
            options = {
                {
                    title = 'Betreten',
                    description = 'Zum Betreten',
                    onSelect = function()
                        if currentHouseData.id ~= 0 and currentHouseData.closed == 0 then
                            teleportPlayer(currentHouseData.leave, currentHouseData.id, true)
                        else
                            Mor.Notify('~r~Haus verschlossen.')
                        end
                    end,
                    icon = 'house',
                    iconcolor = 'green',
                },
                {
                    title = 'Tür aufschließen',
                    description = 'Tür aufschließen. (Kann jeder rein)',
                    onSelect = function()
                        currentHouseData.closed = 0
                        local openDoor = lib.callback.await('OpenDoor', currentHouseData.id )
                        if openDoor == true then
                            Mor.Notify('~g~Aufgeschlossen.')
                        else
                            Mor.Notify('~r~Fehler.')
                        end
                        TriggerEvent('housing:updateMarkers')
                    end,
                    icon = 'door-open'
                },
                {
                    title = 'Tür abschließen',
                    description = 'Tür wieder verschließen.',
                    onSelect = function()
                        currentHouseData.closed = 1
                        local closeDoor = lib.callback.await('CloseDoor', currentHouseData.id )
                        if closeDoor == true then
                            Mor.Notify('~y~Abgeschlossen.')
                        else
                            Mor.Notify('~r~Fehler.')
                        end
                        TriggerEvent('housing:updateMarkers')
                    end,
                    icon = 'door-closed'
                },
                {
                    title = 'Verkaufen',
                    description = 'Objekt verkaufen für $'..sellprice..' ? (Bankkonto)',
                    onSelect = function()
                        local sellHouse = lib.callback.await('SellHouse', source, currentHouseData.id, sellprice)
                        if sellHouse == true then
                            Mor.Notify('Immobilie verkauft, auf Bankkonto gebucht.')
                            TriggerEvent('housing:updateMarkers')
                        else
                            Mor.Notify('~w~Immobilienverkauft ~r~nicht möglich~w~. Käufer hat kein Geld.')
                        end
                    end,
                    icon = 'house'
                },
            }
        })
    else
        lib.registerContext({
            id = 'housingmenu_enter',
            title = 'Gebäude Menü',
            options = {
                {
                    title = 'Betreten',
                    description = 'Zum Betreten.',
                    onSelect = function()
                        if currentHouseData.id ~= 0 and currentHouseData.closed == 0 then
                            teleportPlayer(currentHouseData.leave, currentHouseData.id, true)
                        else
                            Mor.Notify({'~r~Haus verschlossen.'})
                        end
                    end,
                    icon = 'door-open',
                    iconcolor = 'green',
                },
                {
                    title = 'Kaufen',
                    description = 'Objekt kaufen für $'..currentHouseData.price..' ? (Bankkonto)',
                    onSelect = function()
                        local buyHouse = lib.callback.await('BuyHouse', source, currentHouseData.id, currentHouseData.price)
                        if buyHouse == true then
                            Mor.Notify('Immobilie gekauft, von Bankkonto abgebucht.')
                            TriggerEvent('housing:updateMarkers')
                        else
                            Mor.Notify('~w~Immobilienkauft ~r~nicht möglich~w~. Konto ohne Deckung.')
                        end
                    end,
                    icon = 'house'
                },
                {
                    title = 'Einbrechen',
                    description = '???',
                    onSelect = function()
                        Mor.Notify('Einbruch, noch in Arbeit.')
                    end,
                    icon = 'house'
                },
            }
        })
    end
    lib.showContext('housingmenu_enter')
end

-- Marker und Blips erstellen
local function createHousingMarkers(houses)
    -- Alte Einträge löschen
    for _, blip in pairs(housingBlips) do RemoveBlip(blip) end
    --for _, point in pairs(housingPoints) do lib.points.remove(point.id) end

    housingBlips = {}
    --housingMarkers = houses -- Für die Draw-Schleife
    housingPoints = {}

    for _, house in ipairs(houses) do
        local enter = parseVec4(house.enter)
        local leave = parseVec4(house.leave)
        local isAvailable = house.charId == 0

        -- BLIPS (bleiben erhalten wie besprochen)
        local blip = AddBlipForCoord(enter.x, enter.y, enter.z)
        SetBlipSprite(blip, 40)
        SetBlipColour(blip, isAvailable and 2 or 1) -- Grün oder Rot
        SetBlipScale(blip, 0.2)
        SetBlipCategory(blip, isAvailable and 10 or 11)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(("%s %s - %s"):format(house.street, house.number, isAvailable and "Verfügbar" or "Verkauft"))
        EndTextCommandSetBlipName(blip)
        table.insert(housingBlips, blip)

        -- POINTS (ox_lib)
        local enterPointId = "house_enter_"..house.id
        housingPoints[enterPointId] = lib.points.new({
            id = enterPointId,
            houseData = house,
            coords = vec3(enter.x, enter.y, enter.z),
            distance = 1.5,
            onEnter = function(self)
                lib.showTextUI('[E] - Haus Menü', {
                    position = "left-center",
                    icon = 'door-open'
                })
                currentHouseData = {
                    enter = enter,
                    leave = leave,
                    id = house.id,
                    price = house.price,
                    charID = house.charId,
                    closed = house.closed
                }
            end,
            onExit = function(self)
                lib.hideTextUI()
            end,
            nearby = function(self)
                if IsControlJustReleased(0, 38) then
                    CreateEnterMenu()
                end
            end
        })

        local leavePointId = "house_leave_"..house.id-- LEAVE POINT
        housingPoints[leavePointId] = lib.points.new({
            id = leavePointId,
            houseData = house,
            coords = vec3(leave.x, leave.y, leave.z),
            distance = 1.5,
            onEnter = function(self)
                lib.showTextUI('[E] - Haus verlassen', {
                    position = "left-center",
                    icon = 'door-closed'
                })
            end,
            onExit = function(self)
                lib.hideTextUI()
            end,
            nearby = function(self)
                if IsControlJustReleased(0, 38) then -- E-Taste
                    CreateLeaveMenu()
                end
            end
        })
    end
end

-- Daten abrufen und initialisieren
CreateThread(function()
    local houses = lib.callback.await('GetAllHouses')
    if houses then createHousingMarkers(houses) end
end)

-- Event für Updates
RegisterNetEvent('housing:updateMarkers', function()
    local houses = lib.callback.await('GetAllHouses')
    if houses then createHousingMarkers(houses) end
end)

RegisterNetEvent('housing:restorePosition', function(position, houseId)
    -- Hole Hausdaten
    local houses = lib.callback.await('GetAllHouses')
    local houseData
    for _, house in ipairs(houses) do
        if house.id == houseId then
            houseData = house
            break
        end
    end

    if houseData then
        -- Aktualisiere currentHouseData
        currentHouseData = {
            enter = parseVec4(houseData.enter),
            leave = parseVec4(houseData.leave),
            id = houseData.id,
            price = houseData.price,
            charID = houseData.charId,
            closed = houseData.closed
        }
        -- Teleport mit Screenfade
        --DoScreenFadeOut(500)
        --while not IsScreenFadedOut() do Wait(10) end

        --SetEntityCoords(ped, position.x, position.y, position.z, false, false, false, false)
        --SetEntityHeading(ped, position.h or position.w or 0.0)

        --DoScreenFadeIn(500)
        --print("Position wiederhergestellt für Haus", houseId)
    else
        print("Fehler: Hausdaten nicht gefunden für ID", houseId)
    end
end)

CreateThread(function()
    -- Warte bis der Spieler existiert
    while not PlayerPedId() or not DoesEntityExist(PlayerPedId()) do
        Wait(500)
    end

    -- Warte zusätzlich 1 Sekunde für alle Ressourcen
    Wait(1000)

    -- Zustand abfragen
    TriggerServerEvent('housing:playerConnected')
end)


-- DrawMarker Schleife
--[[CreateThread(function()
    while true do
        Wait(0)
        if #housingMarkers > 0 then
            local playerCoords = GetEntityCoords(PlayerPedId())
            for _, house in ipairs(housingMarkers) do
                local enter = parseVec4(house.enter)
                local leave = parseVec4(house.leave)
                local color = house.charId == 0 and {0, 255, 0, 150} or {255, 0, 0, 150}

                DrawMarker(
                    23,
                    enter.x, enter.y, enter.z-0.95,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    0.4, 0.4, 0.4,
                    color[1], color[2], color[3], color[4],
                    false, true, 2, false, nil, nil, false
                )

                DrawMarker(
                    23,
                    leave.x, leave.y, leave.z-0.95,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    0.4, 0.4, 0.4,
                    color[1], color[2], color[3], color[4],
                    false, true, 2, false, nil, nil, false
                )
            end
        end
    end
end)]]
