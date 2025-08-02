
lib.locale()
local Mor = require("client.cl_lib")
local import = require("shared.cfg_auftraggeber")
local cfgCore = require("shared.cfg_core")

local legalJobs = import.legaljobs

local function RandomJobs()
    local randomJobs = {}
    local copiedJobs = {}

    for _, job in ipairs(legalJobs) do
        table.insert(copiedJobs, job)
    end

    for i = 1, math.min(import.legalCount, #copiedJobs) do
        local randomIndex = math.random(1, #copiedJobs)
        table.insert(randomJobs, copiedJobs[randomIndex])
        table.remove(copiedJobs, randomIndex)
    end

    return randomJobs
end

local function NeueAuftragamenu()
    local jobs = RandomJobs()
    local aktJobs = lib.callback.await('auftraggeber:auftragabrufen')
    local numJobs = #aktJobs
    local menuOptions = {}
    if numJobs <= (import.maxOrders-1) then
        for _,k in ipairs(jobs) do
            table.insert(menuOptions,
            {
                title = k.title,
                description = 'Liefer '..k.items.amount..'x '..k.items.label..' für '..k.earning..'$.',
                id = k.id,
                onSelect = function()
                    TriggerServerEvent('auftraggeber:auftragspeichern', k.id, k.atype)
                end
            })
        end
        lib.registerContext({
            id = 'neueauftraegemenu',
            title = locale('Order list'),
            menu = 'mainauftragsgeber',
            options = menuOptions,
        })
        lib.showContext('neueauftraegemenu')
    else
        Mor.Notify('~r~Maximale ~w~Anzahl an Aufträgen ~r~erreicht~w~.')
    end
end

local function AuftragAbgeben()
    local listOptions = {}
    local aktJobs = lib.callback.await('auftraggeber:auftragabrufen')

    for _,a in ipairs(legalJobs) do
        for _,k in ipairs(aktJobs) do
            if a.id == k.id then
                table.insert(listOptions, {
                    title = a.title,
                    description = 'Liefer '..a.items.amount..'x '..a.items.label..' für '..a.earning..'$.',
                    onSelect = function()
                        TriggerServerEvent('auftraggeber:auftragabgeben', k.orderid)
                    end,
                })
            end
        end
    end

    lib.registerContext({
        id = 'auftragsabgeben',
        title = locale('Order list'),
        menu = 'mainauftragsgeber',
        options = listOptions,
    })

    lib.showContext('auftragsabgeben')
end

local function AuftragsListe()
    local listOptions = {}
    local aktJobs = lib.callback.await('auftraggeber:auftragabrufen')

    for _,a in ipairs(legalJobs) do
        for _,k in ipairs(aktJobs) do
            if a.id == k.id then
                table.insert(listOptions, {title = a.title, description = 'Liefer '..a.items.amount..'x '..a.items.label..' für '..a.earning..'$.', readOnly = true})
            end
        end
    end

    lib.registerContext({
        id = 'auftragsliste',
        title = locale('Order list'),
        menu = 'mainauftragsgeber',
        options = listOptions,
    })

    lib.showContext('auftragsliste')
end

local function AuftragAbbrechen()
    local listOptions = {}
    local aktJobs = lib.callback.await('auftraggeber:auftragabrufen')

    for _,a in ipairs(legalJobs) do
        for _,k in ipairs(aktJobs) do
            if a.id == k.id then
                table.insert(listOptions, {
                    title = a.title,
                    description = 'Liefer '..a.items.amount..'x '..a.items.label..' für '..a.earning..'$.',
                    onSelect = function()
                        TriggerServerEvent('auftraggeber:auftragloeschen', k.orderid)
                    end,
                })
            end
        end
    end

    lib.registerContext({
        id = 'auftragsabbruch',
        title = locale("Delete Orders"),
        menu = 'mainauftragsgeber',
        options = listOptions,
    })

    lib.showContext('auftragsabbruch')
end

local function CreateMenu()
    lib.registerContext({
        id = 'mainauftragsgeber',
        title = locale('Order list'),
        options = {
            {
                title = locale("Open Orders"),
                icon = 'list',
                arrow = true,
                onSelect = function()
                    NeueAuftragamenu()
                end,
            },
            {
                title = locale("Close Orders"),
                icon = 'list-check',
                arrow = true,
                onSelect = function()
                    AuftragAbgeben()
                end,
            },
                        {
                title = locale("Your Orders"),
                icon = 'list-check',
                arrow = true,
                onSelect = function()
                    AuftragsListe()
                end,
            },
            {
                title = locale("Delete Orders"),
                icon = 'list-check',
                arrow = true,
                onSelect = function()
                    AuftragAbbrechen()
                end,
            }
        }
    })

    lib.showContext('mainauftragsgeber')
end

if cfgCore.AuftraggeberUse then
    local legalPed = Mor.NPC:new({
        model = import.legalPed.model,
        coords = import.legalPed.coords,
        heading = import.legalPed.heading,
        scenario = import.legalPed.scenario,
        targetable = import.legalPed.targetable,
        targetoptions = {
            label = locale('Get temporary order'),
            name = 'legalauftragsgeber',
            distance = 2.5,
            onSelect = function()
                CreateMenu()
            end
        },
    })

    local legalBlip = Mor.Blip:new({
        coords = import.legalPed.coords,
        name = import.legalBlip.name,
        sprite = import.legalBlip.sprite,
        color = import.legalBlip.color,
        hidden = import.legalBlip.hidden
    })
end

RegisterNetEvent('auftraggeber:nichtgenug', function()
    Mor.Notify('~w~Du hast ~r~nicht ~w~nicht genug dabei.')
end)

RegisterNetEvent('auftraggeber:maxorder', function()
    Mor.Notify('~w~Du hast das ~r~Maximum ~w~an Aufträgen ~r~erreicht~w~.')
end)