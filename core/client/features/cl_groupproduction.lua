

--- ANFANG Coke Lab BALLAS ---
local entercokelab = lib.points.new(vec3(46.537, -1941.939, 21.482), 3)
local leavecokelab = lib.points.new(vec3(1088.756, -3188.162, -38.993), 3)

local function Entercokelab()
  local coords = vec3(1088.792, -3188.575, -38.993)
  local heading =  179.478
  StartPlayerTeleport(PlayerId(), coords.x, coords.y, coords.z, heading, false, true, true)
  while IsPlayerTeleportActive() do
    Wait(0)
  end
  DisplayRadar(false)
end

local function Leavecokelab()
  local coords = vec3(46.537, -1941.939, 21.482)
  local heading =  46.936
  StartPlayerTeleport(PlayerId(), coords.x, coords.y, coords.z, heading, false, true, true)
  while IsPlayerTeleportActive() do
    Wait(0)
  end
  DisplayRadar(true)
end

function entercokelab:onEnter()
    local neededjob = 'ballas'
    local player = Ox.GetPlayer(PlayerId())
    local playergroups = player.getGroups()
    local playerjob = player.getGroup(playergroups)
    if neededjob == playerjob then
        lib.addRadialItem({
            id = 'cokelab_access',
            icon = 'warehouse',
            label = 'Labor betreten',
            onSelect = function()
                AddTextEntry("CUSTOMLOADSTR", "betreten ...")
                BeginTextCommandBusyspinnerOn("CUSTOMLOADSTR")
                EndTextCommandBusyspinnerOn(4)
                Wait(2000)
                BusyspinnerOff()
                Entercokelab()
            end
        })
    end
end

function entercokelab:onExit()
    lib.removeRadialItem('cokelab_access')
end

function leavecokelab:onEnter()
    lib.addRadialItem({
        id = 'cokelab_leave',
        icon = 'warehouse',
        label = 'Labor verlassen',
        onSelect = function()
            AddTextEntry("CUSTOMLOADSTR", "verlassen ...")
            BeginTextCommandBusyspinnerOn("CUSTOMLOADSTR")
            EndTextCommandBusyspinnerOn(4)
            Wait(2000)
            BusyspinnerOff()
            Leavecokelab()
        end
    })
end

function leavecokelab:onExit()
    lib.removeRadialItem('cokelab_leave')
end

--- ENDE Coke Lab BALLAS ---

--- ANFANG Falschgeld TRIADS ---
local enterfalschgeld = lib.points.new(vec3(955.950, -2176.533, 31.151), 3)
local leavefalschgeld = lib.points.new(vec3(1121.897, -3195.338, -40.4025), 3)

function enterfalschgeld:onEnter()
    local neededjob = 'triads'
    local player = Ox.GetPlayer(PlayerId())
    local playergroups = player.getGroups()
    local playerjob = player.getGroup(playergroups)
    if neededjob == playerjob then
        lib.addRadialItem({
            id = 'falschgeld_access',
            icon = 'warehouse',
            label = 'Druckerei betreten',
            onSelect = function()
                AddTextEntry("CUSTOMLOADSTR", "betreten ...")
                BeginTextCommandBusyspinnerOn("CUSTOMLOADSTR")
                EndTextCommandBusyspinnerOn(4)
                Wait(2000)
                BusyspinnerOff()
                Enterfalschgeld()
            end
        })
    end
end

function enterfalschgeld:onExit()
    lib.removeRadialItem('falschgeld_access')
end

function leavefalschgeld:onEnter()
    lib.addRadialItem({
        id = 'falschgeld_leave',
        icon = 'warehouse',
        label = 'Druckerei verlassen',
        onSelect = function()
            AddTextEntry("CUSTOMLOADSTR", "verlassen ...")
            BeginTextCommandBusyspinnerOn("CUSTOMLOADSTR")
            EndTextCommandBusyspinnerOn(4)
            Wait(2000)
            BusyspinnerOff()
            Leavefalschgeld()
        end
    })
end

function leavefalschgeld:onExit()
    lib.removeRadialItem('falschgeld_leave')
end

function Enterfalschgeld()
    local coords = vec3(1121.897, -3195.338, -40.4025)
    local heading =  179.478
    StartPlayerTeleport(PlayerId(), coords.x, coords.y, coords.z, heading, false, true, true)
    while IsPlayerTeleportActive() do
      Wait(0)
    end
end

function Leavefalschgeld()
    local coords = vec3(955.950, -2176.533, 31.151)
    local heading =  46.936
    StartPlayerTeleport(PlayerId(), coords.x, coords.y, coords.z, heading, false, true, true)
    while IsPlayerTeleportActive() do
        Wait(0)
    end
end
--- ENDE Falschgeld TRIADS ---

--- ANFANG Afghan Production VAGOS ---
local enterweedlab = lib.points.new(vec3(981.424, -1805.594, 35.485), 3)
local leaveweedlab = lib.points.new(vec3(1065.371, -3183.592, -39.164), 3)

function enterweedlab:onEnter()
    local neededjob = 'vagos'
    local player = Ox.GetPlayer(PlayerId())
    local playergroups = player.getGroups()
    local playerjob = player.getGroup(playergroups)
    if neededjob == playerjob then
        lib.addRadialItem({
            id = 'cweedlab_access',
            icon = 'warehouse',
            label = 'Labor betreten',
            onSelect = function()
                AddTextEntry("CUSTOMLOADSTR", "betreten ...")
                BeginTextCommandBusyspinnerOn("CUSTOMLOADSTR")
                EndTextCommandBusyspinnerOn(4)
                Wait(2000)
                BusyspinnerOff()
                Enterweedlab()
            end
        })
    end
end

function enterweedlab:onExit()
    lib.removeRadialItem('cweedlab_access')
end

function leaveweedlab:onEnter()
    lib.addRadialItem({
        id = 'weedlab_leave',
        icon = 'warehouse',
        label = 'Labor verlassen',
        onSelect = function()
            AddTextEntry("CUSTOMLOADSTR", "verlassen ...")
            BeginTextCommandBusyspinnerOn("CUSTOMLOADSTR")
            EndTextCommandBusyspinnerOn(4)
            Wait(2000)
            BusyspinnerOff()
            Leaveweedlab()
        end
    })
end

function leaveweedlab:onExit()
    lib.removeRadialItem('weedlab_leave')
end

function Enterweedlab()
  local coords = vec3(1065.371, -3183.592, -39.164)
  local heading =  179.478
  StartPlayerTeleport(PlayerId(), coords.x, coords.y, coords.z, heading, false, true, true)
  while IsPlayerTeleportActive() do
    Wait(0)
  end
end

function Leaveweedlab()
  local coords = vec3(981.424, -1805.594, 35.485)
  local heading = 332.036
  StartPlayerTeleport(PlayerId(), coords.x, coords.y, coords.z, heading, false, true, true)
  while IsPlayerTeleportActive() do
    Wait(0)
  end
end
--- Afghan Production VAGOS ---