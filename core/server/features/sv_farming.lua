
local Mor = require("server.sv_lib")

lib.callback.register('FarmItemAdd', function(source, item, count)
    local additem = Mor.Inv:add(source, item, count)
    return additem
end)

lib.callback.register('FarmCanCarry', function(source, item, count)
    local result = Mor.Inv:canCarry(source, item, count)
    return result
end)