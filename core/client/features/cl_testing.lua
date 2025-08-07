
lib.locale()
local Mor = require("client.cl_lib")

RegisterCommand("bucket", function()
    local player = Ox.GetPlayer(PlayerId())
    local StateBucket = lib.callback.await('testing:GetBucket')
    Mor.Notify('Aktueller Bucket: '..StateBucket)
end, false)



-- Abfrage aller vier Raäder, nach ihrem Zustand.
--[[lib.onCache('vehicle', function(vehicle, oldValue)
    if vehicle ~= false then
        CreateThread(function()
            while true do
                Wait(20000)
                local ped = PlayerPedId()
                if GetPedInVehicleSeat(vehicle, -1) == ped then
                    local wheelHealthVL = GetVehicleWheelHealth(vehicle, 0)
                    print("Vorderes linkes Rad:", wheelHealthVL)
                    local wheelHealthVR = GetVehicleWheelHealth(vehicle, 1)
                    print("Vorderes rechtes Rad:", wheelHealthVR)
                    local wheelHealthHL = GetVehicleWheelHealth(vehicle, 2)
                    print("Hinteres linkes Rad:", wheelHealthHL)
                    local wheelHealthHR = GetVehicleWheelHealth(vehicle, 3)
                    print("Hinteres rechtes Rad:", wheelHealthHR)
                else
                    print('Break')
                    break
                end
            end
        end)
    end
end)]]

--[[lib.onCache('weapon', function(weaponhash)
    print(json.encode(weaponhash))
end)]]


--Teleport mit Fahrzeuh am Casino in die Casino-Garage
local function TeleportVehicleWithOccupants(vehicle, coords, heading)
    -- Sicherstellen, dass das Fahrzeug existiert
    if not DoesEntityExist(vehicle) then
        print("Fahrzeug existiert nicht!")
        return false
    end

    -- Fahrzeug und Insassen einfrieren (optional, für weniger Probleme)
    FreezeEntityPosition(vehicle, true)

    -- Alle Insassen des Fahrzeugs holen
    local occupants = {}
    for i = -1, GetVehicleMaxNumberOfPassengers(vehicle) - 1 do
        local ped = GetPedInVehicleSeat(vehicle, i)
        if DoesEntityExist(ped) then
            table.insert(occupants, ped)
            FreezeEntityPosition(ped, true) -- Optional: Insassen einfrieren
        end
    end

    -- Fahrzeug teleportieren
    SetEntityCoords(vehicle, coords.x, coords.y, coords.z, false, false, false, false)
    SetEntityHeading(vehicle, heading or coords.w or 0.0)

    -- Kurze Verzögerung (optional)
    Citizen.Wait(100)

    -- Fahrzeug und Insassen wieder auftauen
    FreezeEntityPosition(vehicle, false)
    for _, ped in ipairs(occupants) do
        if DoesEntityExist(ped) then
            FreezeEntityPosition(ped, false)
        end
    end

    return true
end

local pointenter = lib.points.new({
    coords = vec3(1000.201, -55.348, 74.960),
    distance = 5,
})

local pointleave = lib.points.new({
    coords = vec3(2650.362, -339.766, -64.723),
    distance = 5,
})

lib.locale()

function pointenter:nearby()
    local pedInVeh = IsPedInAnyVehicle(PlayerPedId(), false)
    local destination = vec4(2650.788, -339.778, -65.135, 49.988)

    if pedInVeh then
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        lib.showTextUI(locale('Press [E] enter garage'), {
            position = 'left-center',
            icon = 'warehouse',
            iconColor = 'blue',
        })

        if self.currentDistance < 5 and IsControlJustReleased(0, 38) then
            if vehicle ~= 0 then
                DoScreenFadeOut(2000)
                while not IsScreenFadedOut() do
                    Wait(0)
                end
                TeleportVehicleWithOccupants(vehicle, destination)
                DoScreenFadeIn(2000)
                while not IsScreenFadedIn() do
                    Wait(0)
                end
            else
                print("Spieler ist in keinem Fahrzeug!")
            end
        end
    end
end

function pointenter:onExit()
    lib.hideTextUI()
end

function pointleave:nearby()
    local pedInVeh = IsPedInAnyVehicle(PlayerPedId(), false)
    local destination = vec4(996.059, -57.811, 74.348, 115.994)

    if pedInVeh then
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        lib.showTextUI(locale('Press [E] leave garage'), {
            position = 'left-center',
            icon = 'warehouse',
        })

        if self.currentDistance < 5 and IsControlJustReleased(0, 38) then
            if vehicle ~= 0 then
                DoScreenFadeOut(2000)
                while not IsScreenFadedOut() do
                    Wait(0)
                end
                TeleportVehicleWithOccupants(vehicle, destination)
                DoScreenFadeIn(2000)
                while not IsScreenFadedIn() do
                    Wait(0)
                end
            else
                print("Spieler ist in keinem Fahrzeug!")
            end
        end
    end
end

function pointleave:onExit()
    lib.hideTextUI()
end
