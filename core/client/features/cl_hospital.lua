
local Mor = require("client.cl_lib")
local cfg = require("shared.cfg_core")
local points = require("shared.cfg_hospital")

local function CreateHospitalMenu(sentoptions)
    local input = lib.inputDialog('Wer soll geheilt werden?', {
        {type = 'select', label = 'Heilen',
        options = sentoptions,
        description = 'Wer soll geheilt werden?',
        required = true,
        },
    })
    local pedId = tonumber(input[1])
    if pedId then
        if pedId and DoesEntityExist(pedId) then
            print("Entity-ID erfolgreich konvertiert:", pedId)
        else
            print("Ungültige Entity oder Konvertierung fehlgeschlagen.")
        end
        if not IsPedAPlayer(pedId) then return nil end
        for _, playerId in ipairs(GetActivePlayers()) do
            local playerPed = GetPlayerPed(playerId)
            if playerPed == pedId then
                print('Auswahl und Ziel sind gleich')
                local playerSource = GetPlayerServerId(playerId)
                print('PlayerSource nach Auswahlt : '..playerSource)
            end
        end
        local plyMaxHealth = GetEntityMaxHealth(pedId)
        local plyHealth = GetEntityHealth(pedId)
        local setHealth = plyMaxHealth * 0.95
        if plyHealth < setHealth then
            local giveInvoice = lib.callback.await('hospital:GiveInvoice')
            if giveInvoice == true then
                SetEntityHealth(pedId, setHealth)
                local tdata = {
                    title = '~w~Krankenhaus',
                    subtitle = "~w~Behandlung.",
                    text = '~b~Mehr konnten wir nicht erreichen, aber es geht Dir wieder besser.',
                    duration = 0.4,
                    pict = 'CHAR_CALL911',
                }
                Mor.PostFeed(tdata)
            else
                Mor.Notify('~r~Sie besitzen kein gültiges Konto zur Abrechnung.')
            end
        else
            Mor.Notify('~w~Benötigen ~r~keine ~w~Behandlung.')
        end
    end
end

local function HospitalStarter()
    local plyCoords = GetEntityCoords(PlayerPedId())
    local players = lib.getNearbyPlayers(plyCoords,2,true)
    if #players == 1 then
        if PlayerPedId() == players[1].ped then
            local plyMaxHealth = GetEntityMaxHealth(players[1].ped)
            local plyHealth = GetEntityHealth(players[1].ped)
            local setHealth = plyMaxHealth * 0.95
            if plyHealth < setHealth then
                local giveInvoice = lib.callback.await('hospital:GiveInvoice')
                if giveInvoice == true then
                    SetEntityHealth(players[1].ped, setHealth)
                    local tdata = {
                        title = '~w~Krankenhaus',
                        subtitle = "~w~Behandlung.",
                        text = '~b~Mehr konnten wir nicht erreichen, aber es geht Dir wieder besser.',
                        duration = 0.4,
                        pict = 'CHAR_CALL911',
                    }
                    Mor.PostFeed(tdata)
                else
                    Mor.Notify('~r~Sie besitzen kein gültiges Konto zur Abrechnung.')
                end
            else
                Mor.Notify('~w~Sie benötigen ~r~keine ~w~Behandlung.')
            end
        end
    else
        Mor.Notify('Mehr als ein Player Ped')
        local menuOptions = {}
        for _,k in pairs(players) do
            if not IsPedAPlayer(k.ped) then return nil end
            for _, playerId in ipairs(GetActivePlayers()) do
                local playerPed = GetPlayerPed(playerId)
                if playerPed == k.ped then
                    local playerSource = GetPlayerServerId(playerId)
                    local getname, getped = lib.callback.await('GetPedInfos', source, playerSource, k.ped)
                    local getPed = json.encode(getped)
                    table.insert(menuOptions, {label = getname, value = getPed})
                end
            end
        end
        CreateHospitalMenu(menuOptions)
    end
end

CreateThread(function()
    if cfg.HospitalUse then
        local coords = points.coords
        for i=1, #coords do
            Mor.NPC:new({
                model = points.ped,
                coords = vec3(coords[i].x,coords[i].y,coords[i].z),
                heading = coords[i].w,
                scenario = points.scenario,
                targetable = true,
                targetoptions = {
                    label = 'Um Hilfe bitten, für $'..points.price..'. (Heilung auf Rechnung)',
                    distance = 2,
                    onSelect = function()
                        HospitalStarter()
                    end,
                }
            })
            Mor.Blip:new({
                coords = vec3(coords[i].x,coords[i].y,coords[i].z),
                label = 'Doktor',
                sprite = 153,
                scale = 0.4,
                color = 1,
                hidden = true,
            })
        end
    end
end)