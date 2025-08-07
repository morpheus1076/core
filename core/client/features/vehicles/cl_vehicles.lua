
local Mor = require("client.cl_lib")

local function AbschleppOption()
    Wait(10)
    local towTruck = GetVehiclePedIsIn(PlayerPedId(), false)
    local vehicle = GetEntityAttachedToTowTruck(towTruck)
    DetachVehicleFromTowTruck(towTruck,vehicle)
    Mor.Notify('Fahrzeug ~g~abgehängt')
end

--- Anti Seat-Shuffle
local function AntiSeatShuffle(vehicle)
    lib.onCache('seat', function(seatvalue, oldValue)
        if seatvalue == 0 and cfg_vehicles.antishuffle == true then
            local playerPed = PlayerPedId()
            SetPedIntoVehicle(playerPed, vehicle, 0)
        end
    end)
end

lib.registerRadial({
    id = 'seatchange',
    items = {
    {
        label = 'Fahrersitz.',
        icon = 'seat',
        onSelect = function()
            local player = PlayerPedId()
            if IsPedSittingInAnyVehicle(player) then
                local vehicle = GetVehiclePedIsIn(player, false)
                if IsVehicleSeatFree(vehicle, -1) then
                    SetPedConfigFlag(player, 184, true)
                    TaskWarpPedIntoVehicle(player, vehicle, -1)
                    Mor.Notify("~g~Sitzplatz wechselt.")
                else
                    Mor.Notify("~r~Sitzplatz belegt.")
                end
            else
                Mor.Notify("~r~Nicht im Fahrzeug.")
            end
        end
    },
    {
        label = 'Beifahrersitz.',
        icon = 'seat',
        onSelect = function()
            local player = PlayerPedId()
            if IsPedSittingInAnyVehicle(player) then
                local vehicle = GetVehiclePedIsIn(player, false)
                if IsVehicleSeatFree(vehicle, 0) then
                    SetPedConfigFlag(player, 184, true)
                    TaskWarpPedIntoVehicle(player, vehicle, 0)
                    Mor.Notify("~g~Sitzplatz wechselt.")
                else
                    Mor.Notify("~r~Sitzplatz belegt.")
                end

            else
                Mor.Notify("~r~Nicht im Fahrzeug.")
            end
        end
    },
    {
        label = 'Hinten Links',
        icon = 'seat',
        onSelect = function()
            local player = PlayerPedId()
            if IsPedSittingInAnyVehicle(player) then
                local vehicle = GetVehiclePedIsIn(player, false)
                if IsVehicleSeatFree(vehicle, 1) then
                    SetPedConfigFlag(player, 184, true)
                    TaskWarpPedIntoVehicle(player, vehicle, 1)
                    Mor.Notify("~g~Sitzplatz wechselt.")
                else
                    Mor.Notify("~r~Sitzplatz belegt.")
                end

            else
                Mor.Notify("~r~Nicht im Fahrzeug.")
            end
        end
    },
    {
        label = 'Hinten Rechts',
        icon = 'seat',
        onSelect = function()
            local player = PlayerPedId()
            if IsPedSittingInAnyVehicle(player) then
                local vehicle = GetVehiclePedIsIn(player, false)
                if IsVehicleSeatFree(vehicle, 2) then
                    SetPedConfigFlag(player, 184, true)
                    TaskWarpPedIntoVehicle(player, vehicle, 2)
                    Mor.Notify("~g~Sitzplatz wechselt.")
                else
                    Mor.Notify("~r~Sitzplatz belegt.")
                end
            else
                Mor.Notify("~r~Nicht im Fahrzeug.")
            end
        end
    },
    }
})

lib.registerRadial({
    id = 'fenster',
    items = {
        {
            label = 'Alle öffnen.',
            icon = 'window',
            onSelect = function()
                local player = PlayerPedId()
                if IsPedSittingInAnyVehicle(player) then
                    local vehicle = GetVehiclePedIsIn(player, false)
                    RollDownWindows(vehicle)
                else
                    Mor.Notify("~r~Nicht im Fahrzeug.")
                end
            end
        },
        {
            label = 'Alle schließen.',
            icon = 'window',
            onSelect = function()
                local player = PlayerPedId()
                if IsPedSittingInAnyVehicle(player) then
                    local vehicle = GetVehiclePedIsIn(player, false)
                    RollUpWindow(vehicle, 0)
                    RollUpWindow(vehicle, 1)
                    RollUpWindow(vehicle, 2)
                    RollUpWindow(vehicle, 3)
                    RollUpWindow(vehicle, 4)
                    RollUpWindow(vehicle, 5)
                    RollUpWindow(vehicle, 6)
                    RollUpWindow(vehicle, 7)
                else
                    Mor.Notify("~r~Nicht im Fahrzeug.")
                end
            end
        },
    }
})

lib.registerRadial({
    id = 'vehicle_menu',
    items = {
        {
            label = 'Sitzplatz wechseln',
            icon = 'seat',
            menu = 'seatchange'
        },
        {
            label = 'Fenster',
            icon = 'window',
            menu = 'fenster'
        },
        {
            label = 'Alle Türen schließen',
            icon = 'car-side',
            onSelect = function()
                local player = PlayerPedId()
                if IsPedSittingInAnyVehicle(player) then
                    local vehicle = GetVehiclePedIsIn(player, false)
                    SetVehicleDoorsShut(vehicle, false)
                end
            end
        },
        {
            label = 'Eigentum verwalten',
            icon = 'car',
            onSelect = function()
                local player = PlayerPedId()
                if IsPedSittingInAnyVehicle(player) then
                    local vehicle = GetVehiclePedIsIn(player, false)

                end
            end
        },
    }
})

lib.addKeybind({name = 'engineoo', description = 'Drücke M für Motor an/aus', defaultKey = 'M', onPressed = function() TriggerEvent('startstop') end})
local towkeybind = lib.addKeybind({name = 'towabkoppeln', description = 'Nur im TowTruck verwendbar, zum Abhängen', defaultkey = ',', disabled = true, onPressed = function() AbschleppOption() end})

--- Radiostation = 'OFF' --- Anti-Helmet ---Towing --- Oil Leaking
lib.onCache('vehicle', function(vehicle, oldValue)
    local playerPed = PlayerPedId()
    local vehClass = nil
    local vehType = nil
    if not vehicle then end
    if vehicle ~= false then
        vehClass = GetVehicleClass(vehicle) or nil
        vehType = GetVehicleTypeRaw(vehicle) or nil
        AntiSeatShuffle(vehicle)
        SetVehRadioStation(vehicle, 'OFF')
        SetRadioToStationName('OFF')
        Wait(50)
        SetVehicleRadioEnabled(vehicle, true)
        SetUserRadioControlEnabled(true)
        SetPedConfigFlag(playerPed, 184, true)
        SetAudioFlag('DisableFlightMusic', true)
        SetVehicleHasBeenOwnedByPlayer(vehicle, true)
        SetVehicleCanLeakOil(vehicle, true)  --- Öl Verlust, ist möglich.
    end
    if GetPedInVehicleSeat(vehicle, -1) == playerPed and (vehClass == 8 or vehClass == 13 or vehType == 3) then
        Wait(3500)
        local helmet = IsPedWearingHelmet(playerPed)
        if helmet then
            RemovePedHelmet(playerPed, true)
            SetPedHelmet(playerPed, false)
        end
    end
    if (IsVehicleModel(vehicle,GetHashKey('towtruck'))) or (IsVehicleModel(vehicle,GetHashKey('towtruck2'))) then
        towkeybind:disable(false)
        Mor.Notify('Abschlepper ~g~aktiviert. ~y~"Komma"~w~, zum abhängen')
    else
        towkeybind:disable(true)
    end
    lib.addRadialItem({
        {
            id = 'vehicle_mainmenu',
            label = 'Fahrzeug',
            icon = 'car',
            menu = 'vehicle_menu'
        },
    })
    if vehicle == false then
        lib.removeRadialItem('vehicle_mainmenu')
    end
end)

AddEventHandler('vehrepair', function()
	local player = PlayerPedId()
	local veh = GetPlayersLastVehicle()
	if IsPedSittingInAnyVehicle(player) then
		Mor.Notify("~r~Nicht ~w~im Fahrzeug ~r~möglich.")
		return
	end
	if DoesEntityExist(veh) then
		local bonnetPosition = GetOffsetFromEntityInWorldCoords(veh, 0.0, 1.9, 0.0) -- Front des Fahrzeugs
		TaskGoToCoordAnyMeans(PlayerPedId(), bonnetPosition.x, bonnetPosition.y, bonnetPosition.z, 1.0, 0, true, 786603, 0)
		Wait(3000)
		SetVehicleDoorOpen(veh, 4, false, false)
		TaskTurnPedToFaceEntity(PlayerPedId(), veh, 2000)
        Wait(2000)
		Mor.Notify("~w~Fahrzeug wird ~g~repariert.")
        Mor.Pbar:start({
            label = 'Reparatur läuft...',
            duration = 25000,
            anim = false,
            scenario = 'PROP_HUMAN_BUM_BIN'
        })
		Wait(25000)
		SetVehicleFixed(veh)
		SetVehicleDeformationFixed(veh)
		SetVehicleUndriveable(veh, false)
		ClearPedTasksImmediately(player)
		Mor.Notify("~w~Fahrzeug ist ~g~repariert.")
		TriggerServerEvent('VehItemRemove', 'fixkit', 1)
	else
		Mor.Notify("~r~Kein Fahrzeug in der Nähe.")
	end
end)

AddEventHandler('vehclean', function()
	local player = PlayerPedId()
    local coords = GetEntityCoords(player)
	local veh = lib.getClosestVehicle(coords, 8, true)
	if IsPedSittingInAnyVehicle(player) then
		Mor.Notify("~r~Nicht ~w~im Fahrzeug ~r~möglich.")
		return
	end
	if DoesEntityExist(veh) then
		Mor.Notify("~w~Fahrzeugwäsche ~g~gestartet.")
        Mor.Pbar:start({
            label = 'Fahrzeugwäsche läuft...',
            duration = 30000,
            anim = false,
            scenario = 'WORLD_HUMAN_MAID_CLEAN'
        })
		Wait(30000)
		SetVehicleDirtLevel(veh, 0)
		ClearPedTasksImmediately(player)
        Mor.Notify("~w~Fahrzeug ~g~gewaschen.")
		TriggerServerEvent('VehItemRemove', 'waschset', 1)
	else
		Mor.Notify("~r~Kein Fahrzeug in der Nähe.")
	end
end)

AddEventHandler('startstop', function()
    local scurrentVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local vehpropsi = lib.getVehicleProperties(scurrentVehicle)
	local enginestatus = GetIsVehicleEngineRunning(scurrentVehicle)
    local invkey
	if IsPedInAnyVehicle(PlayerPedId(), false) then
		if GetPedInVehicleSeat(scurrentVehicle, -1) then
            if vehpropsi then
                invkey = exports.ox_inventory:GetItemCount('keys', {'Master '..vehpropsi.plate}) --and exports.ox_inventory:GetItemCount('keys', {'Kopie: '..vehpropsi.plate})
                if invkey >= 1 then
                    if enginestatus then
                        SetVehicleEngineOn(scurrentVehicle, false, true, true)
                        SetVehicleUndriveable(scurrentVehicle, true)
                        Mor.Notify("~w~Motor ~r~aus.")
                    else
                        SetVehicleEngineOn(scurrentVehicle, true, true, true)
                        SetVehicleUndriveable(scurrentVehicle, false)
                        Mor.Notify("~w~Motor ~g~an.")
                    end
                else
                    Mor.Notify("~w~Du hast ~r~keinen ~y~Schlüssel ~w~für dieses Fahrzeug.")
                end
            end
		end
	end
end)

--- Mileage, OilLevel .... Wheels/Tyres???
local lastPos = nil
local totalDistance = 0
local updateInterval = 20000 -- alle 10 Sekunden

lib.onCache('vehicle', function(vehicle, oldValue)
    if vehicle ~= false then
        CreateThread(function()
            while true do
                Wait(updateInterval)
                local ped = PlayerPedId()
                if IsPedInAnyVehicle(ped, false) then
                    local veh = vehicle
                    if GetPedInVehicleSeat(veh, -1) == ped then
                        local plate = GetVehicleNumberPlateText(veh)
                        local coords = GetEntityCoords(veh)
                        if lastPos then
                            local distance = #(coords - lastPos)
                            totalDistance = totalDistance + distance
                            local km = distance / 1000.0
                            TriggerServerEvent("mileage:update", plate, km)
                        end
                        lastPos = coords
                    end
                else
                    lastPos = nil
                end
            end
        end)
        CreateThread(function()
            local lastPosOil = nil
            local totalDistanceOilLevel = 0
            local oildistance = 0
            local oilLevel = 0
            while true do
                local ped = PlayerPedId()
                local veh = vehicle
                if GetPedInVehicleSeat(veh, -1) == ped then
                    local plate = GetVehicleNumberPlateText(veh)
                    local coords = GetEntityCoords(veh)
                    local getOilLevel = lib.callback.await('GetVehicleOilLevel', source, plate)
                    oilLevel = getOilLevel
                    SetVehicleOilLevel(veh, getOilLevel)
                    if lastPosOil then
                        oildistance = #(coords - lastPosOil)
                        totalDistanceOilLevel = totalDistanceOilLevel + oildistance
                        local km = oildistance / 1000.0
                    end
                    lastPosOil = coords
                    if totalDistanceOilLevel >= 10000 then
                        local setLevel = oilLevel -0.0005
                        SetVehicleOilLevel(veh, setLevel)
                        totalDistanceOilLevel = 0
                        oildistance = 0
                        oilLevel = GetVehicleOilLevel(veh)
                        TriggerServerEvent("mileage:oillevelupdate", plate, oilLevel)
                    end
                else
                    lastPosOil = nil
                end
                Wait(30000)
            end
        end)
        CreateThread(function()
            while true do
                Wait(2000)
                local vehSpeed = (GetEntitySpeed(vehicle)*3.6)
                if vehSpeed >= 20 then
                    SetVehicleDoorsShut(vehicle, false)
                    Wait(2000)
                    break
                end
            end
        end)
    end
end)

RegisterCommand("vehdata", function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh == 0 then return print("Du sitzt in keinem Fahrzeug.") end
    local plate = GetVehicleNumberPlateText(veh)
    local oilLevel = GetVehicleOilLevel(veh)
    print(("Aktueller Öl Stand: %.2f Liter"):format(oilLevel))
    lib.callback("mileage:get", false, function(km)
        print(("Aktuelle Laufleistung: %.2f km"):format(km))
    end, plate)
end, false)

RegisterCommand("opendoors", function()
    local Vehicle = GetVehiclePedIsUsing(PlayerPedId())
    for i = 0, 5 do
        SetVehicleDoorOpen(Vehicle, i, false, false) -- will open every door from 0-5
    end
end, false)

local vehicleData = {}
lib.onCache('vehicle', function(vehicle, oldfalue)
    if not vehicle then return end
    vehicleData[vehicle] = vehicleData[vehicle] or {}
    vehicleData[vehicle].properties = lib.getVehicleProperties(vehicle)
    vehicleData[vehicle].mods = {
        ["0"]= {
            name = locale('spoiler'),
            is = GetVehicleMod(vehicle, 0),
            max = GetNumVehicleMods(vehicle, 0),
            label = GetModTextLabel(vehicle, 0 , is)
        },
        ["1"]= {
            name = locale('bumper Front'),
            is = GetVehicleMod(vehicle, 1),
            max = GetNumVehicleMods(vehicle, 1),
            label = GetModTextLabel(vehicle, 1 , is)
        },
        ["2"]= {
            name = locale('bumper Rear'),
            is = GetVehicleMod(vehicle, 2),
            max = GetNumVehicleMods(vehicle, 2),
            label = GetModTextLabel(vehicle, 2 , is)
        },
        ["3"]= {
            name = locale('skirt'),
            is = GetVehicleMod(vehicle, 3),
            max = GetNumVehicleMods(vehicle, 3),
            label = GetModTextLabel(vehicle, 3 , is)
        },
        ["4"]= {
            name = locale('exhaust'),
            is = GetVehicleMod(vehicle, 4),
            max = GetNumVehicleMods(vehicle, 4),
            label = GetModTextLabel(vehicle, 4 , is)
        },
        ["5"]= {
            name = locale('chassis'),
            is = GetVehicleMod(vehicle, 5),
            max = GetNumVehicleMods(vehicle, 5),
            label = GetModTextLabel(vehicle, 5 , is)
        },
        ["6"]= {
            name = locale('grill'),
            is = GetVehicleMod(vehicle, 6),
            max = GetNumVehicleMods(vehicle, 6),
            label = GetModTextLabel(vehicle, 6 , is)
        },
        ["7"]= {
            name = locale('bonnet'),
            is = GetVehicleMod(vehicle, 7),
            max = GetNumVehicleMods(vehicle, 7),
            label = GetModTextLabel(vehicle, 7, is)
        },
        ["8"]= {
            name = locale('wingL'),
            is = GetVehicleMod(vehicle, 8),
            max = GetNumVehicleMods(vehicle, 8),
            label = GetModTextLabel(vehicle, 8, is)
        },
        ["9"]= {
            name = locale('wingR'),
            is = GetVehicleMod(vehicle, 9),
            max = GetNumVehicleMods(vehicle, 9),
            label = GetModTextLabel(vehicle, 9, is)
        },
        ["10"]= {
            name = locale('roof'),
            is = GetVehicleMod(vehicle, 10),
            max = GetNumVehicleMods(vehicle, 10),
            label = GetModTextLabel(vehicle, 10, is)
        },
        ["11"]= {
            name = locale('engine'),
            is = GetVehicleMod(vehicle, 11),
            max = GetNumVehicleMods(vehicle, 11),
            label = GetModTextLabel(vehicle, 11, is)
        },
        ["12"]= {
            name = locale('brakes'),
            is = GetVehicleMod(vehicle, 12),
            max = GetNumVehicleMods(vehicle, 12),
            label = GetModTextLabel(vehicle, 12, is)
        },
        ["13"]= {
            name = locale('gearbox'),
            is = GetVehicleMod(vehicle, 13),
            max = GetNumVehicleMods(vehicle, 13),
            label = GetModTextLabel(vehicle, 13, is)
        },
        ["14"]= {
            name = locale('horn'),
            is = GetVehicleMod(vehicle, 14),
            max = GetNumVehicleMods(vehicle, 14),
            label = GetModTextLabel(vehicle, 14, is)
        },
        ["15"]= {
            name = locale('suspension'),
            is = GetVehicleMod(vehicle, 15),
            max = GetNumVehicleMods(vehicle, 15),
            label = GetModTextLabel(vehicle, 15, is)
        },
    }
    local vehdata = {mods = vehicleData[vehicle].mods, properties = vehicleData[vehicle].properties, entity = vehicle }
    local serverCall = lib.callback.await("setVehicleData", source, vehdata)
end)
