
local Mor = {}

local Inv = {}
Inv.__index = Inv

function Inv:add(inv, item, count, metadata, slot)
    if not inv or not item or not count then return false end

    local canCarry = exports.ox_inventory:CanCarryItem(inv, item, count, metadata)
    --Notify('~r~Kein ~w~Platz mehr in Deinen Taschen')
    if not canCarry then return false end

    return exports.ox_inventory:AddItem(inv, item, count, metadata, slot)
end
function Inv:remove(inv, item, count, metadata, slot, ignoreTotal)
    if not inv or not item or not count then return false end

    return exports.ox_inventory:RemoveItem(inv, item, count, metadata, slot, ignoreTotal)
end
function Inv:canCarry(inv, item, count, metadata)
    if not inv or not item or not count then return false end
    return exports.ox_inventory:CanCarryItem(inv, item, count, metadata)
end

local Log = {}
Log.__index = Log

local logQueue = {}

function Log:add(type, message, ply1, ply2)
    if not type or not message then return end
    local player1 = ply1 or 'null'
    local player2 = ply2 or 'null'
    table.insert(logQueue, {
        type = type,
        message = message,
        charId1 = player1,
        charId2 = player2
    })
end
function Log:queue()
    local result = nil
    if #logQueue > 0 then
        for i = 1, #logQueue do
            local now = os.date('%Y-%m-%d %H:%M:%S')
            result = MySQL.insert.await('INSERT INTO `logs` (type, message, charId1, charId2, timestamp) VALUES (?,?,?,?,?) ',{
                logQueue[i].type, logQueue[i].message, logQueue[i].charId1, logQueue[i].charId2, now
            })
        end
        logQueue = {}
        if result then
            print('Logs eingefüht.')
        else
            print('keine Logs eingefüht.')
        end
    end
end
CreateThread(function()
    while true do
        Wait(60000*15)
        Log:queue()
    end
end)

-- Exportieren
exports('AddItem', function(...) return Inv:add(...) end)
exports('RemoveItem', function(...) return Inv:remove(...) end)
exports('CanCarry', function(...) return Inv:canCarry(...) end)

Mor.Inv = Inv
Mor.Log = Log

return Mor
