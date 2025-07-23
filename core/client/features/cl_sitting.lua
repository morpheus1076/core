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
        ClearPedTasks(ped)
        isSitting = false
    end,
    onReleased = function(self)
        KeyDisable()
    end
})

function KeyDisable()
    breaksit:disable(true)
end

local function SitOnChair(chair)
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

for i=1, #config do
    exports.ox_target:addModel(config[i].prop, {
        {
            name = 'sit_on_chair',
            icon = 'fa-chair',
            label = 'Hinsetzen',
            onSelect = function(data)
                SitOnChair(data.entity)
            end,
            showWarning = false
        }
    })
    Wait(200)
end
