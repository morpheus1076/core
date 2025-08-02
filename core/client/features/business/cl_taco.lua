
local jobs = require("shared.cfg_jobs")
local Mor = require("client.cl_lib")
------------------------------

local npcAktiv = true

function TacoGrundlage()
    for _,v in pairs (jobs) do
        if v.id == 'thetacofarmer' and npcAktiv == true then
            local NpcCall = Mor.NPC:new({
                model = v.sellNpc,
                coords = vec3(v.sellNpcCoords.x,v.sellNpcCoords.y,v.sellNpcCoords.z),
                heading = v.sellNpcCoords.w,
                scenario = v.sellNpcScenario,
                targetable = true,
                targetoptions = {
                    label = 'Ansprechen',
                    name = 'taconpc',
                    distance = 2.5,
                    onSelect = function()
                        TriggerServerEvent('TacoStart')
                        Wait(200)
                        exports.ox_inventory:openInventory('shop', {type = 'thetacofarmer', id = 1})
                    end
                },
            })
            local ttfblip = Mor.Blip:new({
                coords = vec3(v.sellNpcCoords.x,v.sellNpcCoords.y,v.sellNpcCoords.z),
                name = 'The Taco Farmer',
                sprite = 52,
                color = 15,
                scale = 0.5,
            })
        else
            local npcPed = lib.getClosestPed(vec3(v.sellNpcCoords.x,v.sellNpcCoords.y,v.sellNpcCoords.z),1)
            if npcPed then
                DeleteEntity(npcPed)
            end
        end
    end
end

exports.ox_target:addSphereZone({
    coords = 	vec3(16.696901, -1598.220703, 29.476093),
    name = 'chefmenu',
    radius = 1.5,
    debug = false,
    options = {
        {
            label = 'NPC Steuern',
            name = 'onoffnpc',
            distance = 2.0,
            onSelect = function()
                if npcAktiv == true then
                    npcAktiv = false
                    TacoGrundlage()
                else
                    npcAktiv = true
                    TacoGrundlage()
                end
            end
        },
        {
            label = 'Geld einzahlen',
            name = 'ttfkasse',
            distance = 2.0,
            onSelect = function()
                local plymoney = exports.ox_inventory:GetItemCount('money')
                local input = lib.inputDialog('Dialog title', {
                    {type = 'number', label = 'Betrag', description = 'Betrag der eingezahlt werden soll.', icon = 'hashtag', min = 1, max = plymoney, default = plymoney},
                })
                local plyEinzahlung = lib.callback.await('ttfEinzahlung', PlayerId(), input)
                if plyEinzahlung == true then
                    Mor.Notify("~w~ Einzahlung ~g~erfolgreich getätigt.")
                end
            end
        },
    }
})

TacoGrundlage()

--[[
AddEventHandler('ox:playerLoaded', function(playerId, isNew)
    TacoGrundlage()
end)
]]
RegisterNetEvent('TacoStartServer', function()
    TacoGrundlage()
end)
