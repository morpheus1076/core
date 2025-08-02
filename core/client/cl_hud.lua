
local speedmeter =  ""
local speedo = 0
local speedUnit = "KM/H" --KM/H oder MPH
local pausemenu = false
local seatBelt = 1

local function sendHUDUpdate()
    local job = {}
    local year, month, day, hour, minute = GetLocalTime()
    job = lib.callback.await('jobabfrage')
    pausemenu = IsPauseMenuActive()
    if job == nil or (type(job) == "table" and next(job) == nil) then return end
    for i = 1, #job do
        jobname = job[1]
        jobgrade = job[2]
    end

    if pausemenu == false then
        SendNUIMessage({
            action = "updateHUD",
            serverShort = "newv",
            serverFull = "Development",
            playerID = GetPlayerServerId(PlayerId()),
            playerCount = #GetActivePlayers(),
            date = string.format("%02d.%02d.%02d", day, month, year % 100),
            time = string.format("%02d:%02d", hour, minute),
            jobName = jobname or "Unbekannt",
            jobGrade = jobgrade or "Unbekannt",
        })
    else
        SendNUIMessage({
            action = "updateHUD",
            serverShort = "",
            serverFull = "",
            playerID = "",
            playerCount = "",
            date = "",
            time = "",
            jobName = "",
            jobGrade = "",
        })
    end
end

CreateThread(function()
    while true do
        Wait(5000)
        sendHUDUpdate()
    end
end)

AddEventHandler('ox:statusTick', function(statuses)
    local hungerLevel = statuses.hunger
    local thirstLevel = statuses.thirst
    SendNUIMessage({
        action = "updateStatus",
        hungerLevel = hungerLevel,
        thirstLevel = thirstLevel
    })

    local healthLevel = GetEntityHealth(PlayerPedId())
    local armourLevel = GetPedArmour(PlayerPedId())
    SendNUIMessage({
        action = "updateHAS",
        healthLevel = healthLevel,
        armourLevel = armourLevel,
        --staminaLevel = staminaLevel,
    })

    ShowHudComponentThisFrame(7)
    ShowHudComponentThisFrame(9)
    SetHudComponentSize(7, 0.481000, 0.032200)
    SetHudComponentSize(9, 0.381000, 0.022200)
    SetHudComponentPosition(7, -0.002000, -0.022000)
    SetHudComponentPosition(9, -0.002000, -0.008000)
    Wait(1000)
    if IsPedInAnyVehicle(PlayerPedId(), true) then
        ShowHudComponentThisFrame(6)
        SetHudComponentSize(6, 0.481000, 0.032200)
        SetHudComponentPosition(6, -0.002000, -0.052000)
    end

    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)

    if veh ~= 0 and GetPedInVehicleSeat(veh, -1) == ped then
        local plate = GetVehicleNumberPlateText(veh)
        local fuelLevel = GetVehicleFuelLevel(veh)
        SendNUIMessage({
            action = "updateFuel",
            fuelLevel = fuelLevel,
            seatBelt = seatBelt,
            plate = plate,
        })
    else
        SendNUIMessage({
            action = "updateFuel",
            fuelLevel = -1,
        })
    end
    if veh ~= 0 and GetPedInVehicleSeat(veh, -1) == ped then
        local speed = GetEntitySpeed(veh)
        if speedUnit == "KM/H" then
            speedo = math.floor(speed * 3.6)
        else
            speedo = math.floor(speed * 2.23694)
        end
        speedmeter = speedo .. ""
        SendNUIMessage({
            action = "updateSpeed",
            speed = speedmeter,
        })
    else
        speedmeter = ''
        SendNUIMessage({
            action = "updateSpeed",
            speed = speedmeter,
        })
    end
end)

RegisterNetEvent('SetSeatbelt')
AddEventHandler('SetSeatbelt', function(status)
    if status == 2 then
        seatBelt = 2 --green
    else
        seatBelt = 1 --red
    end
end)

local menuOpen = false

--lib.addKeybind({name = 'seitenmenu', description = 'Seiten-Menü nutzen', defaultKey = 'J', onPressed = function() Seitenmenue() end})

function Seitenmenue()
    menuOpen = not menuOpen
    local player = Ox.GetPlayer(PlayerId())
    local pgroups = player.getGroups()
    local job = player.getGroup(pgroups)
    pausemenu = IsPauseMenuActive()

    for i = 1, #job do
        jobname = job
    end
    SendNUIMessage({
        action = "seitenmenu",
        state = menuOpen,
        job = jobname,
    })
    SetNuiFocus(menuOpen, menuOpen)

    if not menuOpen then
        -- Tabs schließen und Fokus zurücksetzen
        SendNUIMessage({
            action = "closeTabs"
        })
        menuOpen = false
        SetNuiFocus(false, false)
    end
end

RegisterNUICallback('closeMenu', function()
    menuOpen = false
    SetNuiFocus(false, false)
end)

RegisterNUICallback('arrestPlayer', function()
    print("Arrest Player button pressed")
    -- Hier kannst du Logik für Verhaftungen einfügen
end)

RegisterNUICallback('issueTicket', function()
    print("Issue Ticket button pressed")
    -- Hier kannst du Logik für Strafzettel einfügen
end)

RegisterNetEvent('OnPlayerChangeAktivGroup', function()
    sendHUDUpdate()
end)

RegisterNUICallback('healPlayer', function()
    print("Heal Player button pressed")
    local player = Ox.GetPlayer(PlayerId())
    local tarplayer = math.floor(lib.getClosestPlayer(player.getCoords(), 3, true))
    local tarped = math.floor(GetPlayerPed(tarplayer))
    local maxh = GetPedMaxHealth(tarped)
    SetEntityHealth(tarped, maxh)
end)

RegisterNUICallback('revivePlayer', function()
    print("Revive Player button pressed")
    local player = Ox.GetPlayer(PlayerId())
    local tarplayer = lib.getClosestPlayer(player.getCoords(), 3, false)
    local tarped = math.floor(GetPlayerPed(tarplayer))
    local maxh = GetPedMaxHealth(tarped)
    SetEntityHealth(tarped, maxh)
end)

RegisterCommand('showGangHud', function()
    SendNUIMessage({
        action = 'ganghud'
    })
    SetNuiFocus(true, true)
end, false)

-- Gang-HUD deaktivieren
RegisterCommand('hideGangHud', function()
    SendNUIMessage({
        action = 'ganghudclose'
    })
    SetNuiFocus(false, false)
end, false)