
local Mor = require("client.cl_lib")

RegisterCommand("groupperms", function()
    local player = Ox.GetPlayer(PlayerId())
    Wait(50)
    local permissions = Ox.GetGroupPermissions('staat')
    print(json.encode(permissions))
    print(player)
    local plkey = player.get('fullname')
    print(plkey)
    if not plkey then
        local wert1 = 'Cyrus Bradshaw'
        TriggerServerEvent('testing:Werte', wert1)
        --player.set('fullname', 'Cyrus Bradshaw', false)
    end
end, false)

RegisterCommand("bucket", function()
    local player = Ox.GetPlayer(PlayerId())
    local StateBucket = lib.callback.await('testing:GetBucket')
    Mor.Notify('Aktueller Bucket: '..StateBucket)
end, false)

RegisterCommand("health50", function()
    SetEntityHealth(PlayerPedId(), 100)
end, false)


RegisterCommand("gethealth", function()
    local plyhealth = GetEntityHealth(PlayerPedId())
    Mor.Notify(plyhealth)
end, false)

RegisterNetEvent('cl_core:NpcSettings', function(entity)
    SetEntityAsMissionEntity(entity, true, true)
end)

lib.onCache('vehicle', function(vehicle, oldValue)
    if vehicle ~= false then
        CreateThread(function()
            while true do
                Wait(20000)
                local ped = PlayerPedId()
                if GetPedInVehicleSeat(vehicle, -1) == ped then
                    local wheelHealthVL = GetVehicleWheelHealth(vehicle, 0) -- 0 = erstes Rad
                    print("Vorderes linkes Rad:", wheelHealthVL)
                    local wheelHealthVR = GetVehicleWheelHealth(vehicle, 1) -- 0 = erstes Rad
                    print("Vorderes rechtes Rad:", wheelHealthVR)
                    local wheelHealthHL = GetVehicleWheelHealth(vehicle, 2) -- 0 = erstes Rad
                    print("Hinteres linkes Rad:", wheelHealthHL)
                    local wheelHealthHR = GetVehicleWheelHealth(vehicle, 3) -- 0 = erstes Rad
                    print("Hinteres rechtes Rad:", wheelHealthHR)
                else
                    print('Break')
                    break
                end
            end
        end)
    end
end)

--[[lib.onCache('weapon', function(weaponhash)
    print(json.encode(weaponhash))
end)]]