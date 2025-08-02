
if not lib then
    error('ox_lib ist nicht geladen!')
end

local Mor = require("client.cl_lib")

local scenarios = require ("shared.scenarios")
local cfg = require ("shared.cfg_core")
local isAdmin = false

CreateThread(function()
    while true do
        local playerPos = GetEntityCoords(PlayerPedId())
        local phonecount = exports.ox_inventory:GetItemCount('phone')
        if phonecount > 0 and playerPos.z > -30.0 then
            DisplayRadar(true)
        else
            DisplayRadar(false)
        end
        Wait(10000)
    end
end)

lib.callback.register('PrintCommands', function(data)
    local command = data[1]
    local desc = data[2]
    print('COMMAND: "'..command..'"  NUTZEN: "'..desc..'"')
end)

RegisterNetEvent('SettingNewHealth')
AddEventHandler('SettingNewHealth', function()
    local ped = GetPlayerPed(PlayerId())
    local isHealth = GetEntityHealth(ped)
    local newHealth = isHealth - cfg.HealthReduce
    if isHealth >= cfg.HealthReduce then
        FlashMinimapDisplayWithColor(17)
        Wait(500)
        FlashMinimapDisplayWithColor(17)
        SetEntityHealth(ped, newHealth)
    end
end)

CreateThread(function()
    local aktiv = cfg.npcaktiv
    local pedInt = cfg.PedInteriotMultiplier
    local pedExt = cfg.PedExtiriorMultiplier
    local pedMulti = cfg.PedMultiplier
    local vehMulti = cfg.VehicleMultiplier
    local ranMulti = cfg.RandomVehicleMultiplier
    local parkMulti = cfg.ParkedVehicleMultiplier
    while true do
        Wait(0)
        if aktiv then
            SetScenarioPedDensityMultiplierThisFrame( pedInt, pedExt )
            SetPedDensityMultiplierThisFrame(pedMulti)
            SetVehicleDensityMultiplierThisFrame(vehMulti)
            SetRandomVehicleDensityMultiplierThisFrame(ranMulti)
            SetParkedVehicleDensityMultiplierThisFrame(parkMulti)
        else
            SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0)
            SetPedDensityMultiplierThisFrame(0.0)
            SetVehicleDensityMultiplierThisFrame(0.0)
            SetRandomVehicleDensityMultiplierThisFrame(0.0)
            SetParkedVehicleDensityMultiplierThisFrame(0.0)
        end
    end
end)

CreateThread(function()
    while true do
        local year,month,day,hour,minute,second = GetLocalTime()
        NetworkOverrideClockTime(hour,minute,second)
        Wait(300000)
    end
end)

local function WetterSteuerung()
    local success = nil
    if cfg.weathercyclus then
        SetRainLevel(0.0)
        SetWeatherOwnedByNetwork(true)
        success = SetWeatherCycleEntry(0, "CLEAR", 120) and --"EXTRASUNNY"
                        SetWeatherCycleEntry(1, "CLEAR", 120) and --"CLEAR"
                        SetWeatherCycleEntry(2, "CLEAR", 120) and --"NEUTRAL"
                        ApplyWeatherCycles(3, 60000)
        return success
    else
        SetWeatherOwnedByNetwork(true)
    end
    return true
end

local function PedGrundsteuerung()
    DisableIdleCamera(true)
    DisableVehiclePassengerIdleCamera(true)
    SetForcePedFootstepsTracks(false)
    SetMpGamerTagVisibility(PlayerId(), 2, false)
    AddTextEntry('FE_THDR_GTAO', '~p~Deine Server ID: ~g~ ' .. GetPlayerServerId(PlayerId()))
    return true
end

local function ZeitSteuerung()
    NetworkOverrideClockMillisecondsPerGameMinute(60000)
    return true
end

local function MapSteuerung()
    if cfg.mapcomponents then
        local color = cfg.mapcomponentscolor
        SetMinimapComponent(15, true, color)
        SetMinimapComponent(9, true, color)
        SetMinimapComponent(7, true, color)
        SetMinimapComponent(2, true, color)
        SetMinimapComponent(1, true, color)
        SetMinimapComponent(0, true, color)
        SetMinimapComponent(14, true, color)
    end
    return true
end

local function NPCSteuerung()
    if cfg.trains then
        SwitchTrainTrack(0, true)
        SwitchTrainTrack(5, true)
        SwitchTrainTrack(9, true)
        SetTrainTrackSpawnFrequency(0, 900000)
        SetTrainTrackSpawnFrequency(5, 900000)
        SetTrainTrackSpawnFrequency(9, 600000)
        SetRandomTrains(false)
    end
    if cfg.tramps then
        SwitchTrainTrack(3, true)
        SwitchTrainTrack(4, true)
        SetTrainTrackSpawnFrequency(3, 450000)
        SetTrainTrackSpawnFrequency(4, 550000)
    end
    for i=1, 15 do
        EnableDispatchService(i, false)
    end
    if cfg.npcaktiv then
        DisableVehicleDistantlights(false)
        SetPedPopulationBudget(cfg.NpcPopulationBudget)
        SetVehiclePopulationBudget(cfg.VehiclePopulationBudget)
        SetNumberOfParkedVehicles(cfg.NumberOfParkedVehicles)
        SetRandomEventFlag(false)
    else
        DisableVehicleDistantlights(true)
        SetPedPopulationBudget(0)
        SetVehiclePopulationBudget(0)
        SetNumberOfParkedVehicles(0)
        SetRandomEventFlag(false)
    end
    return true
end

local function ScenarioSteuerung()
    if cfg.Scenarios then
        local Scenarios = scenarios.Scenarios
        for i = 1, #Scenarios do
            SetScenarioTypeEnabled(Scenarios[i], false)
        end
        SetScenarioGroupEnabled('DEALERSHIP',false)
        SetScenarioGroupEnabled('SANDY_PLANES', false)
        SetScenarioGroupEnabled('LSA_Planes', false)
        SetScenarioGroupEnabled('Grapeseed_Planes', true)
        SetScenarioGroupEnabled('GRAPESEED_PLANES', true)
        SetScenarioGroupEnabled('ALAMO_PLANES', true)
        SetScenarioGroupEnabled('ARMY_HELI', true)
    end
    return true
end

local function AudioSteuerung()
    if cfg.MapAudioAus == true then
        StartAudioScene("DLC_MPHEIST_TRANSITION_TO_APT_FADE_IN_RADIO_SCENE")
        StartAudioScene("FBI_HEIST_H5_MUTE_AMBIENCE_SCENE")
        StartAudioScene("CHARACTER_CHANGE_IN_SKY_SCENE")
        local staticEmitters = {
            "LOS_SANTOS_VANILLA_UNICORN_01_STAGE",
            "LOS_SANTOS_VANILLA_UNICORN_02_MAIN_ROOM",
            "LOS_SANTOS_VANILLA_UNICORN_03_BACK_ROOM"
        }
        for _, emitter in ipairs(staticEmitters) do
            SetStaticEmitterEnabled(emitter, false)
        end
        SetAmbientZoneListStatePersistent("AZL_DLC_Hei4_Island_Disabled_Zones", false, true)
        SetAmbientZoneListStatePersistent("AZL_DLC_Hei4_Island_Zones", true, true)
        local disabledScenarios = {
            "WORLD_VEHICLE_STREETRACE",
            "WORLD_VEHICLE_SALTON_DIRT_BIKE",
            "WORLD_VEHICLE_SALTON",
            "WORLD_VEHICLE_POLICE_NEXT_TO_CAR",
            "WORLD_VEHICLE_POLICE_CAR",
            "WORLD_VEHICLE_POLICE_BIKE",
            "WORLD_VEHICLE_MILITARY_PLANES_SMALL",
            "WORLD_VEHICLE_MILITARY_PLANES_BIG",
            "WORLD_VEHICLE_MECHANIC",
            "WORLD_VEHICLE_EMPTY",
            "WORLD_VEHICLE_BUSINESSMEN",
            "WORLD_VEHICLE_BIKE_OFF_ROAD_RACE"
        }
        for _, scenario in ipairs(disabledScenarios) do
            SetScenarioTypeEnabled(scenario, false)
        end
        SetAudioFlag("PoliceScannerDisabled", true)
        SetAudioFlag("DisableFlightMusic", true)
        SetPlayerCanUseCover(PlayerId(), false)
        SetRandomEventFlag(false)
        SetDeepOceanScaler(0.0)
    end
    return true
end

CreateThread(function()
    while true do
        Wait(5000)

        -- globale Speech Flags
        SetAudioFlag("PoliceScannerDisabled", true)
        SetAudioFlag("DisableBarks", true)

        local peds = GetGamePool('CPed')
        for _, ped in ipairs(peds) do
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
                --DisablePedAmbientVoice(ped, true)
                SetAmbientVoiceName(ped, "")
                if IsPedInCurrentConversation(ped) then
                    StopCurrentPlayingAmbientSpeech(ped)
                end
            end
        end
    end
end)


local function BigMap()
    if cfg.BigMap then
        lib.addKeybind({name = 'bigmap', description = 'Drücke "Z" um durch die Minimapvarianten zu schalten.', defaultKey = 'Y', onPressed = function()
            local bmAktiv = IsBigmapActive()
            local bbmAktive = IsBigmapFull()
            if not bmAktiv then
                SetRadarBigmapEnabled(true, false)
            elseif not bbmAktive and bmAktiv then
                SetRadarBigmapEnabled(true, true)
            elseif bbmAktive and bmAktiv then
                SetRadarBigmapEnabled(false, false)
            end
        end})
    end
    return true
end

local function SetupWeaponDamage()
    lib.onCache('weapon', function(weaponHash)
        if weaponHash and weaponHash ~= 0 then
            -- Bodyshot für alle Waffen (außer Sniper)
            local modifier = (weaponHash == GetHashKey('WEAPON_SNIPERRIFLE')) and 2.0 or 1.0
            SetWeaponDamageModifier(weaponHash, modifier)
            lib.print.info('cl_core:Weaponmodifier: '..modifier)
        end
    end)
    return true
end


AddEventHandler('ox:playerLoaded', function(playerId, isNew)
    local pedSetting = PedGrundsteuerung()
    local timeSetting = ZeitSteuerung()
    local weatherSettings = WetterSteuerung()
    local mapSettings = MapSteuerung()
    local npcSetting = NPCSteuerung()
    local scenSetting = ScenarioSteuerung()
    local audioSetting = AudioSteuerung()
    local bigmapSetting = BigMap()
    local bodyshotSetting = SetupWeaponDamage()
    local aceabfrage = lib.callback.await('AceCheck')
    isAdmin = aceabfrage

    if isAdmin then
        if pedSetting and timeSetting and weatherSettings and mapSettings and bodyshotSetting and
                    npcSetting and scenSetting and audioSetting and bigmapSetting then
            local msg = true
            lib.callback.await('MessageClientStart', source, msg)
            Wait(5000)
            Mor.Notify('~b~Willkommen in Los Santos Admin')
        else
            local msg = false
            lib.callback.await('MessageClientStart', source, msg)
            Mor.Notify('~b~Willkommen in Los Santos')
        end
    end
end)
