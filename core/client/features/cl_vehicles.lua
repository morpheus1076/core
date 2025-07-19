
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
            label = 'Sitzplatz wechseln.',
            icon = 'seat',
            menu = 'seatchange'
        },
                {
            label = 'Fenster.',
            icon = 'window',
            menu = 'fenster'
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
                    Mor.Notify("~y~Du hast ~r~keine ~y~Schlüssel für dieses Fahrzeug.")
                end
            end
		end
	end
end)
