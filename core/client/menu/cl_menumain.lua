
local Mor = require('client.cl_lib')
local cfg = require("shared.cfg_core")
local garagen = cfg_garage.Garagen
local isAdmin = lib.callback.await('CallAdmincheck')
local grpList, vehList = {}, {}

local iplBlipsAktiv = false
local iplBlips = {}
local IplBlips = cfg.GtaIplBlips
local customMloBlipsAktiv = false
local customMloBlips = {}
local customMlosBlips = cfg.CustomMloBlips

local handcuffModel = 0
local pedcarried = 0

CreateThread( function()
    local player = Ox.GetPlayer(PlayerId())
    if not player then Wait(1) end
end)

local function SetWeather(weatherType)
    ClearOverrideWeather()
    ClearWeatherTypePersist()
    SetWeatherTypeNowPersist(weatherType)
    SetWeatherTypeNow(weatherType)
    SetWeatherTypePersist(weatherType)
    Mor.Notify("~r~[Wetterkontrolle:] ~g~Wetter geändert zu: ~y~" .. weatherType)
end

local function SetRandomWeather()
    local weatherTypes = {
        "EXTRASUNNY", "CLEAR", "CLOUDS", "SMOG", "FOGGY",
        "OVERCAST", "RAIN", "THUNDER", "CLEARING", "NEUTRAL"
    }
    local randomWeather = weatherTypes[math.random(#weatherTypes)]
    SetWeather(randomWeather)
    Mor.Notify('~r~[Wetterkontrolle:] ~g~Zufälliges Wetter: ~y~'.. randomWeather)
end

local function WetterAuswahl(wetter)
    local weatherType = wetter
    SetWeather(weatherType)
    Wait(3 * 60 * 60000) --3 Stunden
    SetRandomWeather()
end

local function CreateVehList(data)
    vehList = {}
    local garage
    local yes = '🟢'
    local no = '🔴'
    local symbol = ''
    if not data then return end
    for i=1, #data do
        local vehdata = Ox.GetVehicleData(data[i].model)
        if vehdata then
            for k=1, #garagen do
                if data[i].garage == garagen[k].name then
                    symbol = yes
                    garage = garagen[k].label
                end
                if data[i].garage == 'spawned' then
                    symbol = no
                    garage = 'ausgeparkt'
                end
            end
        end
        table.insert(vehList, {
            title = ''..symbol..' Fahrzeug: '..vehdata.name,
            description = 'Garage: '..garage..'\n  Kennzeichen: '..data[i].plate,
            readOnly = true,
            image = "nui://core/images/"..data[i].model..".png",
        })
    end
    return vehList
end

local function PedOk()
    if isAdmin then
        local tCoords = GetEntityCoords(PlayerPedId())
        local tHeading = GetEntityHeading(PlayerPedId())
        local player = Ox.GetPlayer(PlayerId())
        local maxHealth = GetEntityMaxHealth(PlayerPedId())
        local isDeadPlayer = GetEntityHealth(PlayerPedId())
        if isDeadPlayer <= 1 then
            print('NetworkResurrectLocalPlayer')
            NetworkResurrectLocalPlayer(tCoords.x, tCoords.y, tCoords.z, tHeading, 5000, false)
        end
        SetEntityHealth(PlayerPedId(), (maxHealth))
        SetPedArmour(PlayerPedId(), 100)
        player.addStatus('hunger', -100)
        player.addStatus('thirst', -100)
        player.setStatus('joint', 0)
        player.setStatus('drunk', 0)
    end
end

local function NeueGruppe()
    local input = lib.inputDialog('Neue Gruppe erstellen', {
        {type = 'input', label = 'Gruppen Name', description = 'Gruppenname kleinschreiben und ein Word', required = true, min = 1, max = 10},
        {type = 'input', label = 'Gruppen Label', description = 'GruppenLabel eingeben(offizieller Name)', required = true, min = 4, max = 30},
        {type = 'select', label = 'Gruppen Typ', description = 'Typ auswählen', required = true, options={{value="gang", label="Gang"},{value="job", label="Job"},{value="staat", label="Staat"}}},
        {type = 'number', label = 'Blip Farbe', description = 'Farbe für den Gruppenblip(1-85)', icon = 'hashtag', default = 1, min = 1, max = 85, required = true},
        {type = 'checkbox', label = 'Konto für Gruppe anlegen?', required = true},
    })
    local setnewgroup = lib.callback.await('gruppeanlegen', source, input)
    Mor.Notify(setnewgroup)
end

local function GruppeLoeschen()
    local Options = {}
    local getgroups = lib.callback.await('gruppenabfragen')
    for i=1, #getgroups do
        table.insert(Options, {value = getgroups[i].name, label = getgroups[i].name})
    end
    local input = lib.inputDialog('Gruppe löschen', {
        {type = 'select', label = 'Gruppenname', description = 'Name selektieren', required = true, options=Options}
    })
    local loeschgrp = lib.callback.await('gruppeloeschen', source, input)
    Mor.Notify(loeschgrp)
end

local function GruppeGeben()
    local GrpOptions = {}
    local getgroups = lib.callback.await('gruppenabfragen')
    for i=1, #getgroups do
        table.insert(GrpOptions, {value = getgroups[i].name, label = getgroups[i].name})
    end
    local input = lib.inputDialog('Gruppe/Rang vergeben', {
        {type = 'select', label = 'Gruppe', description = 'Typ auswählen', required = true, options=GrpOptions},
        {type = 'number', label = 'ID Nummer', description = 'ID des Spielers', icon = 'hashtag', required = true},
    })
    if input then
        local groupgeben = lib.callback.await('gruppevergeben', source, input)
        if groupgeben then
            Mor.Notify('Änderungen durchgeführt.')
        else
            Mor.Notify('~w~Änderung ~r~nicht ~w~möglich.')
        end
    else
        Mor.Notify('~r~Abgebrochen')
    end
end

local function GruppeVerlassen()
    local GrpOptions = {}
    local getgroups = lib.callback.await('morlib:GetAllGroups')
    for i=1, #getgroups do
        table.insert(GrpOptions, {value = getgroups[i].name, label = getgroups[i].name})
    end
    local input = lib.inputDialog('Gruppe/Firma verlassen', {
        {type = 'select', label = 'Gruppe', description = 'Typ auswählen', required = true, options=GrpOptions},
    })
    local groupverlassen= lib.callback.await('gruppeverlassen', source, input)
    if groupverlassen then
        Mor.Notify('Gruppe ~g~verlassen.')
    else
        Mor.Notify('~w~Gruppe ~r~nicht ~w~verlassen.')
    end
end

local isgeton = false
local function GetTargetEntityAimed()
    CreateThread(function()
        if isgeton == false then
            isgeton = true
        else
            isgeton = false
        end
        while true do
            if isgeton == true then
                if (IsAimCamActive() ~= false) or (IsAimCamThirdPersonActive() ~= false) then
                    local isEntity, entityNum = GetEntityPlayerIsFreeAimingAt(PlayerId())
                    if isEntity then
                        local entNum = entityNum
                        local entCoords = GetEntityCoords(entNum, false)
                        local entHeading = GetEntityHeading(entNum)
                        local entHash = GetEntityModel(entNum)
                        local entType = GetEntityType(entNum)
                        local info = 'Daten in der F8-Console und Hash im Zwischenspeicher.'
                        lib.setClipboard(entHash)
                        print('Entity:      ', entNum)
                        print('Coords:      ', entCoords)
                        print('Heading:     ', entHeading)
                        print('Hash:        ', entHash)
                        print('Type:        ', entType)
                        print('Tools aktiv: ', isgeton)
                        print('Hash in Zwischenablage kopiert.')

                        local displayTime = GetGameTimer() + 5000
                        CreateThread(function()
                            while GetGameTimer() < displayTime do
                                Wait(0)
                                DrawText3D(entCoords.x, entCoords.y, entCoords.z + 1.2, string.format(
                                    "Entity: %s\nTyp: %s\nCoords: %s\nHeading: %.1f\nHash: %s\nInfo: %s",
                                    entNum, entType, entCoords, entHeading, entHash, info))
                            end
                        end)
                    end
                else
                    Wait(1000)
                end
                Wait(1000)
            else
                isgeton = false
                break
            end
        end
    end)
end

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())

    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(true)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(true)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

local function DoUncuffPed(ped)
    if DoesEntityExist(ped) and not IsPedDeadOrDying(ped, true) then
        local coords = GetEntityCoords(PlayerPedId())
        local cuffsentity = GetClosestObjectOfType(coords.x,coords.y,coords.z, 2, handcuffModel, false, false, false)
        SetPedConfigFlag(ped,49,false)
        ClearPedTasksImmediately(ped)
        SetPedCanPlayAmbientAnims(ped, true)
        SetPedCanPlayGestureAnims(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, false)
        FreezeEntityPosition(ped, false)
        SetEntityAsMissionEntity(ped, false, false)
        DeleteEntity(cuffsentity)
        TaskWanderStandard(ped, 10.0, 10)
    end
end

local function HandcuffPed(ped)
    if DoesEntityExist(ped) and not IsPedDeadOrDying(ped, true) then
        if GetPedConfigFlag(ped,49,true) then
            DoUncuffPed(ped)
            Mor.Notify("~w~Handschellen abgenommen.")
        else
            ClearPedSecondaryTask(ped)
            ClearPedTasks(ped)
            SetPedConfigFlag(ped,49,true)
            RequestAnimDict("mp_arresting")
            while not HasAnimDictLoaded("mp_arresting") do
                Wait(10)
            end
            TaskPlayAnim(ped, "mp_arresting", "idle", 8.0, -8.0, -1, 49, 0, false, false, false)
            SetEntityAsMissionEntity(ped, true, true)
            SetPedCanPlayAmbientAnims(ped, false)
            SetPedCanPlayGestureAnims(ped, false)
            SetBlockingOfNonTemporaryEvents(ped, true)
            FreezeEntityPosition(ped, true)
            handcuffModel = GetHashKey("ba_prop_battle_cuffs")
            RequestModel(handcuffModel)
            while not HasModelLoaded(handcuffModel) do
                Wait(10)
            end
            local handcuffs = CreateObject(handcuffModel, 0.0, 0.0, 0.0, true, true, false)
            AttachEntityToEntity(handcuffs, ped, GetPedBoneIndex(ped, 60309), -0.055, 0.06, 0.04, 265, 190, 110, true, true, false, true, 1, true)
            SetModelAsNoLongerNeeded(handcuffModel)
            Mor.Notify("~w~Handschellen angelegt.")
        end
    end
end

local function GetNextPed()
    local coords = GetEntityCoords(PlayerPedId())
    local targetped = lib.getClosestPed(coords, 2)
    local player = Ox.GetPlayer(PlayerId())
    local playerjobstatus = player.getGroups()
    local playerjob = player.getGroup(playerjobstatus)
    if playerjob == 'police' and targetped then
        HandcuffPed(targetped)
    elseif not targetped  then
        Mor.Notify("~r~Kein Spieler in der Nähe!")
    end
end

local function Pedtragen(ped)
    local playerPed = PlayerPedId()
    if GetPedConfigFlag(ped,49,true) then
        if pedcarried == 0 then
            if DoesEntityExist(ped) then
              AttachEntityToEntity(ped, playerPed, GetPedBoneIndex(playerPed, 0), 0.0, 1.0, 0.4, 0.0, 0.0, 0.0, true, true, false, false, 2, true)
              pedcarried = 1
              Mor.Notify("~r~Tragen gestartet.")
            end
        elseif pedcarried == 1 then
            DetachEntity(ped, true, true)
            Mor.Notify("~r~Tragen beendet.")
            pedcarried = 0
        else
            Mor.Notify("~r~Fehler beim Tragen(Ticket).")
        end
    else
        Mor.Notify("~r~Keiner ~w~in der Nähe oder\nhat ~r~keine ~w~Handschellen.")
    end
end

local function FirmaManagement()
    print('Menu Firam')
    local aktGroup = lib.callback.await('jobabfrage', source)
    local allGroups = lib.callback.await('morlib:GetAllGroups')

    lib.registerContext({
        id = 'firma_menu',
        title = 'Firma',
        menu = 'persoenlichesmenu',
        options = {
            {
                title = 'Aktuelle Firma: '..aktGroup[1],
                icon = 'user',
                disabled = true,
            },
            {
                title = 'Firma wechseln',
                icon = 'business-time',
                onSelect = function()
                    grpList = {}
                    for i=1, #allGroups do
                        local group = lib.callback.await('morlib:GetLabels', source, allGroups[i].name, allGroups[i].grade)
                        if group == nil or (type(group) == "table" and next(group) == nil) then return end
                        Wait(100)
                        table.insert(grpList, {
                            title = group.grouplabel,
                            icon = 'user-group',
                            description = group.ranklabel,
                            onSelect = function()
                                local setAktGroup = lib.callback.await('SetAktivGroup', source, group.groupname)
                                Wait(200)
                                if setAktGroup then
                                    Mor.Notify('Firma ~g~gewechselt')
                                else
                                    Mor.Notify('~r~Fehler ~w~beim wechsel der Firma')
                                end
                            end,
                        })

                    end
                    Wait(200)
                    lib.registerContext({
                        id = 'firma_wechsel_menu',
                        title = 'Firma wechseln',
                        menu = 'persoenlichesmenu',
                        options = grpList,
                    })
                    lib.showContext('firma_wechsel_menu')
                end,
            },
            {
                title = 'Firma verlassen',
                icon = 'briefcase',
                onSelect = function()
                    GruppeVerlassen()
                end,
            },
        }
    })
    lib.showContext('firma_menu')
end

local function MenuSelect()
    local isAdmin = lib.callback.await('CallAdmincheck')
    local player = Ox.GetPlayer(PlayerId())
    local plyAllVehicles = lib.callback.await('GetAllPlayerVehicles', source)
    local aktGroup = lib.callback.await('jobabfrage', source)
    local plyData, plyDate = lib.callback.await('Personendatenabfrage', source)
    local allGroups = lib.callback.await('morlib:GetAllGroups')

    vehList = CreateVehList(plyAllVehicles)

    if plyData == nil or (type(plyData) == "table" and next(plyData) == nil) then return end

    if aktGroup == 'police' then
        lib.registerContext({
            {
                id = 'police',
                label = 'Polizei',
                icon = 'shield-halved',
                menu = 'police_menu'
            },
        })
        lib.registerContext({
            id = 'police_menu',
            items = {
                {
                  label = 'Handschellen',
                  icon = 'handcuffs',
                  onSelect = function()
                    print('Handcuff')
                    GetNextPed()
                  end
                },
                {
                  label = 'Durchsuchen',
                  icon = 'hand'
                },
                {
                  label = 'Fingerprint',
                  icon = 'fingerprint'
                },
                {
                  label = 'Tragen',
                  icon = 'hand',
                  onSelect = function()
                    local coords = GetEntityCoords(PlayerPedId())
                    local targetped = lib.getClosestPed(coords, 2)
                    Pedtragen(targetped)
                  end
                },
                {
                  label = 'Search',
                  icon = 'magnifying-glass',
                  onSelect = function()
                    print('Search')

                  end
                }
            }
        })
    end


    if not isAdmin then
        lib.registerContext({
            id = 'persoenlichesmenu',
            title = 'Persönliches Menü',
            options = {
                {
                    title = 'Interaktion',
                    description = 'Zum interagieren mit anderen Spielern',
                    menu = 'interaction_menu',
                    icon = 'circle-user'
                },
                {
                    title = 'Übersicht',
                    description = 'Deine Übersicht',
                    menu = 'uebersicht_menu',
                    icon = 'bars'
                },
                {
                    title = 'Firma',
                    description = 'Deine Firma',
                    menu = 'interaction_menu',
                    icon = 'bars'
                },
            }
        })
    else
        lib.registerContext({
            id = 'persoenlichesmenu',
            title = 'Persönliches Menü',
            options = {
                {
                    title = 'Interaktion',
                    description = 'Zum interagieren mit anderen Spielern',
                    menu = 'interaction_menu',
                    icon = 'circle-user'
                },
                {
                    title = 'Übersicht',
                    description = 'Deine Übersicht',
                    menu = 'uebersicht_menu',
                    icon = 'bars'
                },
                {
                    title = 'Firma',
                    description = 'Deine Firma',
                    arrow = true,
                    onSelect = function()
                        FirmaManagement()
                    end,
                    --menu = 'firma_menu',
                    icon = 'bars'
                },
                                {
                    title = 'Admin',
                    description = 'Admin Tools',
                    menu = 'admin_menu',
                    icon = 'bars'
                },
            }
        })
    end

    lib.registerContext({
        id = 'interaction_menu',
        title = 'Interaktions Menü',
        menu = 'persoenlichesmenu',
        options = {
            {
                title = 'Ausweis zeigen',
                icon = 'circle-user',
            },
            {
                title = 'Führerschein zeigen',
                icon = 'truck',
            },
        }
    })

    lib.registerContext({
        id = 'vehgarage_menu',
        title = '🚗 Deine Fahrzeuge 🚗',
        menu = 'persoenlichesmenu',
        options = vehList,
    })

    lib.registerContext({
        id = 'uebersicht_menu',
        title = 'Übersicht',
        menu = 'persoenlichesmenu',
        options = {
            {
                title = 'Deine Person',
                icon = 'user',
                iconColor = 'red',
                readOnly = true,
                metadata = {
                    {label = 'Name: ', value = plyData[1].fullName},
                    {label = 'Character Id: ', value = player.charId},
                    {label = 'Geboren am: ', value = plyDate},
                    {label = 'Telefonnummer: ', value = plyData[1].phoneNumber},
                },
            },
            {
                title = 'Fahrzeuge',
                icon = 'truck',
                iconColor = 'white',
                menu = 'vehgarage_menu',
            },
        }
    })

    lib.registerContext({
        id = 'map_menu',
        title = 'Map Einstellungen',
        options = {
            {
                title = 'Custom MLOs',
                icon = 'map-location-dot',
                onSelect = function()
                    if customMloBlipsAktiv == false then
                        customMloBlipsAktiv = true
                        for i=1, #customMlosBlips do
                            local iplblip = AddBlipForCoord(customMlosBlips[i].coords.x,customMlosBlips[i].coords.y,customMlosBlips[i].coords.z)
                                SetBlipSprite(iplblip, 78)
                                if customMlosBlips[i].inuse == 'yes' then
                                    SetBlipColour(iplblip, 2)
                                elseif customMlosBlips[i].inuse == 'no' then
                                    SetBlipColour(iplblip, 1)
                                end
                                SetBlipAsShortRange(iplblip, true)
                                SetBlipHiddenOnLegend(iplblip, false)
                                SetBlipScale(iplblip, 0.8)
                                BeginTextCommandSetBlipName("STRING")
                                AddTextComponentString("~p~"..customMlosBlips[i].name.." ~w~: ~y~"..customMlosBlips[i].gebiet.."")
                                EndTextCommandSetBlipName(iplblip)
                                AddTextEntry("BLIP_CAT_201", "~r~MLOs ")
                                SetBlipCategory(iplblip, 201)
                            table.insert(customMloBlips, iplblip)
                        end
                    elseif customMloBlipsAktiv == true then
                        for i=1, #customMloBlips do
                            RemoveBlip(customMloBlips[i])
                        end
                        customMloBlipsAktiv = false
                        table.wipe(customMloBlips)
                    end
                end,
            },
            {
                title = 'GTA IPLs',
                icon = 'map-location-dot',
                onSelect = function()
                    if iplBlipsAktiv == false then
                        iplBlipsAktiv = true
                        for i=1, #IplBlips do
                            local iplblip = AddBlipForCoord(IplBlips[i].coords.x,IplBlips[i].coords.y,IplBlips[i].coords.z)
                                SetBlipSprite(iplblip, 438)
                                if IplBlips[i].door == 'yes' then
                                    SetBlipColour(iplblip, 2)
                                elseif IplBlips[i].door == 'no' then
                                    SetBlipColour(iplblip, 1)
                                end
                                SetBlipAsShortRange(iplblip, true)
                                SetBlipHiddenOnLegend(iplblip, false)
                                SetBlipScale(iplblip, 0.8)
                                BeginTextCommandSetBlipName("STRING")
                                AddTextComponentString("~p~"..IplBlips[i].name.." ~w~: ~y~"..IplBlips[i].gebiet.."")
                                EndTextCommandSetBlipName(iplblip)
                                AddTextEntry("BLIP_CAT_200", "~r~IPLS ")
                                SetBlipCategory(iplblip, 200)
                            table.insert(iplBlips, iplblip)
                        end
                    elseif iplBlipsAktiv == true then
                        for i=1, #iplBlips do
                            RemoveBlip(iplBlips[i])
                        end
                        iplBlipsAktiv = false
                        table.wipe(iplBlips)
                    end
                end,
            },
        }
    })

    lib.registerContext({
        id = 'persdaten_menu',
        title = 'Persönliche Daten',
        menu = 'persoenlichesmenu',
        options = {
            {
                title = 'Deine Person',
                icon = 'user',
                onSelect = function()
                    print('persönliche Daten')
                end,
                metadata = {
                    {label = 'Name: ', value = plyData[1].fullName},
                    {label = 'Character Id: ', value = player.charId},
                    {label = 'Geboren am: ', value = plyDate},
                    {label = 'Telefonnummer: ', value = plyData[1].phoneNumber},
                },
            },
            {
                title = 'Fahrzeuge',
                icon = 'truck',
                onSelect = function()
                    print('Deine Fahrzeuge')
                end,
            },
        }
    })

    lib.registerContext({
        id = 'tools_menu',
        title = 'Tools Menü',
        menu = 'persoenlichesmenu',
        options = {
            {
                title = 'Get Hash (Targeting)',
                icon = 'bullseye',
                iconColor = 'red',
                onSelect = function()
                    GetTargetEntityAimed()
                end,
            },
            {
                label = 'Fahrzeuge DB prüfen',
                icon = 'code-compare',
                onSelect = function()
                    TriggerEvent('StartDBVehModels')
                end
            },
        }
    })

    lib.registerContext({
        id = 'group_menu',
        title = 'Gruppen verwalten',
        menu = 'persoenlichesmenu',
        options = {
            {
                title = 'Neue Gruppe anlegen',
                icon = 'people-group',
                onSelect = function()
                    NeueGruppe()
                end,
            },
            {
                title = 'Gruppe löschen.',
                icon = 'people-group',
                onSelect = function()
                    GruppeLoeschen()
                end,
            },
            {
                title = 'Gruppe geben.',
                icon = 'people-group',
                onSelect = function()
                    GruppeGeben()
                end,
            },
        }
    })

    lib.registerContext({
        id = 'admin_menu',
        title = 'Admin Menü',
        menu = 'persoenlichesmenu',
        options = {
            {
                title = 'Tool Menü',
                icon = 'screwdriver-wrench',
                menu = 'tools_menu',
            },
            {
                title = 'Wetter Menü',
                icon = 'smog',
                menu = 'wetter_menu',
            },
            {
                title = 'Map Settings Menü',
                icon = 'map',
                menu = 'map_menu',
            },
            {
                title = 'Gruppen verwalten.',
                icon = 'people-group',
                menu = 'group_menu',
            },
            {
                title = 'Eigenes Ped heilen',
                icon = 'user',
                onSelect = function()
                    PedOk()
                end,
            },
        }
    })
    lib.registerContext({
        id = 'wetter_menu',
        title = 'Wetter Menü1',
        menu = 'persoenlichesmenu',
        options = {
            {
                title = 'Sehr Sonnig',
                onSelect = function()
                    WetterAuswahl("EXTRASUNNY")
                end
            },
            {
                title = 'Klar',
                onSelect = function()
                    WetterAuswahl("CLEAR")
                end
            },
            {
                title = 'Regen',
                onSelect = function()
                    WetterAuswahl("RAIN")
                end
            },
            {
                title = 'Nebel',
                onSelect = function()
                    WetterAuswahl("FOGGY")
                end
            },
            {
                title = 'Neutral',
                onSelect = function()
                    WetterAuswahl("NEUTRAL")
                end
            },
            {
                title = 'Sturm',
                onSelect = function()
                    WetterAuswahl("BLIZZARD")
                end
            },
            {
                title = 'Aufklaren',
                onSelect = function()
                    WetterAuswahl("CLEARIG")
                end
            },
            {
                title = 'Smog',
                onSelect = function()
                    WetterAuswahl("SMOG")
                end
            },
            {
                title = 'Bedeckt',
                onSelect = function()
                    WetterAuswahl("OVERCAST")
                end
            },
            {
                title = 'Wolkig',
                onSelect = function()
                    WetterAuswahl("CLOUDS")
                end
            },
            {
                title = 'Helloween',
                onSelect = function()
                    WetterAuswahl("HELLOWEEN")
                end
            },
        }
    })
end

local keybind = lib.addKeybind({
    name = 'Menü',
    description = 'Drücke y um Dein Menü zu öffnen.',
    defaultKey = 'z',
    onPressed = function(self)
        lib.hideContext(true)
        Wait(20)
        MenuSelect()
        lib.showContext('persoenlichesmenu')
    end
})
