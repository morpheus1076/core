-- Zentrale Tabelle für require
local Mor = {}

local Blip = {}
Blip.__index = Blip
local blipRegistry = {}

function Blip:new(data)
    local self = setmetatable({}, Blip)
    self.coords = data.coords or vector3(0.0, 0.0, 0.0)
    self.sprite = data.sprite or 1
    self.color = data.color or 0
    self.scale = data.scale or 0.5
    self.name = data.name or ""
    self.shortRange = data.shortRange ~= false
    self.category = data.category
    self.catname = data.catname
    self.hidden = data.hidden or false
    self.flash = data.flash or false
    self.playername = data.playername or false
    self:generate()
    blipRegistry[self.id] = self
    return self
end

function Blip:generate()
    self.id = AddBlipForCoord(self.coords.x, self.coords.y, self.coords.z)
    SetBlipSprite(self.id, self.sprite)
    SetBlipColour(self.id, self.color)
    SetBlipScale(self.id, self.scale)
    SetBlipAsShortRange(self.id, self.shortRange)
    SetBlipDisplay(self.id, 2)
    SetBlipHiddenOnLegend(self.id, self.hidden)
    SetBlipFlashes(self.id, self.flash)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(self.name)
    EndTextCommandSetBlipName(self.id)
    if self.category then
        AddTextEntry("BLIP_CAT_" .. self.category, self.catname)
        SetBlipCategory(self.id, self.category)
    end
    if self.playername then
        DisplayPlayerNameTagsOnBlips(self.playername)
    end
end

function Blip:remove()
    if self.id and DoesBlipExist(self.id) then
        RemoveBlip(self.id)
        blipRegistry[self.id] = nil
        self.id = nil
    end
end

------------------------------------------------------------------------------

local Pbar = {}
Pbar.__index = Pbar

function Pbar:start(data, cb)
    local self = setmetatable({}, Pbar)
    self.label = data.label
    self.duration = data.duration
    self.anim = data.anim or false
    self.animation = data.animation or ''
    self.animdict = data.animdict or ''
    self.scenario = data.scenario or ''
    self.blockInput = true

    if self.anim == false then
        RemoveAllPedWeapons(PlayerPedId(), false)
        TaskStartScenarioInPlace(PlayerPedId(), self.scenario, self.duration, true)
    else
        RequestAnimDict(self.animation)
        while not HasAnimDictLoaded(self.animation) do Wait(10) end
        TaskPlayAnim(PlayerPedId(), self.animation, self.animdict, 2.0, -2.0, self.duration, 49, 0, false, false, false)
    end

    SetNuiFocus(false, false)
    SendNuiMessage(json.encode({
        type = 'showProgressbar',
        text = self.label,
        duration = self.duration
    }))

    CreateThread(function()
        local endTime = GetGameTimer() + self.duration
        while GetGameTimer() < endTime and self.blockInput do
            -- Sperre alle Inputs
            for i = 0, 359 do
                if i ~= 1 and i ~= 2 then -- Ausnahme: Maussteuerung (LOOK_LR und LOOK_UD)
                    DisableControlAction(0, i, true)
                    DisableControlAction(1, i, true)
                    DisableControlAction(2, i, true)
                end
            end
            Wait(0)
        end
    end)

    RegisterNuiCallback('progressbarFinished', function(nuiData, nuiCb)
        self.blockInput = false
        ClearPedTasksImmediately(PlayerPedId())
        SetNuiFocus(false, false)
        if cb then cb(nuiData.success) end
        nuiCb({})
    end)
end


------------------------------------------------------------------------------

local PGroups = {}
Pbar.__index = PGroups

function PGroups:get(charId)
    local self = setmetatable({}, PGroups)
    local activGroupLabels = {}
    self.GroupLabels = {}
    self.AllPlayerGroups = lib.callback.await('morlib:GetAllGroups', charId)
    Wait(100)
    for _,v in pairs (self.AllPlayerGroups) do
        if v.isActive == true then
            activGroupLabels = lib.callback.await('morlib:GetLabels', source, v.name, v.grade)
        end
        if v.name ~= 'arbeitslos' then
            local groupLabels = lib.callback.await('morlib:GetLabels', source,  v.name, v.grade)
            table.insert(self.GroupLabels, groupLabels)
        end
        Wait(20)
    end
    self.AktivGroup = activGroupLabels
    return self
end
function PGroups:set(data)
    self.charId = data.charId
    self.group = data.group
    self.rank = data.rank
    local success = lib.callback.await('morlib:SetPlayerGroup', source, self.charId, self.group, self.rank)
    if success then
        Mor.Notify('~w~Gruppe ~g~gesetzt.')
    else
        Mor.Notify('~r~Fehler ~w~beim Gruppe setzen.')
    end
    return self
end

------------------------------------------------------------------------------

local NPC = {}
NPC.__index = NPC
local npcRegistry = {}

function NPC:new(data)
    local self = setmetatable({}, NPC)
    self.model = data.model or 'CSB_Car3guy1'
    self.coords = data.coords or vec3(0.0, 0.0, 0.0)
    self.heading = data.heading or 0.0
    self.scenario = data.scenario or 'WORLD_HUMAN_STAND_IMPATIENT'
    self.targetable = data.targetable or false
    self.targetoptions = data.targetoptions or {}
    self.freeze = data.freeze or true
    self.invincible = data.invincible or true
    self.blockevents = data.blockevents or true
    self:spawn()
    npcRegistry[self.ped] = self
    return self
end

function NPC:spawn()
    RequestModel(self.model)
    while not HasModelLoaded(self.model) do Wait(0) end

    self.ped = CreatePed(0, self.model, self.coords.x, self.coords.y, self.coords.z-1.00, self.heading, false, true)
    TaskStartScenarioInPlace(self.ped, self.scenario, -1, true)
    SetEntityAsMissionEntity(self.ped, true, true)
    if self.freeze then FreezeEntityPosition(self.ped, self.freeze) end
    if self.invincible then SetEntityInvincible(self.ped, self.invincible) end
    if self.blockevents then SetBlockingOfNonTemporaryEvents(self.ped, self.blockevents) end
    if self.targetable and next(self.targetoptions or {}) then
        exports.ox_target:addLocalEntity(self.ped, self.targetoptions)
    end
end

function NPC:remove()
    if self.ped and DoesEntityExist(self.ped) then
        DeleteEntity(self.ped)
        npcRegistry[self.ped] = nil
        self.ped = nil
    end
end

------------------------------------------------------------------------------

local Object = {}
Object.__index = Object
local objRegistry = {}

function Object:new(data)
    local self = setmetatable({}, Object)
    self.model = data.model
    self.coords = data.coords
    self.heading = data.heading or 0.0
    self.freeze = data.freeze or true
    self.placeOnGround = data.placeOnGround or false
    self.autoz = data.autoz or true
    self:spawn()
    objRegistry[self.obj] = self
    return self
end

function Object:spawn()
    RequestModel(self.model)
    while not HasModelLoaded(self.model) do Wait(0) end
    if self.autoz then
        local success, newZ, normal = GetGroundZAndNormalFor_3dCoord(self.coords.x, self.coords.y, self.coords.z)
        self.obj = CreateObjectNoOffset(self.model, self.coords.x, self.coords.y, newZ, true, true, true)
    else
        self.obj = CreateObjectNoOffset(self.model, self.coords.x, self.coords.y, self.coords.z, true, true, true)
    end
    if self.placeOnGround then PlaceObjectOnGroundProperly(self.obj) end
    if self.freeze then FreezeEntityPosition(self.obj, self.freeze) end
    if self.heading then SetEntityHeading(self.obj, self.heading) end
end

function Object:remove()
    if self.obj and DoesEntityExist(self.obj) then
        DeleteObject(self.obj)
        objRegistry[self.obj] = nil
        self.obj = nil
    end
end

------------------------------------------------------------------------------

local EPoints = {}  --ErfahrungsPunkte
EPoints.__index = EPoints

function EPoints:add(data)
    local self = setmetatable({}, EPoints)
    self.type = data.type
    self.amount = data.amount
    local GiveEPoints = lib.callback.await('GiveEPoints', source, self.type, self.amount)
    if GiveEPoints then
        return self
    else
        return false
    end
end

function EPoints:get(data)
    self.type = data.type
    local GetEPoints = lib.callback.await('GetEPoints', source, self.type)
    print(json.encode(GetEPoints))
    return GetEPoints
end

------------------------------------------------------------------------------

local function Notify(msg)
    if IsDuplicityVersion() then
        TriggerClientEvent('mor_nucleus:Notify', -1, msg) -- Server: an alle
    else
        SetNotificationTextEntry("STRING")
        AddTextComponentString(msg)
        DrawNotification(false, false)
    end
end

RegisterNetEvent('mor_nucleus:Notify')
AddEventHandler('mor_nucleus:Notify', function(msg)
    Notify(msg)
end)

local function InfoLog(msg)
    lib.print.info(msg)
end

local function WarnLog(msg)
    lib.print.warn(msg)
end

local function PostFeed(data)
    local handle = RegisterPedheadshot(PlayerPedId())
    while not IsPedheadshotReady(handle) or not IsPedheadshotValid(handle) do Wait(0) end

    local txd = GetPedheadshotTxdString(handle)
    local pict = data.pict or txd
    RequestStreamedTextureDict(pict, true)
    Wait(5)

    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(data.text)
    EndTextCommandThefeedPostMessagetextTu(pict, pict, false, 0, data.title or "", data.subtitle or "", data.duration or 0.1)

    UnregisterPedheadshot(handle)
end

local function ScFoTe(text, duration, color)
    duration = duration or 5000
    local scaleform = RequestScaleformMovie("MP_BIG_MESSAGE_FREEMODE")

    while not HasScaleformMovieLoaded(scaleform) do
        Wait(0)
    end

    BeginScaleformMovieMethod(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
    PushScaleformMovieMethodParameterString(text)
    PushScaleformMovieMethodParameterString("")
    PushScaleformMovieMethodParameterInt(color or 5)
    EndScaleformMovieMethod()

    CreateThread(function()
        local startTime = GetGameTimer()
        while GetGameTimer() - startTime < duration do
            Wait(0)
            DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
        end
        SetScaleformMovieAsNoLongerNeeded(scaleform)
    end)
end

local function FormatTime(milliseconds) -- os.Time format in lesbares format umwandeln
    if not milliseconds then return end
    local totalSeconds = milliseconds / 1000
    local minutes = math.floor(totalSeconds / 60)
    local seconds = math.floor(totalSeconds % 60)
    local ms = math.floor((milliseconds % 1000) / 10)
    return string.format("%02d:%02d:%02d", minutes, seconds, ms)
end

RegisterNetEvent('mor_nucleus:PostFeed')
AddEventHandler('mor_nucleus:PostFeed', PostFeed)

------------------------------------------------------------------------------

-- 🌐 Zentrale Klasse
Mor.Blip = Blip
Mor.NPC = NPC
Mor.Object = Object
Mor.Pbar = Pbar
Mor.PGroups = PGroups
Mor.EPoints = EPoints
Mor.Notify = Notify
Mor.InfoLog = InfoLog
Mor.WarnLog = WarnLog
Mor.PostFeed = PostFeed
Mor.ScFoTe = ScFoTe
Mor.FormTime = FormatTime

------------------------------------------------------------------------------

exports('CreateBlip', function(data)
    local blip = Mor.Blip:new(data)
    return blip.id
end)

exports('RemoveBlip', function(id)
    local blip = blipRegistry[id]
    if blip then blip:remove() end
end)

exports('CreateNPC', function(data)
    local npc = Mor.NPC:new(data)
    return npc.ped
end)

exports('RemoveNPC', function(id)
    local npc = npcRegistry[id]
    if npc then npc:remove() end
end)

exports('CreateObject', function(data)
    local obj = Mor.Object:new(data)
    return obj.obj
end)

exports('RemoveObject', function(id)
    local obj = objRegistry[id]
    if obj then obj:remove() end
end)

exports('Notify', Notify)
exports('InfoLog', InfoLog)
exports('WarnLog', WarnLog)
exports('PostFeed', PostFeed)
exports('ScFoTe', ScFoTe)
exports('FormTime', FormatTime)

------------------------------------------------------------------------------

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    -- Blips löschen
    for id, blip in pairs(blipRegistry) do
        if blip and blip.remove then
            blip:remove()
        elseif DoesBlipExist(id) then
            RemoveBlip(id)
        end
    end

    -- NPCs löschen
    for ped, npc in pairs(npcRegistry) do
        if npc and npc.remove then
            npc:remove()
        elseif DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end

    -- Objekte löschen
    for obj, object in pairs(objRegistry) do
        if object and object.remove then
            object:remove()
        elseif DoesEntityExist(obj) then
            DeleteObject(obj)
        end
    end

    print("^3[core]: ^7Aufräumen: Alle blips, NPCs, und objects bereinigt.")
end)

------------------------------------------------------------------------------

return Mor

--- local Mor = require("client.cl_lib") ---
