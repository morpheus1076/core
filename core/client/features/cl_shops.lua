
local Mor = require("client.cl_lib")
local Wirt = require("shared.cfg_wirtschaftssystem")
local Shops = require("shared.cfg_shops")

local function ShopsStart()
    for _,v in pairs(Shops) do
        local targ = v.targets
        for _,k in pairs (targ) do
            local pedmodel = k.ped
            local coords = k.loc
            local heading = k.heading
            local scenario = k.scenario
            Mor.NPC:new({
                model = pedmodel,
                coords = vec3(coords.x,coords.y,coords.z+1),
                heading = heading,
                scenario = scenario,
                targetable = true,
                targetoptions = {
                    label = 'Ansprechen',
                    name = 'liqnpc',
                    distance = 2.5,
                    onSelect = function()
                        TriggerServerEvent('CreateShops', v.type)
                        Wait(200)
                        exports.ox_inventory:openInventory('shop', {type = v.type})
                    end
                }
            })
            Mor.Blip:new({
                coords = coords,
                sprite = v.blip.id,
                color = v.blip.colour,
                scale = v.blip.scale,
                hidden = v.blip.hidden,
                name = v.name
            })
        end
    end
end

AddEventHandler('ox:playerLoaded', function(playerId, isNew)
    Wait(10000)
    ShopsStart()
end)