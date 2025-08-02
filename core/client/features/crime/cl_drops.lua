
lib.locale()
local Mor = require("client.cl_lib")

local dropObject = nil
local dfhash = DropConfig.dfhash
local ddhash = DropConfig.ddhash

RegisterNetEvent("drop:spawn")
AddEventHandler("drop:spawn", function(dropPos)
    if DoesEntityExist(dropObject) then
        DeleteObject(dropObject)
    end

    -- Fallschirm-Objekt erstellen
    dropObject = CreateObject(dfhash, dropPos.x, dropPos.y, dropPos.z + 70.0, true, false, false)
    SetEntityAsMissionEntity(dropObject, true, true)
    SetEntityDynamic(dropObject, true)
    FreezeEntityPosition(dropObject, false)

    local obj = dropObject
    local driftX = math.random(-15, 15) * 0.2 -- Kleine seitliche Bewegung
    local driftY = math.random(-15, 15) * 0.2
    local fallSpeed = -0.6 -- Langsame Sinkgeschwindigkeit
    SetEntityVelocity(obj, driftX, driftY, fallSpeed)

    fblip = AddBlipForEntity(obj)
            SetBlipSprite(fblip, 550)
            SetBlipColour(fblip, 1)
            SetBlipAsShortRange(fblip, true)
            SetBlipHiddenOnLegend(fblip, false)
            SetBlipScale(fblip, 0.9)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString('Frachtkiste abgeworfen')
            EndTextCommandSetBlipName(fblip)

            Mor.Notify('~y~Abwurf ~w~einer Frachtkiste....')

    CreateThread(function()
        while true do
            Wait(200)
            local objCoords = GetEntityCoords(obj)
            local newFallSpeed = GetEntityVelocity(obj).z - 0.01

            if newFallSpeed < -0.5 then newFallSpeed = -0.5 end

            SetEntityVelocity(obj, driftX, driftY, newFallSpeed)
            local objCoords = GetEntityCoords(dropObject)
            local isOnGround, groundZ = GetGroundZFor_3dCoord(objCoords.x, objCoords.y, objCoords.z, false)

            if isOnGround and math.abs(objCoords.z - groundZ) < 0.9 then
                local expprop = GetEntityCoords(dropObject)
                --AddExplosion(expprop.x, expprop.y, expprop.z, 5, 0, true, true, 1)
                AddExplosion(expprop.x, expprop.y, expprop.z, 20, 0, true, true, 1)
                local pos = GetEntityCoords(dropObject)
                local rot = GetEntityRotation(dropObject)
                DeleteObject(dropObject)
                dropObject = CreateObject(ddhash, pos.x, pos.y, pos.z, true, true, true)
                Wait(50)
                SetEntityDynamic(dropObject, true)
                Wait(200)
                FreezeEntityPosition(dropObject, false)
                local dropedObj = dropObject
                dblip = AddBlipForEntity(dropedObj)
                SetBlipSprite(dblip, 586)
                SetBlipColour(dblip, 1)
                SetBlipAsShortRange(dblip, true)
                SetBlipHiddenOnLegend(dblip, false)
                SetBlipScale(dblip, 0.6)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString('Frachtkiste gelandet')
                EndTextCommandSetBlipName(dblip)

                Mor.Notify('~w~Frachtkiste ~g~gelandet. ~w~( Drei Minuten bis zur ~r~Explosion~w~. ) ')
                TriggerServerEvent("drop:destroytimer")
                break
            end
        end
    end)
end)

RegisterNetEvent("drop:remove")
AddEventHandler("drop:remove", function()
    if DoesEntityExist(dropObject) then
        DeleteObject(dropObject)
        RemoveBlip(dblip)
        dropObject = nil
        Mor.Notify('~r~Drop ~w~wurde eingesammelt oder Zeit ist ~r~abgelaufen.')
    end
end)

RegisterNetEvent("drop:removeexp")
AddEventHandler("drop:removeexp", function()
    if DoesEntityExist(dropObject) then
        local expprop = GetEntityCoords(dropObject)
        DeleteObject(dropObject)
        AddExplosion(expprop.x, expprop.y, expprop.z, 50, 0, true, false, 1)
        RemoveBlip(dblip)
        dropObject = nil
        Mor.Notify('~r~Drop ~w~wurde eingesammelt oder Zeit ist ~r~abgelaufen.')
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        if DoesEntityExist(dropObject) then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local dropCoords = GetEntityCoords(dropObject)

            -- Falls der Spieler nah am Drop ist
            if #(playerCoords - dropCoords) < 2.0 then
                DrawText3D(dropCoords.x, dropCoords.y, dropCoords.z, "[E] Aufheben")
                if IsControlJustReleased(0, 38) then -- Taste "E"
                    TriggerServerEvent("drop:collected") -- Sende an Server
                end
            end
        end
    end
end)

-- Funktion für 3D-Text
function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end
