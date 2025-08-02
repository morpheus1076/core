local Mor = require("client.cl_lib")

local raceCheckpoints = {
    vec3(1185.045, -2584.947, 36.427),
    vec3(1421.641, -2574.996, 47.581),
    vec3(1642.088, -2451.393, 86.601),
    vec3(1691.763, -2112.458, 106.638),
    vec3(1801.678, -1546.564, 112.966)
}

-- Race State
local currentCheckpoint = 0
local raceStarted = false
local startTime = 0
local bestLap = nil
local checkpointBlips = {}
local checkpointObjects = {}
local raceTimeout = 5 * 60 * 1000 -- 5 Minuten
local timeoutTimer = nil
local showRaceUI = false

-- DrawText UI für die Rennzeit
local function DrawRaceTime()
    if not raceStarted then return end

    local currentTime = GetGameTimer() - startTime
    local timeText = Mor.FormTime(currentTime)

    -- UI Position und Stil
    SetTextFont(7)
    SetTextScale(0.5, 0.5)
    SetTextColour(255, 255, 255, 255)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString("~b~Zeit: ~w~"..timeText)
    DrawText(0.50, 0.95)

    -- Bestzeit anzeigen, wenn vorhanden

end

-- UI Rendering Thread
CreateThread(function()
    while true do
        Wait(0)
        if showRaceUI then
            DrawRaceTime()
        end
    end
end)

-- Löscht alle Checkpoints/Blips
local function ClearAllCheckpoints()
    for _, blip in pairs(checkpointBlips) do
        RemoveBlip(blip)
    end
    for _, checkpoint in pairs(checkpointObjects) do
        DeleteCheckpoint(checkpoint)
    end
    checkpointBlips = {}
    checkpointObjects = {}
    SetGpsMultiRouteRender(false)
    showRaceUI = false
    ClearGpsMultiRoute()
    currentCheckpoint = 0
end

-- Erstellt den nächsten Checkpoint-Marker
local function CreateNextCheckpoint()
    if currentCheckpoint > #raceCheckpoints then return end

    local nextPoint = raceCheckpoints[currentCheckpoint]
    checkpointObjects[currentCheckpoint] = CreateCheckpoint(
        47, -- Pfeil-Checkpoint
        nextPoint.x, nextPoint.y, nextPoint.z - 1.5,
        nextPoint.x, nextPoint.y, nextPoint.z + 0.0,
        10.0, 246, 68, 165, 100, 0
    )
    SetBlipRoute(checkpointBlips[currentCheckpoint], true)
end

-- Initialisiert das Rennen
local function SetupRace()
    ClearAllCheckpoints()
    ClearGpsMultiRoute()
    StartGpsMultiRoute(49, false, true)

    for i, point in ipairs(raceCheckpoints) do
        checkpointBlips[i] = AddBlipForCoord(point.x, point.y, point.z)
        if i == #raceCheckpoints then
            SetBlipSprite(checkpointBlips[i], 309) -- Ziel-Checkpoint
        else
            SetBlipSprite(checkpointBlips[i], 501+i)
        end
        SetBlipColour(checkpointBlips[i], 48)
        SetBlipScale(checkpointBlips[i], 0.5)
        SetBlipHiddenOnLegend(checkpointBlips[i], true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("CP " .. i)
        EndTextCommandSetBlipName(checkpointBlips[i])
        AddPointToGpsCustomRoute(point.x, point.y, point.z)
    end

    currentCheckpoint = 1
    SetGpsMultiRouteRender(true)
    CreateNextCheckpoint()
end

-- Startet die Zeitmessung
local function StartRaceTimer()
    raceStarted = true
    startTime = GetGameTimer()
    showRaceUI = true
    StartRaceTimeout()
    Mor.ScFoTe('Zeitmessung gestartet!', 3000, 2)
end

-- Timeout-Logik
function StartRaceTimeout()
    if timeoutTimer then Citizen.InvokeNative(0x5AAB586FFEC0FD96, timeoutTimer) end
    timeoutTimer = SetTimeout(raceTimeout, function()
        if raceStarted then
            Mor.ScFoTe('Rennen abgebrochen (Timeout nach 5 Minuten)!', 5000, 5)
            EndRace(false)
        end
    end)
end

-- Beendet das Rennen
function EndRace(success)
    if not raceStarted and success then return end

    local finishTimeMs = success and (GetGameTimer() - startTime) or 0
    raceStarted = false
    showRaceUI = false

    if success then
        Mor.ScFoTe('Race beendet - Zeit: '..Mor.FormTime(finishTimeMs), 5000, 2)
        if not bestLap or finishTimeMs < bestLap then
            bestLap = finishTimeMs
        end
        if bestLap then
            Mor.Notify("~b~Neue Bestzeit: ~w~"..Mor.FormTime(bestLap))
        else
            Mor.Notify("~b~Aktuelle Bestzeit: ~w~"..Mor.FormTime(bestLap))
        end
    else
        Mor.ScFoTe('Race abgebrochen', 5000, 5)
        if bestLap then
            Mor.Notify("~b~Aktuelle Bestzeit: ~w~"..Mor.FormTime(bestLap))
        end
    end

    ClearAllCheckpoints()

    if timeoutTimer then
        Citizen.InvokeNative(0x5AAB586FFEC0FD96, timeoutTimer)
        timeoutTimer = nil
    end
end

-- Haupt-Thread (Checkpoint-Logik)
CreateThread(function()
    while true do
        Wait(500)
        if currentCheckpoint > 0 then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local currentPoint = raceCheckpoints[currentCheckpoint]

            if playerCoords then
                if #(playerCoords - currentPoint) < 15.0 then
                    PlaySoundFrontend(-1, "RACE_PLACED", "HUD_AWARDS")

                    if currentCheckpoint == 1 and not raceStarted then
                        StartRaceTimer()
                    end

                    currentCheckpoint = currentCheckpoint + 1

                    if currentCheckpoint > #raceCheckpoints then
                        EndRace(true)
                    else
                        CreateNextCheckpoint()
                    end
                end
            end
        end
    end
end)

-- Kommandos
RegisterCommand("startrace", function()
    if currentCheckpoint > 0 then return end
    SetupRace()
    Mor.ScFoTe('Rennen vorbereitet! Fahre zum ersten Checkpoint.', 5000, 3)
end, false)

RegisterCommand("stoprace", function()
    if currentCheckpoint >= 0 then
        EndRace(false)
    end
end, false)