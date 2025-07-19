------------------------------------------------------------------------
local Notify = function(msg) exports['mor_nucleus']:Notify(msg) end
local InfoLog = function(msg) exports['mor_nucleus']:InfoLog(msg) end
local WarnLog = function(msg) exports['mor_nucleus']:WarnLog(msg) end
------------------------------------------------------------------------


local function InfoLog(msg)
    lib.print.info(msg)
end

local function WarnLog(msg)
    lib.print.warn(msg)
end

-- Nur auf dem Server ergibt Notify Sinn als Broadcast
local function Notify(msg)
    if IsDuplicityVersion() then
        TriggerClientEvent('mor_nucleus:Notify', -1, msg)
    end
end

-- 🧱 Rückgabe als Table
return {
    InfoLog = InfoLog,
    WarnLog = WarnLog,
    Notify = Notify,
}
