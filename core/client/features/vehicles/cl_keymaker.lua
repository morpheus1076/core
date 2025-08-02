
lib.locale()
local Mor = require("client.cl_lib")

local coords = vec3(157.816, 6654.254, 31.667)
local heading = 133.863
local ped = "a_m_y_genstreet_01"
local pedhash =  0x9877EF71
local scenario = "WORLD_HUMAN_CLIPBOARD"
local label = "Schlüsseldienst"
local bliplabel = "Schlüsseldienst"
local price = 500
local Options = {}

local parameters = {
    coords = coords,
    name = label,
    size = vec3(2,2,2),
    rotation = 0,
    debug = false,
    options = {
        label = label,
        icon = "fas fa-key",
        distance = 2.5,
        onSelect = function()
            Keymakermenu()
        end
    }
}

exports.ox_target:addBoxZone(parameters)

CreateThread(function()
    RequestModel(GetHashKey(ped))
    while not HasModelLoaded(GetHashKey(ped)) do
        Wait(1)
    end
    local blip = AddBlipForCoord(coords.x,coords.y,coords.z)
        SetBlipSprite(blip, 134)
        SetBlipColour(blip, 2)
        SetBlipAsShortRange(blip, true)
        SetBlipHiddenOnLegend(blip, false)
        SetBlipScale(blip, 0.8)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(label)
        EndTextCommandSetBlipName(blip)
    local npc = CreatePed(4, pedhash, coords.x, coords.y, coords.z-1, heading, true, true)
        FreezeEntityPosition(npc, true)
        SetEntityHeading(npc, heading)
        SetEntityInvincible(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        TaskStartScenarioInPlace(npc, scenario, -1, true)
end)

function Keymakermenu()
    local Options = {}
    local vehicles = lib.callback.await('mor_keymaker:getVehicles', source)
    local player = Ox.GetPlayer(PlayerId())
    for i=1, #vehicles do
        local plate = vehicles[i].plate
        local vin = vehicles[i].vin
        local model = vehicles[i].model
        local group = vehicles[i].group or 'keine'
        local vehdata = Ox.GetVehicleData(model)
		local vehname = vehdata.name
        table.insert(Options, {title = vehname, description = 'Preis pro Schlüssel: $'..price,
        metadata = {
            {label = 'Kennzeichen: ', value = ''..plate},
            {label = 'Fahrgestellnr.: ', value = ''..vin},
            {label = 'Garage: ', value = ''..vehicles[i].stored},
            {label = 'Gruppe: ', value = ''..group},
        },
        onSelect = function()
            MakeKey(plate, vin, model, price)
        end,
        })
    end
    lib.registerContext({id = 'keymaker', title = label, options = Options})
	lib.showContext('keymaker')
end

function MakeKey(plate, vin, model, price)
    local herstellen = lib.callback.await('mor_keymaker:herstellen', source, plate, vin, model, price)
    if herstellen == 'hergestellt' then
        Mor.Notify('~w~Schlüssel ~g~hergestellt')
    else
        Mor.Notify('~w~Schlüssel ~r~nicht ~w~hergestellt, vielleicht fehlt das Geld?')
    end
end
