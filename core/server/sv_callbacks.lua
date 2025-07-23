
local Inv = require("server.sv_lib")

local Grades = {
    {label = 'Anwärter', accountRole = 'viewer'},
    {label = 'Mitglied', accountRole = 'viewer'},
    {label = 'Manager', accountRole = 'contributor'},
    {label = 'Co Boss', accountRole = 'manager'},
    {label = 'Boss', accountRole = 'owner'},
}

lib.callback.register('CallAdmincheck', function(source)
    local playerace = IsPlayerAceAllowed(source, "admin")
    return playerace
end)

lib.callback.register('inv:canCarry', function(source, inv, item, count, metadata)
    return Inv:canCarry(inv, item, count, metadata)
end)

lib.callback.register('inv:add', function(inv, item, count, metadata, slot)
    return Inv:add(inv, item, count, metadata, slot)
end)

lib.callback.register('inv:remove', function(source, inv, item, count, metadata, slot, ignoreTotal)
    local inv = source
    return Inv:remove(inv, item, count, metadata, slot, ignoreTotal)
end)

--- Groups
lib.callback.register('morlib:GetAllGroups', function()
    local player = Ox.GetPlayer(source)
    Wait(200)
    if player == nil or (type(player) == "table" and next(player) == nil) then return end
    local plygroups = MySQL.query.await('SELECT * FROM `character_groups` WHERE charId = ?',{player.charId})
    return plygroups
end)

lib.callback.register('morlib:GetLabels', function(source, group, rank)
    local src = source
    local groupLabel = MySQL.query.await('SELECT label FROM `ox_groups` WHERE name = ?',{group})
    local rankLabel = MySQL.query.await('SELECT `label` FROM `ox_group_grades` WHERE `group` = ? AND `grade` = ?',{group, rank})
    local labels = {grouplabel = groupLabel[1].label, ranklabel = rankLabel[1].label, groupname = group, grouprank = rank }
    return labels
end)

lib.callback.register('SetAktivGroup', function(source, group)
    local player = Ox.GetPlayer(source)
    Wait(100)
    if player == nil or (type(player) == "table" and next(player) == nil) then return end
    local setActiv = player.setActiveGroup(group, false)
    return setActiv
end)

lib.callback.register('morlib:SetPlayerGroup', function(source, charId, group, rank)
    local src = source
    local player = Ox.GetPlayerFromCharId(charId)
    if player == nil or (type(player) == "table" and next(player) == nil) then return end
    local setSuccess = player.setGroup(group, rank)
    if setSuccess then
        local setActiv = player.setActiveGroup(group, false)
        return setActiv
    end
end)

lib.callback.register('gruppenabfragen', function()
    local groups = MySQL.query.await('SELECT name FROM ox_groups')
    return groups
end)

lib.callback.register('gruppeanlegen', function(source, data)
    Ox.CreateGroup({
        name = data[1],
        label = data[2],
        grades = Grades,
        type=data[3],
        colour = data[4],
        hasAccount = data[5]
    })
    local msg = '~w~Neue Gruppe ~y~'..data[2]..' ~w~wurde erstellt.'
    return msg
end)

lib.callback.register('gruppeloeschen', function(source, data)
    local delgroup = data[1]
    Ox.DeleteGroup(delgroup)
    local msg = '~w~Gruppe gelöscht: ~y~'..delgroup..''
    return msg
end)

lib.callback.register('gruppevergeben', function(source, data)
    local src = source
    local group = data[1]
    local target = data[2]
    local tplayer = Ox.GetPlayer(target)
    if tplayer == nil or (type(tplayer) == "table" and next(tplayer) == nil) then
        return false
    else
        local setgroup = tplayer.setGroup(group, 1)
        if setgroup then
            return true
        end
    end
end)

lib.callback.register('gruppeverlassen', function(source, data)
    local group = data[1]
    local player = Ox.GetPlayer(source)
    local setgroup = player.setGroup(group, 0)
    if setgroup == true then
        local setActiv = player.setActiveGroup('arbeitslos', false)
        return setActiv
    else
        return false
    end
end)

lib.callback.register('Personendatenabfrage', function(source)
    local player = Ox.GetPlayer(source)
    Wait(200)
    if player == nil or (type(player) == "table" and next(player) == nil) then return end
    local charData = MySQL.query.await('SELECT * FROM `characters` WHERE `charId`=?',{player.charId})
    local timeInSeconds = charData[1].dateOfBirth / 1000
    local charDate = os.date("%d.%m.%Y", timeInSeconds)
    return charData, charDate
end)

lib.callback.register('jobabfrage', function(source)
    local job = {}
    local joblabel = 'unbekannt'
    local gradelabel = 'unbekannt'
    local player = Ox.GetPlayer(source)
    local alljobs = MySQL.query.await('SELECT * FROM character_groups WHERE charId = ?;',{player.charId})
    for _,k in pairs (alljobs) do
        if k.isActive then
            local getjoblabel = MySQL.query.await('SELECT label FROM ox_groups WHERE name = ?;',{k.name})
            local getgradelabel = MySQL.query.await('SELECT label FROM ox_group_grades WHERE `group` = ? AND `grade` = ?;',{k.name, k.grade})
            joblabel = tostring(json.encode(getjoblabel[1].label))
            gradelabel = tostring(json.encode(getgradelabel[1].label))
        end
    end
    job = {joblabel, gradelabel}
    return job
end)

lib.callback.register('playergroupblips', function(source)
    local myGroup = {}
    local allplayers = Ox.GetPlayers()
    local player = Ox.GetPlayer(source)
    local souPlayer = MySQL.query.await('SELECT name FROM character_groups WHERE `charId` = ? AND `isActive` = ?;',{player.charId, true})
    if souPlayer == nil or (type(souPlayer) == "table" and next(souPlayer) == nil) then return end
    local plyGroup = souPlayer[1].name
    for i=1, #allplayers do
        local alljobs = MySQL.query.await('SELECT `name` FROM `character_groups` WHERE `charId` = ? AND `isActive` = ?;',{allplayers[i].charId, true})
        if alljobs then
            servGroup = alljobs[1].name
        end
        if plyGroup == servGroup then
            local getcolor = MySQL.query.await('SELECT `colour` FROM `ox_groups` WHERE `name` = ?', { plyGroup })
            local groupLabel = MySQL.query.await('SELECT `label` FROM `ox_groups` WHERE `name` = ?', { plyGroup })
            local grpplayer = Ox.GetPlayer(allplayers[i].source)
            local playername = grpplayer.get('fullname')
            if getcolor == nil or (type(getcolor) == "table" and next(getcolor) == nil) then return end
            table.insert(myGroup, {coords = allplayers[i].getCoords(), color = getcolor[1].colour, name = playername[1].fullName, label = groupLabel[1].label})
        end
    end
    return myGroup
end)

-- vehicles
lib.callback.register('GetAllPlayerVehicles', function()
    local player = Ox.GetPlayer(source)
    Wait(200)
    if player == nil or (type(player) == "table" and next(player) == nil) then return end
    local plyVehicles = MySQL.query.await('SELECT * FROM `vehicles` WHERE owner = ?',{player.charId})
    return plyVehicles
end)

-- pointsystem
lib.callback.register('GiveEPoints', function(source, eptype, amount)
    local player = Ox.GetPlayer(source)
    print(eptype, amount)
    if eptype == 'farm' or eptype == 'craft' or eptype == 'crime' or eptype == 'busi' then
        local GetPoints = MySQL.query.await('SELECT * FROM `pointsystem` WHERE `charId` = ?',{player.charId})
        if GetPoints == nil or (type(GetPoints) == "table" and next(GetPoints) == nil) then
            if eptype == 'farm' and amount >= 0 then
                local NewEPoints = MySQL.insert.await('INSERT INTO `pointsystem` (charId, farmpoints) VALUES( ?, ?)',{player.charId, amount})
                if NewEPoints then return true end
            end
            if eptype == 'crime' and amount >= 0 then
                local NewEPoints = MySQL.insert.await('INSERT INTO `pointsystem` (charId, crimepoints) VALUES( ?, ?)',{player.charId, amount})
                if NewEPoints then return true end
            end
            if eptype == 'craft' and amount >= 0 then
                local NewEPoints = MySQL.insert.await('INSERT INTO `pointsystem` (charId, craftpoints) VALUES( ?, ?)',{player.charId, amount})
                if NewEPoints then return true end
            end
            if eptype == 'busi' and amount >= 0 then
                local NewEPoints = MySQL.insert.await('INSERT INTO `pointsystem` (charId, businesspoints) VALUES( ?, ?)',{player.charId, amount})
                if NewEPoints then return true end
            end
        else
            if eptype == 'farm' and amount >= 0 then
                local IstEPoints = MySQL.query.await('SELECT `farmpoints` FROM `pointsystem` WHERE `charId` = ?',{player.charId})
                local SetPoints = IstEPoints[1].farmpoints + amount
                local NewEPoints = MySQL.update.await('UPDATE `pointsystem` SET `farmpoints`= ? WHERE `charId` = ?',{SetPoints, player.charId})
                if NewEPoints then return true end
            end
            if eptype == 'crime' and amount >= 0 then
                local IstEPoints = MySQL.query.await('SELECT `crimepoints` FROM `pointsystem` WHERE `charId` = ?',{player.charId})
                local SetPoints = IstEPoints[1].crimepoints + amount
                local NewEPoints = MySQL.update.await('UPDATE `pointsystem` SET `crimepoints`= ? WHERE `charId` = ?',{SetPoints, player.charId})
                if NewEPoints then return true end
            end
            if eptype == 'craft' and amount >= 0 then
                local IstEPoints = MySQL.query.await('SELECT `craftpoints` FROM `pointsystem` WHERE `charId` = ?',{player.charId})
                local SetPoints = IstEPoints[1].craftpoints + amount
                local NewEPoints = MySQL.update.await('UPDATE `pointsystem` SET `craftpoints`= ? WHERE `charId` = ?',{SetPoints, player.charId})
                if NewEPoints then return true end
            end
            if eptype == 'busi' and amount >= 0 then
                local IstEPoints = MySQL.query.await('SELECT `businesspoints` FROM `pointsystem` WHERE `charId` = ?',{player.charId})
                local SetPoints = IstEPoints[1].businesspoints + amount
                local NewEPoints = MySQL.update.await('UPDATE `pointsystem` SET `businesspoints`= ? WHERE `charId` = ?',{SetPoints, player.charId})
                if NewEPoints then return true end
            end
        end
    else
        lib.print.warn("[Pointsystem] Type ist nicht vorhanden. Types(farm, craft, crime, busi) : ", eptype)
    end
end)

lib.callback.register('GetEPoints', function(source, eptype)
    local player = Ox.GetPlayer(source)
    print(eptype)
    if eptype == 'farm' or eptype == 'craft' or eptype == 'crime' or eptype == 'busi' then
        if eptype == 'farm' then
            local IstEPoints = MySQL.query.await('SELECT `farmpoints` FROM `pointsystem` WHERE `charId` = ?',{player.charId})
            if IstEPoints then return IstEPoints[1].farmpoints end
        end
        if eptype == 'crime' then
            local IstEPoints = MySQL.query.await('SELECT `crimepoints` FROM `pointsystem` WHERE `charId` = ?',{player.charId})
            if IstEPoints then return IstEPoints[1].crimepoints end
        end
        if eptype == 'craft' then
            local IstEPoints = MySQL.query.await('SELECT `craftpoints` FROM `pointsystem` WHERE `charId` = ?',{player.charId})
            if IstEPoints then return IstEPoints[1].vraftpoints end
        end
        if eptype == 'busi' then
            local IstEPoints = MySQL.query.await('SELECT `businesspoints` FROM `pointsystem` WHERE `charId` = ?',{player.charId})
            if IstEPoints then return IstEPoints[1].businesspoints end
        end
    else
        lib.print.warn("[Pointsystem] Type ist nicht vorhanden. Types(farm, craft, crime, busi) : ", eptype)
    end
end)