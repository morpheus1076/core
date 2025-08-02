
local Mor = require("client.cl_lib")

local function smoothTurnToHeading(ped, targetHeading, duration)
    local currentHeading = GetEntityHeading(ped)
    local steps = 30
    local stepTime = duration / steps

    local diff = (targetHeading - currentHeading + 360.0) % 360.0
    if diff > 180.0 then diff = diff - 360.0 end
    local stepAmount = diff / steps

    CreateThread(function()
        for i = 1, steps do
            currentHeading = currentHeading + stepAmount
            SetEntityHeading(ped, currentHeading % 360.0)
            Wait(stepTime)
        end
    end)
end

local function PMLockPick()
    local ped = PlayerPedId()
    local getPCoords = GetEntityCoords(PlayerPedId())
    local getObj1 = GetClosestObjectOfType(getPCoords.x,getPCoords.y,getPCoords.z, 1, 'prop_parknmeter_01', false, false, false)
    local getObj2 = GetClosestObjectOfType(getPCoords.x,getPCoords.y,getPCoords.z, 1, 'prop_parknmeter_02', false, false, false)
    if getObj1 or getObj2 then
        local obj = getObj1 or getObj2
        local objCoords = GetEntityCoords(obj)
        local dx = objCoords.x - getPCoords.x
        local dy = objCoords.y - getPCoords.y
        local heading = math.deg(math.atan2(dy, dx)) - 90.0
        if heading < 0 then heading = heading + 360.0 end

        smoothTurnToHeading(ped, heading, 800) -- 800 ms Drehung
        Wait(850)
        Mor.Pbar:start({
            label = 'Parkuhr knacken ...',
            duration = 8000,
            anim = false,
            scenario = 'PROP_HUMAN_PARKING_METER',
        })
        Wait(8000)
        local isRunning = false
        local chance = math.random(1,9)
        local amount = math.random(5,20)
        if chance <= 5 and isRunning == false then
            isRunning = true
            local gewinn = lib.callback.await('littleCrime:GiveItem', source, 'money', amount)
            ClearPedTasksImmediately(PlayerPedId())
            if gewinn then
                Mor.Notify('Glückwunsch, du hast es ~g~geschafft~w~.')
            else
                Mor.Notify('Matrixfehler')
            end
            isRunning = false
        elseif chance >=4 and isRunning == false then
            isRunning = true
            local verlust = lib.callback.await('littleCrime:RemoveItem', source, 'defklammer', 1)
            if verlust then
                Mor.Notify('~y~Dein Unvermögen hat gesiegt.')
            else
                Mor.Notify('Matrixfehler')
            end
            isRunning = false
        end
    end
end

exports.ox_target:addModel('prop_parknmeter_01', {name = 'parkmeterlockpick', label = 'Knacken', onSelect = function() PMLockPick() end, distance = 2.0, items = 'defklammer'})
exports.ox_target:addModel('prop_parknmeter_02', {name = 'parkmeterlockpick', label = 'Knacken', onSelect = function() PMLockPick() end, distance = 2.0, items = 'defklammer'})
