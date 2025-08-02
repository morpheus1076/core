
lib.locale()
local Mor = require("client.cl_lib")

local pause = 500

local spawnPoint = vector4(-127.2602, 6476.1436, 31.4685, 136.5271) -- Fahrzeug Spawn-Koordinaten (x, y, z, heading)
local waypoints = { -- Liste der Punkte mit Koordinaten und Heading
    {coords = vec3(2587.469, 3089.006, 46.466), heading = 133.296, duration = 500},
    {coords = vec3(1208.713, 2685.248, 37.711), heading = 89.875, duration = 500},
    {coords = vector3(1183.3915, 2690.4817, 37.7805), heading = 84.9796, duration = 25000},
    {coords = vector3(-1219.0105, -315.0755, 37.7044), heading = 295.9811, duration = 25000},
    {coords = vector3(-342.0731, -28.3638, 47.6045), heading = 250.6661, duration = 25000},
    {coords = vector3(221.9472, 226.6069, 105.5156), heading = 343.9855, duration = 25000}
}
local vehicleModel = "stockade" -- Fahrzeugmodell
local pedModel = "MP_M_SecuroGuard_01" -- KI-Ped Modell
local pedModel2 = "MP_M_SecuroGuard_01" -- KI-Ped Modell

local currentWaypoint = 1
local vehicle = nil
local ped = nil
local ped2 = nil
local area = nil or "unbekannt"
local vehicleBlip = nil -- Blip-Referenz

-- Funktion, um ein Fahrzeug zu spawnen
function SpawnVehicle()
    -- Fahrzeugmodell laden
    RequestModel(vehicleModel)
    while not HasModelLoaded(vehicleModel) do
        Wait(0)
    end

    -- Fahrzeug erstellen
    vehicle = CreateVehicle(GetHashKey(vehicleModel), spawnPoint.x, spawnPoint.y, spawnPoint.z, spawnPoint.w, true, false)
    SetVehicleOnGroundProperly(vehicle)
    SetVehicleDoorsLocked(vehicle, 3) -- Türen nicht abschließen
    SetVehicleUndriveable(vehicle, false) -- Fahrzeug fahrbar machen

    -- Blip erstellen
    CreateVehicleBlip(vehicle)
end

-- Funktion, um ein KI-Ped zu erstellen
function spawnPed()
    -- Ped-Modell laden
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(0)
    end

    -- Ped im Fahrzeug platzieren
    ped = CreatePedInsideVehicle(vehicle, 4, GetHashKey(pedModel), -1, true, false)
    ped2 = CreatePedInsideVehicle(vehicle, 4, GetHashKey(pedModel2), 0, true, false)
end

-- Funktion, um das Fahrzeug zum nächsten Wegpunkt fahren zu lassen
function DriveToNextWaypoint()
    if currentWaypoint <= #waypoints then
        pause = 500
        local waypoint = waypoints[currentWaypoint]
        local destination = waypoint.coords
        local heading = waypoint.heading or 0.0
        pause = waypoint.duration
        Wait(pause)
        TaskVehicleDriveToCoordLongrange(
            ped, -- KI-Ped
            vehicle, -- Fahrzeug
            destination.x, destination.y, destination.z, -- Zielkoordinaten
            20.0, -- Geschwindigkeit
            786603, -- Fahrstil
            1.0 -- Min. Abstand zu Hindernissen
        )
    else
        deleteVehicleAndPed()
    end
end

-- Funktion, um Fahrzeug und Ped zu löschen
function deleteVehicleAndPed()
    Wait(20000)
    if DoesEntityExist(ped) then
        DeleteEntity(ped)
    end
    if DoesEntityExist(ped2) then
        DeleteEntity(ped2)
    end
    if DoesEntityExist(vehicle) then
        DeleteEntity(vehicle)
    end
    if DoesBlipExist(vehicleBlip) then
        RemoveBlip(vehicleBlip)
    end
end

-- Funktion, um einen Blip für das Fahrzeug zu erstellen
function CreateVehicleBlip(vehicle)
    if DoesEntityExist(vehicle) then
        vehicleBlip = AddBlipForEntity(vehicle)
        SetBlipSprite(vehicleBlip, 67) -- Blip-Symbol (225 = Auto)
        SetBlipColour(vehicleBlip, 3) -- Blip-Farbe (3 = Blau)
        SetBlipScale(vehicleBlip, 0.5) -- Blip-Größe
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Geldtransporter")
        EndTextCommandSetBlipName(vehicleBlip)
    end
end

function CreateRobberyVehicleBlip(vehicle)
    if DoesEntityExist(vehicle) then
        vehicleBlip = AddBlipForEntity(vehicle)
        SetBlipSprite(vehicleBlip, 42) -- Blip-Symbol (225 = Auto)
        SetBlipColour(vehicleBlip, 1) -- Blip-Farbe (3 = Blau)
        SetBlipScale(vehicleBlip, 0.5) -- Blip-Größe
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Geldtransporter")
        EndTextCommandSetBlipName(vehicleBlip)
    end
end

-- Überwachung des Wegpunktstatus
CreateThread(function()
    while true do
        Wait(1000)
        if currentWaypoint <= #waypoints and vehicle ~= nil and ped ~= nil then
            local waypoint = waypoints[currentWaypoint]
            local destination = waypoint.coords
            local heading = waypoint.heading or 0.0
            local vehicleCoords = GetEntityCoords(vehicle)

            -- Prüfen, ob der Wegpunkt erreicht wurde
            if #(vehicleCoords - destination) < 10.0 then

                -- Fahrzeug Heading setzen
                SetEntityHeading(vehicle, heading)

                -- Zum nächsten Wegpunkt wechseln
                currentWaypoint = currentWaypoint + 1
                DriveToNextWaypoint()
            end
        end
    end
end)

-- Definiere die Fahrzeugklasse und andere Parameter
local transportVehicleModel = GetHashKey("stockade") -- Geldtransporter-Modell
local interactionDistance = 5.0 -- Maximale Distanz zum Interagieren
local actionKey = 38 -- Standardtaste "E"

-- Animation Dict und Name
local animationDict = "mini@repair" -- Animation-Set
local animationName = "fixing_a_ped" -- Animation
local scenarioWelding = "WORLD_HUMAN_WELDING" -- Schweiß-Szenario
local scenarioCollectingMoney = "PROP_HUMAN_BUM_BIN" -- Geld einsammeln

-- Funktion: Zeigt den HelpText an
local function ShowHelpText(text)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

-- Hauptthread
CreateThread(function()
    while true do
        Wait(0) -- Ständig prüfen

        -- Spielerped und Position
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        -- Überprüfe, ob der Spieler in der Nähe eines Geldtransporters ist
        local nearbyVehicle = nil
        local vehicles = GetGamePool("CVehicle")
        for _, vehicle in pairs(vehicles) do
            if DoesEntityExist(vehicle) and GetEntityModel(vehicle) == transportVehicleModel then
                local vehicleCoords = GetEntityCoords(vehicle)
                if #(playerCoords - vehicleCoords) < interactionDistance then
                    nearbyVehicle = vehicle
                    break
                end
            end
        end

        -- Wenn ein passendes Fahrzeug in der Nähe ist
        if nearbyVehicle and not IsPedInAnyVehicle(playerPed, false) then
            ShowHelpText("Drücke ~INPUT_CONTEXT~ um den Geldtransporter zu knacken.") -- HelpText anzeigen
            local tdata = {title = '~r~Geldtransporter', subtitle = "~r~Überfall", text = '~w~Drücke E um den Geldtransporter zu überfallen.', duration = 0.2}
            TriggerEvent('PostFeed', tdata)

            -- Warte auf Tastendruck (E)
            if IsControlJustReleased(0, actionKey) then
                -- Spieler zur Rückseite des Fahrzeugs bewegen
                local vehicleCoords = GetEntityCoords(nearbyVehicle)
                local rearCoords = GetOffsetFromEntityInWorldCoords(nearbyVehicle, 0.0, -4.4, 0.0) -- Hinteres Ende des Fahrzeugs
                TaskGoStraightToCoord(playerPed, rearCoords.x, rearCoords.y, rearCoords.z, 1.0, 5000, GetEntityHeading(nearbyVehicle), 0.1)
                Wait(2000) -- Warte, bis der Spieler angekommen ist
                TriggerServerEvent('jobcheck', source)
                CreateRobberyVehicleBlip(nearbyVehicle)
                TaskLeaveVehicle(ped, nearbyVehicle, 0)

                Wait(2000)

                -- Ped weglaufen lassen
                local playerPed = PlayerPedId() -- Spielerped (Referenz für Flucht)
                TaskSmartFleePed(ped, playerPed, 9000.0, 180000, false, false) -- Ped flieht 100 Meter weit
                SetPedKeepTask(ped, true) -- Ped behält die Flucht-Task bei
                Wait(5000)
                if DoesEntityExist(ped) then
                    DeleteEntity(ped)
                end

                -- Spieler zum Fahrzeug ausrichten
                local vehicleHeading = GetEntityHeading(nearbyVehicle) -- Richtung des Fahrzeugs
                SetEntityHeading(playerPed, vehicleHeading) -- Spieler ausrichten

                local propModel = "prop_weld_torch"
                RequestModel(propModel)
                while not HasModelLoaded(propModel) do
                    Wait(10)
                end

                local playerCoords = GetEntityCoords(playerPed)
                SetVehicleUndriveable(nearbyVehicle, true)
                TaskStartScenarioAtPosition(playerPed, scenarioWelding, playerCoords.x, playerCoords.y, playerCoords.z +0.5, vehicleHeading, 0, true, false)

                Wait(60000)

                ClearPedTasksImmediately(playerPed)

                SetVehicleEngineOn(nearbyVehicle, false, true, true)
                SetVehicleUndriveable(nearbyVehicle, true)

                SetVehicleDoorOpen(nearbyVehicle, 2, false, false)
                SetVehicleDoorOpen(nearbyVehicle, 3, false, false)

                Wait(1000)
                TaskStartScenarioAtPosition(playerPed, scenarioCollectingMoney, playerCoords.x, playerCoords.y, playerCoords.z+ 0.05, vehicleHeading, 0, true, false)
                Wait(20000)
                ClearPedTasksImmediately(playerPed)
                local amount = math.random(1000,5200)
                local args = {item = 'black_money', count = amount}
                local adata = {title = '~r~Geldtransporter', subtitle = "~r~Überfall", text = '~w~Überfall ~g~erfolgreich. ~r~'..amount..'$', duration = 0.4}
                TriggerEvent('PostFeed', adata)
                TriggerServerEvent('AddItem', args)

                SetVehicleDoorShut(nearbyVehicle, 2, false)
                SetVehicleDoorShut(nearbyVehicle, 3, false)
                SetVehicleDoorsLocked(nearbyVehicle, 1)
                deleteVehicleAndPed()
            end
        else
            Wait(1000)
        end
    end
end)

RegisterNetEvent('sendHelpMessageToPlayer')
AddEventHandler('sendHelpMessageToPlayer', function(message)
    -- Zeige die Nachricht im Spiel an
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    area = GetNameOfZone(playerCoords.x, playerCoords.y, playerCoords.z)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName("~w~"..message.." ~r~"..area.."~w~ statt.")
    EndTextCommandThefeedPostMessagetext("CHAR_DEFAULT", "CHAR_DEFAULT", true, 1, "~r~Überfall", "~r~Achtung")
end)

-- Befehl, um das Fahrzeug zu spawnen und die Fahrt zu starten
RegisterCommand("geldtransport", function()
    currentWaypoint = 1 -- Wegpunkte zurücksetzen
    pause = 500
    SpawnVehicle()
    spawnPed()
    DriveToNextWaypoint()
end,false)
