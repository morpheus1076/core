
--local Mor = require("@core.client.cl_lib")
local Mor = lib.load('client.cl_lib')
local Raub = require("shared.cfg_atmraub")

local cooldown = false

local function SmoothTurnToHeading(ped, targetHeading, duration)
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

local function LookAtTarget()
    local ped = PlayerPedId()
    local getPCoords = GetEntityCoords(PlayerPedId())
    local getObj1 = GetClosestObjectOfType(getPCoords.x,getPCoords.y,getPCoords.z, 1, 'prop_atm_01', false, false, false)
    local getObj2 = GetClosestObjectOfType(getPCoords.x,getPCoords.y,getPCoords.z, 1, 'prop_atm_02', false, false, false)
    local getObj3 = GetClosestObjectOfType(getPCoords.x,getPCoords.y,getPCoords.z, 1, 'prop_atm_03', false, false, false)
    local getObj4 = GetClosestObjectOfType(getPCoords.x,getPCoords.y,getPCoords.z, 1, 'prop_fleeca_atm', false, false, false)
    if getObj1 or getObj2 or getObj3 or getObj4 then
        local obj = getObj1 or getObj2 or getObj3 or getObj4
        local objCoords = GetEntityCoords(obj)
        local dx = objCoords.x - getPCoords.x
        local dy = objCoords.y - getPCoords.y
        local heading = math.deg(math.atan(dy, dx)) - 30.0
        if heading < 0 then heading = heading + 360.0 end
        SmoothTurnToHeading(ped, heading, 800) -- 800 ms Drehung
        Wait(850)
    end
end

local function AtmStart()
    if cooldown then
        Mor.Notify('~w~Derzeit ~r~nicht ~w~möglich. Wurde schon ausgeraubt.')
    else
        LookAtTarget()
        Mor.Pbar:start({
            label = ' ATM Raub läuft',
            duration = Raub.duration,
            anim = false,
            scenario = Raub.scenarion
        })
        Wait(Raub.duration +300)
        TriggerServerEvent('ATMRaubAuszahlung')
    end
end

RegisterNetEvent('ATMCooldown', function()
    cooldown = true
    Wait(60000*Raub.cooldown)
    cooldown = false
end)

exports.ox_target:addModel('prop_atm_01', {name = 'atmraub', label = 'ATM knacken', onSelect = function() AtmStart() end, distance = 2.0, items = 'blowpipe', icon = 'sack-dollar'})
exports.ox_target:addModel('prop_atm_02', {name = 'atmraub', label = 'ATM knacken', onSelect = function() AtmStart() end, distance = 2.0, items = 'blowpipe', icon = 'sack-dollar'})
exports.ox_target:addModel('prop_atm_03', {name = 'atmraub', label = 'ATM knacken', onSelect = function() AtmStart() end, distance = 2.0, items = 'blowpipe', icon = 'sack-dollar'})
exports.ox_target:addModel('prop_fleeca_atm', {name = 'atmraub', label = 'ATM knacken', onSelect = function() AtmStart() end, distance = 2.0, items = 'blowpipe', icon = 'sack-dollar'})
