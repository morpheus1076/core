local config = require 'shared.cfg_sitting'
local isSitting = false
local sitentities = {}

local breaksit = lib.addKeybind({
    name = 'breaksitting',
    description = 'drücke x um das Sitzen abzubrechen.',
    defaultKey = 'X',
    disabled = true,
    onPressed = function(self)
        local ped = PlayerPedId()
        ClearPedTasksImmediately(ped)
        isSitting = false
    end,
    onReleased = function(self)
        KeyDisable()
    end
})

function KeyDisable()
    breaksit:disable(true)
end

function SitOnChair(chair)
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then return end
    if isSitting then return end

    local model = GetEntityModel(chair)
    local entry = nil

    -- passenden Eintrag aus config suchen
    for _, prop in ipairs(config) do
        if model == GetHashKey(prop.prop) then
            entry = prop
            break
        end
    end

    if not entry then
        print('[Sitzen] Kein Konfigurationseintrag für: ' .. model)
        return
    end

    local chairHeading = GetEntityHeading(chair)
    local sitHeading = (chairHeading + 180.0) % 360.0
    local sitPos = GetOffsetFromEntityInWorldCoords(chair, entry.offsetX, entry.offsetY, entry.offsetZ)
    breaksit:disable(false)
    TaskGoStraightToCoord(ped, sitPos.x, sitPos.y, sitPos.z, 1.0, -1, sitHeading, 0.5)
    Wait(1500)

    TaskStartScenarioAtPosition(ped, entry.scenarion or "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER", sitPos.x, sitPos.y, sitPos.z, sitHeading, 0, true, true)
    isSitting = true

end

local function AddTargetToNearbyChairs()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local chairs = GetGamePool('CObject')

    for _, obj in ipairs(chairs) do
        local model = GetEntityModel(obj)
        for _, prop in ipairs(config) do
            if model == GetHashKey(prop.prop) and #(playerCoords - GetEntityCoords(obj)) < 5.0 then
                local chairEntity = exports.ox_target:addLocalEntity(obj, {
                    {
                        name = 'sit_on_chair'..model,
                        icon = 'fa-chair',
                        label = 'Hinsetzen',
                        onSelect = function(data)
                            SitOnChair(data.entity)
                        end
                    }
                })
                table.insert(sitentities, chairEntity)
                break
            end
        end
    end
end

local function TargetScan()
    while true do
        for i=1, #sitentities do
            exports.ox_target:removeEntity(sitentities[i], 'sit_on_chair')
        end
        chairs = {}
        AddTargetToNearbyChairs()
        Wait(10000)
    end
end

AddEventHandler('ox:playerLoaded', function(playerId, isNew)
    TargetScan()
end)
