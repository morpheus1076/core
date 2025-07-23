
local Mor = require("client.cl_lib")
local cfg = require("shared.cfg_core")

local grpBlips = {}

--local function GroupBlips()
--CreateThread(function()
local function CreateGroupBlips()
    local myGroup = lib.callback.await('playergroupblips', PlayerId())
    for _,k in ipairs(myGroup) do
        if k.color ~= 99 then
            local pGroup = k.label
            local gblip = Mor.Blip:new({
                coords = vec3(k.coords.x, k.coords.y, k.coords.z),
                sprite = 280,
                scale = 0.5,
                color = k.color,
                name = k.name,
                category = 14,
                catname = '~b~'..pGroup..'~w~',
            })
            table.insert(grpBlips, gblip)
        end
    end
end


local function StartGroupBlips()
    if cfg.useGroupBlips then
        while true do
            Wait(30000)
            if #grpBlips > 0 then
                for i=1, #grpBlips do
                    grpBlips[i]:remove()
                end
            end
            Wait(100)
            CreateGroupBlips()
        end
    end
end

--AddEventHandler('ox:playerLoaded', function(playerId, isNew)
    --StartGroupBlips()
--end)
StartGroupBlips()