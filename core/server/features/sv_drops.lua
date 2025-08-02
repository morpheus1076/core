
local Mor = require("server.sv_lib")

local dfhash = DropConfig.dfhash
local ddhash = DropConfig.ddhash
local delay

local dropPositions = DropConfig.Drop

CreateThread(function()
    if cfg_feat.drops then
        while true do
            delay = math.random(30, 120) * 60000
            Wait(delay)
            local randomIndex = math.random(1, #dropPositions)
            local dropPos = dropPositions[randomIndex]
            TriggerClientEvent("drop:spawn", -1, dropPos)
        end
    end
end)

RegisterServerEvent("drop:collected")
AddEventHandler("drop:collected", function()
    local src = source
    local amount = math.random(3100,5200)
    Mor.Notify('eingesammelt')
    exports.ox_inventory:AddItem(src, 'black_money', amount)
    TriggerClientEvent("drop:remove", -1)
end)

RegisterServerEvent("drop:destroytimer")
AddEventHandler("drop:destroytimer", function()
    lib.timer((10*60000),
    function()
        TriggerClientEvent("drop:removeexp", -1)
        Mor.Notify('Frachtkiste wurde ~r~zerstört.')
    end, true)
end)

--[[]
local obj
local dropedObj
local dropBlip
local dropprop = DropConfig.Prop
local drophash = DropConfig.Hash
local randomdropNum = 0

function DropSpawn()

    obj = CreateObjectNoOffset(drophash, -1337.844, -3045.512, 160.159, true, false, false)
    --SetEntityAsMissionEntity(obj, true, true)
    --SetEntityDynamic(obj, true)       -- Lässt das Objekt physikalisch reagieren
    FreezeEntityPosition(obj, false)  -- Falls das Objekt sonst festhängt
    fblip = AddBlipForEntity(obj)
            SetBlipSprite(fblip, 550)
            --SetBlipColour(fblip, 9)
            --SetBlipAsShortRange(fblip, true)
            --SetBlipHiddenOnLegend(fblip, false)
            --SetBlipScale(fblip, 0.5)
            --BeginTextCommandSetBlipName("STRING")
            --AddTextComponentString('Air Drop landet')
            --EndTextCommandSetBlipName(fblip)

    local driftX = math.random(-15, 15) * 0.2 -- Kleine seitliche Bewegung
    local driftY = math.random(-15, 15) * 0.2
    local fallSpeed = -0.6 -- Langsame Sinkgeschwindigkeit
    SetEntityVelocity(obj, driftX, driftY, fallSpeed)

    --Mor.Notify('Drop gestartet')


    while true do
        Wait(200)

        local objCoords = GetEntityCoords(obj)
        local newFallSpeed = GetEntityVelocity(obj).z - 0.01 -- Verlangsamt den Fall schrittweise

        -- Begrenzung der Geschwindigkeit (nicht zu schnell)
        if newFallSpeed < -0.5 then newFallSpeed = -0.5 end

        -- Setze neue Geschwindigkeit
        SetEntityVelocity(obj, driftX, driftY, newFallSpeed)

        local coords = GetEntityCoords(obj)
        local isOnGround, groundZ = GetGroundZFor_3dCoord(coords.x,coords.y,coords.z, false)
        local objZ = GetEntityCoords(obj).z

        if isOnGround and math.abs(objZ - groundZ) < 0.5 then
            Mor.Notify('on Ground')
            RemoveBlip(fblip)
            local pos = GetEntityCoords(obj)
            local rot = GetEntityRotation(obj)
            DeleteObject(obj)
            Wait(100)
            dropedObj = CreateObjectNoOffset(0xCC8478D8, pos.x, pos.y, pos.z, true, false, false)
            Wait(300)
            SetEntityDynamic(dropedObj, true)
            Wait(300)
            FreezeEntityPosition(dropedObj, true)

            dblip = AddBlipForEntity(dropedObj)
            SetBlipSprite(dblip, 586)
            SetBlipColour(dblip, 1)
            SetBlipAsShortRange(dblip, true)
            SetBlipHiddenOnLegend(blip, false)
            SetBlipScale(dblip, 0.5)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString('Air Drop gelandet')
            EndTextCommandSetBlipName(dblip)
            DropMenu(dropedObj)
            break
        end
    end
end

function DropMenu(ente)
    Wait(3000)
    local options = {
        label = 'Airdrop',
        name = 'airdrop',
        distance = 2,
        onSelect = function()
            DeleteEntity(ente)
            TriggerServerEvent('AddDropInventory', source)
        end
    }
    exports.ox_target:addLocalEntity(ente, options)
end

RegisterNetEvent('DropCommand', function()
    DropSpawn()
end)

RegisterNetEvent('AddDropInventory', function()
    local src = source
    exports.ox_inventory:AddItem(src, 'black_money', 5000)
end)]]