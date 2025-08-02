
local Mor = require("client.cl_lib")
local Spots = require 'shared.cfg_farming'
local cfg = require("shared.cfg_core")

local zoneIds = {}
local aktivZone = nil
local objList = {}
local aktivProp = ''
local aktivItem = nil
local farmAktiv = false

local farmkey = lib.addKeybind({
        name = 'farmkey',
        description = 'Drücke E zum ernten/sammeln.',
        defaultKey = 'E',
        disabled = true,
        onPressed = function(self)
            if farmAktiv == false then
                StartFarming()
            end
        end
})

function ErnteEnde(amount, prop)
    local pedcoords = GetEntityCoords(PlayerPedId())
    local closeObj = GetClosestObjectOfType(pedcoords.x, pedcoords.y, pedcoords.z, 30, GetHashKey(prop), true, false, true)
    local giveitem = lib.callback.await('FarmItemAdd', source, aktivItem, amount)
    if giveitem then
        local EPointsAdd = Mor.EPoints:add({type = 'farm', amount = 0.1})
        if closeObj ~= 0 then
            SetEntityAsMissionEntity(closeObj, false, true)
            DeleteObject(closeObj)
        end
    else
        Mor.WarnLog('Fehler bei der Ernte')
    end
    anzahl = 0
end

function ObjSpawn()
    local zone = aktivZone
    for _,v in pairs (Spots) do
        for i=1, #v do
            if v[i].ident == zone then
                local reihen = v[i].reihen
                for k=1, #reihen do
                    aktivProp = v[i].objProp
                    local direction = reihen[k].ende - reihen[k].start
                    local distance = #(direction)
                    direction = direction / distance
                    local objectCount = math.floor(distance / (reihen[k].distance))
                    for j = 0, objectCount do
                        local spawnPos = reihen[k].start + (direction * (j * (reihen[k].distance)))
                        local success, spawnPoszz, normal = GetGroundZAndNormalFor_3dCoord(spawnPos.x, spawnPos.y, spawnPos.z)
                        local obj = Mor.Object:new({
                            model = v[i].objProp,
                            coords = vec3(spawnPos.x, spawnPos.y, spawnPoszz),
                        })
                        table.insert(objList, obj)
                    end
                end
            end
        end
    end
end

function onEnter(self)
    aktivZone = self.ident
    aktivItem = self.item
    farmkey:disable(false)
    ObjSpawn()
end

function onExit(self)
    aktivZone = nil
    aktivProp = ''
    aktivItem = nil
    farmkey:disable(true)
    for i=1, #objList do
        DeleteObject(objList[i].obj)
    end
    table.wipe(objList)
end

function StartFarming()
    farmAktiv = true
    local zone = aktivZone
    local prop = aktivProp
    local player = Ox.GetPlayer(PlayerId())
    local canCarry = true

    for _,v in pairs (Spots) do
        for i=1, #v do
            if v[i].ident == zone and farmAktiv then
                amount = math.random(v[i].minamount, v[i].maxamount)
                canCarry = lib.callback.await('FarmCanCarry', source, aktivItem, amount)
                if canCarry then
                    farmkey:disable(true)
                    Mor.Pbar:start({
                        label = 'Ernte / Sammeln',
                        duration = v[i].duration,
                        anim = v[i].anim,
                        animation = v[i].animation,
                        animdict = v[i].animdict,
                        scenario = v[i].scenario,
                    },
                    function(success)
                        -- Hier kommt der Code NACH der Progressbar
                        farmAktiv = false
                        farmkey:disable(false)

                        if success then
                            ClearPedTasksImmediately(PlayerPedId())
                            ErnteEnde(amount, aktivProp)
                        else
                            Mor.WarnLog("Abgebrochen oder fehlgeschlagen.")
                        end
                    end)
                else
                    Mor.Notify('~w~Deine Taschen sind schon ~r~VOLL~w~.')
                    farmAktiv = false
                    farmkey:disable(false)
                end
            end
        end
    end
end


local function CreateZones()
    if cfg.FarmingAktiv then
        for _,v in pairs (Spots) do
            for i=1, #v do
                local farmzone = lib.zones.poly({
                    points = v[i].zone,
                    thickness = v[i].thickness,
                    debug = v[i].debug,
                    ident = v[i].ident,
                    item = v[i].item,
                    onEnter = onEnter,
                    onExit = onExit,
                })
                table.insert(zoneIds, farmzone)
            end
        end
    end
end

CreateThread(function ()
    if cfg.FarmingBlipsAktiv then
        for _,v in pairs (Spots) do
            for i=1, #v do
                if v[i].noBlip == true then return end
                Mor.Blip:new({
                    coords = v[i].centercoords,
                    sprite = v[i].blipsprite,
                    color = v[i].blipcolor,
                    scale = v[i].blipscale,
                    name = v[i].blipname,
                    hidden = v[i].bliphidden,
                })
            end
        end
    end
end)

CreateZones()

--AddEventHandler('ox:playerLoaded', function(playerId, isNew)
--    CreateZones()
--end)
