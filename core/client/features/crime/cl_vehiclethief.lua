
local Mor = require("client.cl_lib")

local createNPC = CfgVehThief.auftraggeber
local stolenentity = 0
local blip = 0
local cooldown, abgabecooldown = false, false
local cooldownDuration = math.random(CfgVehThief.auftragsCooldownMin, CfgVehThief.auftragsCooldownMax) * 60000
local abgabeDuration = CfgVehThief.abgabecooldown * 60000

local timer = 300 -- Sekunden
local phoneNumber = nil
local thiefnpc = 0
local entBlip = 0
local entBlipaktiv = false
local model = nil
local belohnung, maxbelohnung = 0, 0

CreateThread(function()
    while true do
        Wait(10000)
        if model == nil then
            model = lib.callback.await('GetModelThief')
            if model then
                maxbelohnung = math.random(model.minamout, model.maxamout)
            end
        else
            break
        end
    end
end)

local function StartCooldown()
    if not cooldown then
        cooldown = true
        SetTimeout(cooldownDuration, function()
            cooldown = false
        end)
    else
        Mor.WarnLog("Cooldown ist bereits aktiv.")
    end
end

local function StartAbgabeCooldown()
    if not abgabecooldown then
        abgabecooldown = true
        local message = lib.callback.await('MessageToThief2', source, phoneNumber)
    else
        Mor.WarnLog("Abgabe Cooldown ist bereits aktiv.")
    end
end

local function StolenVehBlip()

    CreateThread(function()
        if entBlipaktiv == false then
            entBlipaktiv = true
            while true do
                Wait(5000)
                RemoveBlip(entBlip)
                local pedInVeh = IsPedInAnyVehicle(PlayerPedId(), false)
                local getVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                local stveh = DoesEntityExist(stolenentity)
                if stveh then
                    local coords = GetEntityCoords(stolenentity)
                    entBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
                        SetBlipSprite(entBlip, 41)
                        SetBlipColour(entBlip, 1)
                        SetBlipAsShortRange(entBlip, true)
                        SetBlipHiddenOnLegend(entBlip, false)
                        SetBlipScale(entBlip, 0.8)
                        SetBlipFlashes(entBlip, true)
                        BeginTextCommandSetBlipName('STRING')
                        AddTextComponentString("Gestohlenes Fahrzeug")
                        EndTextCommandSetBlipName(entBlip)
                else
                    RemoveBlip(entBlip)
                    if stveh == false then
                        entBlipaktiv = false
                        break
                    end
                end
            end
        end
    end)

end

local function onEnter(self)
    local pedInVeh = false
    local inAusfuehrung = lib.callback.await('vehiclethief:getauftragnehmer', source)
    Wait(500)
    stolenentity = lib.getClosestVehicle(self.coords, 3, false)
    local hotw = IsVehicleNeedsToBeHotwired(stolenentity)
    if hotw == false then
        SetVehicleDoorsLocked(stolenentity, 2)
        SetVehicleNeedsToBeHotwired(stolenentity, true)
    end
    while true do
        local enter = IsPedTryingToEnterALockedVehicle(PlayerPedId())

        if enter == true then
            SetVehicleDoorsLocked(stolenentity, 1)
            SetVehicleAlarm(stolenentity, true)
            SetVehicleAlarmTimeLeft(stolenentity, 10000)
            SetPlayerVehicleAlarmAudioActive(stolenentity, true)
            Wait(50)
            StartVehicleAlarm(stolenentity)
            if blip ~= nil then
                RemoveBlip(blip)
                if entBlipaktiv == false then
                    StolenVehBlip()
                end
            end
            if thiefnpc ~= 0 then
                DeletePed(thiefnpc.ped)
                StartAbgabeCooldown()
                thiefnpc = 0
            end
        end

        local pedseat = GetPedInVehicleSeat(stolenentity,-1)
        if pedseat == inAusfuehrung then
            pedInVeh = true
            SetVehicleIsStolen(stolenentity, true)
        else
            Wait(500)
        end

        if pedInVeh then
            pedInVeh = false
            local ageber = CfgVehThief.auftraggeber
            if not IsWaypointActive() then
                SetNewWaypoint(ageber[1].coords.x, ageber[1].coords.y)
            else
                ClearGpsPlayerWaypoint()
                Wait(100)
                SetNewWaypoint(ageber[1].coords.x, ageber[1].coords.y)
            end
            break
        end
        Wait(100)
    end
end

local function CreateNPCPed()
    if CfgVehThief.aktiv then
        thiefnpc = Mor.NPC:new({
            model = createNPC.pedmodel,
            coords = createNPC.coords,
            heading = createNPC.heading,
            scenario = createNPC.scenario,
            targetable = false
        })
    end
end

local function Auftragsannahme()
    local inAusfuehrung = lib.callback.await('vehiclethief:getauftragnehmer', source)
    phoneNumber = exports.npwd:getPhoneNumber()
    if not cooldown then
        if inAusfuehrung > 0 then
            Mor.Notify('Leider ist der Auftrag schon in Arbeit.')
        else
            local contract = lib.alertDialog({
                header = 'Auftraggeber',
                content = 'Aktueller Auftrag ist ein Fahrzeug Diebstahl.  \n Möchtest Du den Auftrag annehmen.',
                centered = true,
                size = 'xl',
                overflow = false,
                cancel = true,
                labels = {
                    cancel = 'Ablehnen',
                    confirm = 'Annehmen',
                }
            })
            if contract == 'confirm' then
                local auftrag = lib.callback.await('vehiclethief:SpawnThiefVehicle', source)
            elseif contract == 'cancel' then
                lib.closeAlertDialog()
                Mor.Notify('Auftrag ~r~abgelehnt.')
            end
        end
    else
        Mor.Notify('~w~Derzeit ~r~keine ~w~Aufträge vorhanden. \nKomme später wieder.')
    end
end

local function Auftragsabgabe()
    local engineHealth = 0
    local bodyHealth = 0
    if not abgabecooldown then
        local inAusfuehrung = lib.callback.await('vehiclethief:getauftragnehmer', source)
        if inAusfuehrung > 0 then
            if stolenentity ~= nil then
                if DoesEntityExist(stolenentity) then
                    local ente = stolenentity
                    local entBlip2 = GetBlipFromEntity(ente)
                    RemoveBlip(entBlip2)
                end
            end
            if stolenentity then
                if DoesEntityExist(stolenentity) then
                    engineHealth = GetVehicleEngineHealth(stolenentity)
                    bodyHealth = GetVehicleBodyHealth(stolenentity)
                    if engineHealth <= 800 then
                        belohnung = belohnung - 154
                    end
                    if bodyHealth <= 800 then
                        belohnung = belohnung - 181
                    end
                    belohnung = maxbelohnung - belohnung
                end
            end
            Wait(50)
            local abgabe = lib.callback.await('vehiclethief:auftragsabgabe', source, belohnung)
            if abgabe == 'AbgabeErledigt' then
                Wait(50)
                RemoveBlip(blip)
                local reset = lib.callback.await('vehiclethief:resetauftragnehmer', source)
                if reset == 'reset' then
                    local tdata = {
                        title = '~w~Auftraggeber',
                        subtitle = "~g~Abgeschlossen.",
                        text = '~w~Du hast ~g~$'..belohnung..' von möglichen ~y~$'..maxbelohnung..' ~w~bekommen.  \n~b~Fahrzeugzustand zählt da mit rein.',
                        duration = 0.6,
                        pict = 'CHAR_LESTER',
                        }
                    Mor.PostFeed(tdata)
                else
                    Mor.WarnLog('~r~[Fehler cl_vehiclethief]: ~w~Bei der Auftragsabgabe.')
                end
                stolenentity = 0
                local reBlip = DoesBlipExist(entBlip)
                if reBlip then
                    RemoveBlip(entBlip)
                end
                StartCooldown()
            else
                Mor.Notify('Auftrag noch aktiv. \nAbgabe nicht möglich.')
            end
        else
            Mor.Notify('~w~Es ist ~r~kein ~w~Auftrag in Arbeit.')
        end
    else
        Mor.Notify('~w~Abgabe ist ~r~noch nicht ~w~möglich')
    end
end

local function Auftragsabbruch()
    local inAusfuehrung = lib.callback.await('vehiclethief:getauftragnehmer', source)
    if inAusfuehrung > 0 then
        local strafzahlung = lib.callback.await('vehiclethief:strafzahlung', source)
        Wait(500)
        if strafzahlung == 'strafe' then
            local reset = lib.callback.await('vehiclethief:resetauftragnehmer', source)
            if blip ~= nil then
                RemoveBlip(blip)
            end
            stolenentity = 0
            if reset == 'reset' then
                Mor.Notify('Auftrag ~r~abgebrochen')
            else
                Mor.Notify('~r~[Fehler]: ~w~Beim Auftragsabbruch.')
            end
        else
            Mor.Notify('~r~[Fehler]: ~w~Bei Auftragsabbruch/Strafzahlung.')
        end
    else
        Mor.Notify('~w~Es ist ~r~kein ~w~Auftrag in Arbeit.')
    end
end

CreateThread( function()
    if CfgVehThief.aktiv then
        local thiefZone = exports.ox_target:addSphereZone({
            coords = createNPC.coords,
            options = {
                {
                    label = 'Auftragannehmen',
                    icon = 'car',
                    distance = 3,
                    onSelect = function()
                        Auftragsannahme()
                    end
                },
                {
                    label = 'Auftragabgeben',
                    icon = 'car',
                    distance = 3,
                    onSelect = function()
                        Auftragsabgabe()
                    end
                },
                            {
                    label = 'Auftragabbrechen(Strafzahlung)',
                    icon = 'car',
                    distance = 3,
                    onSelect = function()
                        Auftragsabbruch()
                    end
                },
            }
        })
        lib.callback.register('vehiclethief:ZoneUnLock', function(spawncoords, vehentity)
            if CfgVehThief.aktiv then
                Wait(500)
                lib.zones.sphere({
                    coords = spawncoords,
                    radius = 6,
                    debug = false,
                    onEnter = onEnter,
                })
            end
        end)
        lib.callback.register('vehiclethief:SetVehicleBlip', function(coords)
            blip = AddBlipForCoord(coords.x, coords.y, coords.z)
                SetBlipSprite(blip, 225)
                SetBlipColour(blip, 1)
                SetBlipAsShortRange(blip, true)
                SetBlipHiddenOnLegend(blip, false)
                SetBlipScale(blip, 0.7)
                SetBlipFlashes(blip, true)
                BeginTextCommandSetBlipName('STRING')
                AddTextComponentString("Auftragsziel")
                EndTextCommandSetBlipName(blip)
            if not IsWaypointActive() then
                SetNewWaypoint(coords.x, coords.y)
            else
                ClearGpsPlayerWaypoint()
                Wait(100)
                SetNewWaypoint(coords.x, coords.y)
            end
            return true
        end)
    end
end)

CreateThread(function()
    while true do
        Wait(10000)
        if abgabecooldown then
            timer = timer -10
            if timer <= 0 then
                abgabecooldown = false
                CreateNPCPed()
                local message = lib.callback.await('MessageToThief', source, phoneNumber)
            end
        end
    end
end)

CreateNPCPed()
