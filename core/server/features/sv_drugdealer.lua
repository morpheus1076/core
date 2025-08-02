
local Mor = require("server.sv_lib")

RegisterNetEvent('drugdealer:AddItem', function(item, count)
    local src = source
    Mor.Inv:add(src, item, count)
    Wait(10)
    Mor.Inv:remove('einkauf_lager_01', item, count)
end)

RegisterNetEvent('drugdealer:RemoveItem', function(item, count)
    local src = source
    Mor.Inv:remove(src, item, count)
    Wait(10)
    Mor.Inv:add('einkauf_lager_01', item, count)
end)