
local Mor = require("@core.server.sv_lib")
local Raub = require("shared.cfg_atmraub")

RegisterNetEvent('ATMRaubAuszahlung', function()
    local src = source
    local amount = math.random(Raub.minamount,Raub.maxamount)
    Mor.Inv:add(src, Raub.item, amount)
    Mor.Inv:remove(src, Raub.needed, 1)
    TriggerClientEvent('ATMCooldown', src)
end)