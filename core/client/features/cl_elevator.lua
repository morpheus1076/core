
lib.locale()
local Mor = require("client.cl_lib")
local cfg = require("shared.cfg_core")
local elevators = require("shared.cfg_elevators")

local Options = {}
local Elevatorname = {}

local function Teleport(data)
    local args = data.id
    for k,v in pairs(elevators) do
        for _, j in pairs(v) do
            if args == j.id then
                local coords = j.coords
                StartPlayerTeleport(PlayerId(), coords.x, coords.y, coords.z, j.heading, false, true, true)
                while IsPlayerTeleportActive() do
                    Wait(2000)
                end
            end
        end
    end
end

local function Devoptions()
    Options = {}
    for k,v in pairs(elevators) do
        for _, j in pairs(v) do
            if Elevatorname == j.name then
                table.insert(Options, {title = j.label, onSelect = function() args= {id = j.id} Teleport(args) end })
            end
        end
    end
    return Options
end

local function inside(self)
    local result = IsControlJustPressed(1, 38)
    if result then
        local Options = Devoptions()
        lib.registerContext({
            id = 'elevators',
            title = 'Hell`s Elevators',
            onExit = function() Options = {} end,
            options = Options,
        })
        lib.showContext('elevators')
    end
end

local function ExitElevator(self)
    Elevatorname = {}
    Options = {}
end

local function Enterelevator(self)
    Mor.Notify("~e~Drücke ~r~[E] ~w~um den Aufzug zu benutzen")
    Elevatorname = self.Elevatorname
end

CreateThread(function()
    if cfg.ElevatorsUse == true then
        for k,v in pairs(elevators) do
            for _, j in pairs(v) do
                local sphere = lib.zones.sphere({
                    coords = j.coords,
                    radius = 1.5,
                    debug = false,
                    inside = inside,
                    onEnter = Enterelevator,
                    onExit = ExitElevator,
                    Elevatorname = j.name
                })
            end
        end
    end
end)
