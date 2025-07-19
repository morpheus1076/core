
local Mor = require("client.cl_lib")
local cfg = require("shared.cfg_core")

local function GroupBlips()
    if cfg.useGroupBlips then
        while true do
            local myGroup = lib.callback.await('playergroupblips', PlayerId())
            if myGroup == nil or (type(myGroup) == "table" and next(myGroup) == nil) then
                Wait(10000)
            else
                local pGroup = myGroup.label

                if myGroup.color ~= 99 then
                    local gblip = Mor.Blip:new({
                        coords = vec3(myGroup.coords.x, myGroup.coords.y, myGroup.coords.z),
                        sprite = 280,
                        scale = 0.5,
                        color = myGroup.color,
                        name = myGroup.name,
                        category = 14,
                        catname = '~b~'..pGroup..'~w~',
                    })
                    Wait(30000)
                    gblip:remove()
                end
            end
        end
    end
end

AddEventHandler('ox:playerLoaded', function(playerId, isNew)
    GroupBlips()
end)