
local Mor = require("client.cl_lib")
local Points = require 'shared.cfg_blackmoney'
local cfg = require 'shared.cfg_core'

local function WaescheAbgeben()
    local player = Ox.GetPlayer(PlayerId())
    if not player then return end
    local group = player.getGroup(player.getGroups())
    local bmCount = lib.callback.await('GetCount')
    local input = lib.inputDialog('Abgabe Menge max. $20.000', {
        {type = 'number', label = 'Schwarzgeld', description = 'Wieviel möchtest Du abgeben?', icon = 'hashtag', default = bmCount, max = 20000},
    })
    if input then
        local amount = input[1]
        local dbAbgabe = lib.callback.await('mor_blackmoney:einzahlung', source, group, amount)
        if dbAbgabe == true then
            Mor.Notify('~w~Schwarzgeld ~g~abgegeben~w~.')
        else
            Mor.Notify('~r~Fehler bei der Abgabe')
        end
    end
end

local function WaescheAbholen()
    local player = Ox.GetPlayer(PlayerId())
    if not player then return end
    local group = player.getGroup(player.getGroups())
    local gesAmount, ausgezahltIds = 0, {}
    local ownerMoney = lib.callback.await('GetMoneyCount')
    local dbAusz = lib.callback.await('mor_blackmoney:auszahlung', source, group)
    if dbAusz then
        for i=1, #dbAusz do
            if dbAusz[i].amount then
                gesAmount = gesAmount + dbAusz[i].amount
                table.insert(ausgezahltIds, {id = dbAusz[i].id})
            end
        end
        if (math.floor(gesAmount * cfg.BlackmoneyChange)) > ownerMoney then
            Mor.Notify('~w~Auszahlung ~b~derzeit ~r~NICHT ~w~möglich.  \n~w~Bitte komme ~b~später ~w~wieder.')
        else
            local abschluss = lib.callback.await('mor_blackmoney:abschluss', source, gesAmount, ausgezahltIds)
            if abschluss then
                Mor.Notify('~w~Geld wurde ~g~ausgezahlt~w~.')
            else
                Mor.Notify('~r~Fehler bei der Auszahlung.')
            end
        end
    end
end

local function ChipsKaufen()

end

local function BlackMoneySalonMenu()
    lib.registerContext({
        id = 'waschsalon_menu',
        title = 'Waschsalon',
        options = {
            {
                title = 'Was kann ich für Sie tun?',
                disabled = true,
                readOnly = true,
            },
            {
                title = 'Wäsche abgeben.',
                description = 'Eine Ladung "Wäsche" abgeben.',
                icon = 'hand',
                onSelect = function()
                    WaescheAbgeben()
                end,
            },
            {
                title = 'Wäsche abholen.',
                description = 'Hoffentlich ist die "Wäsche" sauber.',
                icon = 'hand',
                onSelect = function()
                    WaescheAbholen()
                end,
            },
            {
                title = '"Automaten" Chips kaufen.',
                description = 'Takes you to another menu!',
                icon = 'bars',
                onSelect = function()
                    Mor.Notify('Was für Chips, hier gibts nix zu Essen.')
                    ChipsKaufen()
                end,
            },
        }
    })
    lib.showContext('waschsalon_menu')
end

local function BlackMoneyNPC()
    if cfg.BlackmoneyAktiv then
        local points = Points.Points
        for i=1, #points do
            local npc = Mor.NPC:new({
                model = points[i].pedModel,
                coords = points[i].pedCoords,
                heading =  points[i].pedHeading,
                targetable = true,
                scenario = points[i].pedScenario,
                targetoptions = {
                    label = 'Ansprechen',
                    distance = 3,
                    groups = {vagos = 3,ballas = 3,triads = 3, gwa = 4},
                    onSelect = function()
                        BlackMoneySalonMenu()
                    end,
                }
            })
        end
    end
end

AddEventHandler('ox:playerLoaded', function(playerId, isNew)
    Wait(8000)
    BlackMoneyNPC()
end)

BlackMoneyNPC()