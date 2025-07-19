
local aktGarage = 'impound'
local parkBereich = {}
local garageLoaded = false
local isRunningWorkaround = false
local freepBlips = {}
local Mor = require("client.cl_lib")

local function IsSpawnPointClear(coords, radius)
    return not IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, radius)
end

local function StartWorkaroundTask()
	if isRunningWorkaround then
		return
	end
	local timer = 0
	local playerPed = PlayerPedId()
	isRunningWorkaround = true
	while timer < 50 do
		Wait(0)
		timer = timer + 1
		local vehicle = GetVehiclePedIsTryingToEnter(playerPed)
		if DoesEntityExist(vehicle) then
			local lockStatus = GetVehicleDoorLockStatus(vehicle)
			if lockStatus == 4 then
				ClearPedTasks(playerPed)
			end
		end
	end
	isRunningWorkaround = false
end

local function Doorlockanim()
    ClearPedSecondaryTask(GetPlayerPed(-1))
    while (not HasAnimDictLoaded( "anim@heists@keycard@")) do
        RequestAnimDict("anim@heists@keycard@")
        Wait(5)
    end
    TaskPlayAnim(GetPlayerPed(-1), "anim@heists@keycard@", "exit", 8.0, 1.0, -1, 16, 0, false, false, false)
    Wait(850)
    ClearPedTasks(GetPlayerPed(-1))
end

local function Einparken()
    local lastVehicle = GetPlayersLastVehicle()
    local vehNetId = NetworkGetNetworkIdFromEntity(lastVehicle)
    local properties = lib.getVehicleProperties(lastVehicle)
    local coords = 'null'
    TriggerServerEvent('VehEinparken', source, coords, aktGarage, vehNetId, properties)
end

local function Updaten()
    local lastVehicle = GetPlayersLastVehicle()
    local vehNetId = NetworkGetNetworkIdFromEntity(lastVehicle)
    local coords = GetEntityCoords(lastVehicle, true)
    local heading = GetEntityHeading(lastVehicle)
    local properties = lib.getVehicleProperties(lastVehicle)
    local garage = 'spawned'
    TriggerServerEvent('VehUpdaten', source, coords, heading, garage, vehNetId, properties)
end

local function Ausparken(plate, props)
    local points = cfg_garage.Garagen
    if cfg_garage.Aktiv then
        for i=1, #points do
            if points[i].name == aktGarage then
                local spawnpoints = points[i].spawnpoints
                for k=1, #spawnpoints do
                    local coord = spawnpoints[k]
                    if IsSpawnPointClear(coord, 2) then
                        local spawnCoords = vec3(coord.x,coord.y,coord.z)
                        local spawnHeading = coord.w
                        local spawnPlate = plate
                        TriggerServerEvent('VehAusparken', source, spawnPlate, spawnCoords, spawnHeading)
                        Wait(500)
                        Mor.Notify('~w~Fahrzeug ~g~ausgeparkt.')
                        break
                    end
                end
            end
        end
    end
end

local function AusparkMenu()
    if cfg_garage.Aktiv then
        local Options = {}
        local getVehicles = lib.callback.await('GetGarageVehicle', source, aktGarage)
        if getVehicles then
            for i=1, #getVehicles do
                local testData = json.decode(getVehicles[i].data)
                local fuelLevel = testData.properties.fuelLevel
                if fuelLevel >= 80.0 then
                    fuelColor = 'green'
                elseif fuelLevel >= 29.0 then
                    fuelColor = 'orange'
                else
                    fuelColor = 'red'
                end
                local engineHealth = ((testData.properties.engineHealth) / 10)
                if engineHealth >= 80.0 then
                    engineColor = 'green'
                elseif engineHealth >= 29.0 then
                    engineColor = 'orange'
                else
                    engineColor = 'red'
                end
                local bodyHealth = ((testData.properties.bodyHealth) / 10)
                if bodyHealth >= 80 then
                    bodyColor = 'green'
                elseif bodyHealth >= 29.0 then
                    bodyColor = 'orange'
                else
                    bodyColor = 'red'
                end
                local mileage = getVehicles[i].mileage
                local vehData = Ox.GetVehicleData(getVehicles[i].model)
                local vehName = vehData.name
                table.insert(Options, {title = vehName, description = 'Kennzeichen: '..getVehicles[i].plate,
                    image = "nui://core/images/"..getVehicles[i].model..".png",
                    metadata = {
                        {label = 'Fahrgestellnr.: ', value = ''..getVehicles[i].vin},
                        {label = 'Kilometerstand: ', value = ''..mileage..' km'},
                        {label = 'Tank: ', value = ''..fuelLevel..' %', progress = fuelLevel, colorScheme = fuelColor},
                        {label = 'Motor Status: ', value = ''..engineHealth..' %', progress = engineHealth, colorScheme = engineColor},
                        {label = 'Karosserie: ', value = ''..bodyHealth..' %', progress = bodyHealth, colorScheme = bodyColor},
                    },
                    onSelect = function()
                        Ausparken(getVehicles[i].plate)
                    end,
                })
            end
            lib.registerContext({id = 'garage', title = 'Garage', options = Options})
	        lib.showContext('garage')
        end
    end
end

local function VehicleBlips()
    local entities = lib.callback.await('PropsGetStart', source)
	if entities then
		for i = 1, #entities do
            local coords = entities[i].coords
			local fblip = AddBlipForCoord(coords.x, coords.y, coords.z)
			SetBlipSprite(fblip, 227)
			SetBlipColour(fblip, 15)
			SetBlipHiddenOnLegend(fblip, false)
			SetBlipScale(fblip, 0.3)
			SetBlipAsShortRange(fblip, true)
			SetBlipDisplay(fblip,2)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("~y~"..entities[i].model)
            AddTextEntry("BLIP_CAT_15", "~b~Deine Fahrzeuge")
            SetBlipCategory(fblip, 15)
			EndTextCommandSetBlipName(fblip)
            table.insert(freepBlips, fblip)
		end
	end
end

function CheckSpawnpoints()
    local cleanedAny = false
    for _, vehicle in pairs(GetGamePool('CVehicle')) do
        if DoesEntityExist(vehicle) then
            local coords = GetEntityCoords(vehicle)
            for _, zone in pairs(parkBereich) do
                if zone:contains(coords) then
                    local vehClass = GetVehicleClass(vehicle)
                    if vehicle and (vehClass >= 0 and vehClass <= 9 or vehClass == 12) then
                        local PedInVehicle = GetPedInVehicleSeat(vehicle, -1)
                        if PedInVehicle == 0 then
                            local props = lib.getVehicleProperties(vehicle)
                            local garage = zone.zone
                            local vehNetId = NetworkGetNetworkIdFromEntity(vehicle)
                            if vehNetId and vehNetId ~= 0 then
                                local parkcoords = 'null'
                                --local isDespawned = lib.callback.await('CleanSpawnPoint', source, vehNetId, garage, props)
                                TriggerServerEvent('VehEinparken', source, parkcoords, garage, vehNetId, props)
                                Wait(500)
                                cleanedAny = true
                            end
                        end
                    end
                    break
                end
            end
        end
    end
    Wait(2000)
    if cleanedAny then
        local tdata = {
            title = '~w~Abschleppdienst.',
            subtitle = "~w~On Tour.",
            text = '~p~Aufräumen beendet.',
            duration = 0.4,
            pict = 'CHAR_PROPERTY_TOWING_IMPOUND',
        }
        Mor.PostFeed(tdata)
    else
        local tdata = {
            title = '~w~Abschleppdienst.',
            subtitle = "~w~On Tour.",
            text = '~p~Aufräumen beendet.',
            duration = 0.4,
            pict = 'CHAR_PROPERTY_TOWING_IMPOUND',
        }
        Mor.PostFeed(tdata)
    end
    TriggerServerEvent('InfoMessage')
end

function GarageOnEnter(self)
    aktGarage = self.zone
end
function GarageOnExit(self)
    aktGarage = 'impound'
end

function GarageBase()
    if cfg_garage.Aktiv then
        garageLoaded = true
        local points = cfg_garage.Garagen
        local player = Ox.GetPlayer(PlayerId())
        local groups = player.getGroups()
        local plygroup = player.getGroup(groups)
        Wait(500)
        for i=1, #points do
            ---NPC---
            if points[i].group == 'keine' then
                RequestModel(GetHashKey(points[i].pedModel))
                while not HasModelLoaded(GetHashKey(points[i].pedModel)) do
                    Wait(1)
                end
                local npc = CreatePed(4, points[i].pedHash, points[i].pedcoords.x, points[i].pedcoords.y, points[i].pedcoords.z-1, points[i].pedcoords.w, true, true)
                FreezeEntityPosition(npc, true)
                SetEntityHeading(npc, points[i].pedcoords.w)
                SetEntityInvincible(npc, true)
                SetBlockingOfNonTemporaryEvents(npc, true)
                TaskStartScenarioInPlace(npc, points[i].pedScenario, -1, true)
            end
            if points[i].group == plygroup then
                RequestModel(GetHashKey(points[i].pedModel))
                while not HasModelLoaded(GetHashKey(points[i].pedModel)) do
                    Wait(1)
                end
                local npc = CreatePed(4, points[i].pedHash, points[i].pedcoords.x, points[i].pedcoords.y, points[i].pedcoords.z-1, points[i].pedcoords.w, true, true)
                FreezeEntityPosition(npc, true)
                SetEntityHeading(npc, points[i].pedcoords.w)
                SetEntityInvincible(npc, true)
                SetBlockingOfNonTemporaryEvents(npc, true)
                TaskStartScenarioInPlace(npc, points[i].pedScenario, -1, true)
            end
            ---Zone---
            lib.zones.sphere({
                coords = points[i].pedcoords,
                radius = 4,
                debug = false,
                zone = points[i].name,
                onEnter = GarageOnEnter,
                onExit = GarageOnExit
            })
            ---TargetZone---
            local thiefZone = exports.ox_target:addSphereZone({
                coords = points[i].pedcoords,
                options = {
                    {
                        label = 'Fahrzeug ausparken',
                        icon = 'car',
                        distance = 3,
                        onSelect = function()
                            AusparkMenu()
                        end
                    },
                    {
                        label = 'Fahrzeug einparken',
                        icon = 'car',
                        distance = 3,
                        onSelect = function()
                            Einparken()
                        end
                    }
                }
            })
            --Blips---
            local gtype = points[i].type
            if points[i].group == 'keine' then
                local blip = AddBlipForCoord(points[i].coord.x, points[i].coord.y, points[i].coord.z-1)
                if gtype == 'auto' then
                    SetBlipSprite(blip, 357)
                elseif gtype == 'boot' then
                    SetBlipSprite(blip, 356)
                elseif gtype == 'heli' then
                    SetBlipSprite(blip, 360)
                elseif gtype == 'plane' then
                    SetBlipSprite(blip, 359)
                end
                SetBlipColour(blip, 10)
                SetBlipAsShortRange(blip, true)
                SetBlipHiddenOnLegend(blip, true)
                SetBlipScale(blip, 0.5)
                SetBlipFlashes(blip, false)
                BeginTextCommandSetBlipName('STRING')
                AddTextComponentString("Garage")
                EndTextCommandSetBlipName(blip)
            end
            if points[i].group == plygroup then
                local gpblip = AddBlipForCoord(points[i].coord.x, points[i].coord.y, points[i].coord.z-1)
                SetBlipSprite(gpblip, 357)
                SetBlipColour(gpblip, 76)
                SetBlipAsShortRange(gpblip, true)
                SetBlipHiddenOnLegend(gpblip, true)
                SetBlipScale(gpblip, 0.5)
                SetBlipFlashes(gpblip, false)
                BeginTextCommandSetBlipName('STRING')
                AddTextComponentString("Garage")
                EndTextCommandSetBlipName(gpblip)
            end

            --- ParkingZone --- fürs automatische Einparken
            local parkingZone = lib.zones.poly({
                points = points[i].parkingZone,
                thickness = points[i].zoneThickness,
                debug = points[i].debug,
                zone = points[i].name,
            })
            table.insert(parkBereich, parkingZone)
        end
    end
end

local function Vehopen()
    local player = PlayerPedId()
    local pcoords = GetEntityCoords(player)
    local veh = nil
    local invkey

    StartWorkaroundTask()

    if IsPedInAnyVehicle(player, false) then
        veh = GetVehiclePedIsIn(player, false)
        local vehpropsi = lib.getVehicleProperties(veh)
		Wait(200)
        if vehpropsi then
            invkey = exports.ox_inventory:GetItemCount('keys', {'Master '..vehpropsi.plate}) --and exports.ox_inventory:GetItemCount('keys', {'Kopie: '..vehpropsi.plate})
        end
    else
        veh = GetClosestVehicle(pcoords.x, pcoords.y, pcoords.z, 8.0, 0, 70)
        local vehpropsi = lib.getVehicleProperties(veh)
		Wait(200)
        if vehpropsi then
            invkey = exports.ox_inventory:GetItemCount('keys', {'Master '..vehpropsi.plate}) --and exports.ox_inventory:GetItemCount('keys', {'Kopie: '..vehpropsi.plate})
        end
    end
    if not DoesEntityExist(veh) then
        return
    end
    if invkey == 1 then
        local vehlock = GetVehicleDoorLockStatus(veh)
        if vehlock == 1 then
			local vehprops = lib.getVehicleProperties(veh)
            Mor.Notify("~w~Fahrzeug ~r~verschlossen.")
            SetVehicleDoorsLocked(veh, 2)
            PlayVehicleDoorCloseSound(veh, 1)
            Doorlockanim()
			StartVehicleHorn(veh, 150, 'HELDDOWN', false)
			Wait(300)
            StartVehicleHorn(veh, 150, 'HELDDOWN', false)
            Updaten()
        elseif vehlock == 2 then
            Mor.Notify("~w~Fahrzeug ~g~aufgeschlossen.")
            SetVehicleDoorsLocked(veh, 1)
            PlayVehicleDoorOpenSound(veh, 0)
            Doorlockanim()
            StartVehicleHorn(veh, 150, 'HELDDOWN', false)
        end
    else
        Mor.Notify("~y~Du hast ~r~keine ~y~Schlüssel für dieses Fahrzeug.")
    end
end

lib.addKeybind({name = 'vehlock', description = 'Fahrzeug öffnen/verriegeln', defaultKey = 'G', onPressed = function() Vehopen() end})

CreateThread(function()
    while true do
        local notiTime = cfg_garage.checkTime - 5
        local despawnTime = cfg_garage.checkTime - notiTime
        Wait(notiTime * 60000)
        local tdata = {
            title = '~w~Abschleppdienst.',
            subtitle = "~w~On Tour.",
            text = '~w~In ~y~'..despawnTime..' Minuten~w~, wird auf den ~r~Garagen-Parkplätzen ~w~aufgeräumt.',
            duration = 0.6,
            pict = 'CHAR_PROPERTY_TOWING_IMPOUND',
        }
        Mor.PostFeed(tdata)
        Wait(despawnTime * 60000)
        local tdata = {
            title = '~w~Abschleppdienst.',
            subtitle = "~w~On Tour.",
            text = '~b~ Aufräumen startet.',
            duration = 0.3,
            pict = 'CHAR_PROPERTY_TOWING_IMPOUND',
        }
        Mor.PostFeed(tdata)
        CheckSpawnpoints()
    end
end)

CreateThread(function()
    while true do
        for i=1, #freepBlips do
            RemoveBlip(freepBlips[i])
        end
        table.wipe(freepBlips)
        VehicleBlips()
        Wait(60000)
    end
end)

GarageBase()