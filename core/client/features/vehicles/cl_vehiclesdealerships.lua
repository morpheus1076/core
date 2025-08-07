
if not lib then
    error('ox_lib ist nicht geladen!')
end
lib.locale()
local Mor = require("client.cl_lib")
local cfg = require("shared.cfg_vehicledealers")
local cfgcore = require("shared.cfg_core")

local function IsSpawnPointClear(coords, radius)
    return not IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, radius)
end

local function CreateMenuOptions(data)
    local Options = {}
    local player = Ox.GetPlayer(PlayerId())
    local plyData = player.get('playerdata')
    local menuVehicles = data.vehicles
    local spawnpoints = data.spawnpoints
    for i=1, #menuVehicles do
        local vehData = Ox.GetVehicleData(menuVehicles[i])
        local setPrice = math.floor(vehData.price*data.calculator)
        print(setPrice)
        table.insert(Options, {
            title = vehData.name,
            model = menuVehicles[i],
            image = "nui://core/images/"..menuVehicles[i]..".png",
            metadata = {
                {label = 'Preis ', value = '$'..setPrice..''},
                {label = 'Hersteller ', value = ''..vehData.make..''},
            },
            onSelect = function()
                lib.print.info('Spawnpoints: ', data.spawnpoints)
                for k=1, #spawnpoints do
                    local coord = vec3(spawnpoints[k].x,spawnpoints[k].y,spawnpoints[k].z)
                    lib.print.info(coord)
                    if IsSpawnPointClear(coord, 2) then
                        local vehModel = menuVehicles[i]
                        local group = plyData.group
                        local coords = vec3(coord.x,coord.y,coord.z)
                        local heading = spawnpoints[k].w
                        local garage = data.garage
                        lib.print.info('\nSelected: '..vehModel..'\nGroup: '..group..'')
                        local buyVehicle = lib.callback.await('dealerships:BuyVehicle', source, setPrice, vehModel, group, coords, heading, garage)
                        if buyVehicle then
                            Mor.Notify('Fahrzeug ~g~gekauft~w~.\nEs steht bereit.')
                        else
                            Mor.Notify('Fahrzeugkauf ~r~fehlgeschlagen~w~.\nWahrscheinlich ~r~keine ~w~Kontodeckung?')
                        end
                        break
                    end
                end
            end
        })
    end
    Wait(500)
    lib.registerContext({
        id = 'commercial_menu',
        title = 'Firmenfahrzeuge',
        options = Options
    })
    lib.showContext('commercial_menu')
end

local function VehicleDealerships()
    if cfgcore.VehicleDealershipUse then
        Wait(10000)
        local player = Ox.GetPlayer(PlayerId())
        local plyData = player.get('playerdata')
        Wait(300)
        if not plyData or player then
            Wait(300)
            player = Ox.GetPlayer(PlayerId())
            plyData = player.get('playerdata')
        end
        local data = cfg.commercial[plyData.group]

        Mor.NPC:new({
            coords = vec3(data.npc.coords.x, data.npc.coords.y, data.npc.coords.z),
            heading = data.npc.coords.w,
            model = data.npc.model,
            scenario = data.npc.scenario,
            targetable = true,
            targetoptions = {
                label = 'Verkäufer ansprechen',
                name = 'commercial_seller',
                distance = 2.0,
                onSelect = function()
                    CreateMenuOptions(data)
                end
            },
        })
        Mor.Blip:new({
            coords = vec3(data.npc.coords.x, data.npc.coords.y, data.npc.coords.z),
            name = data.label,
            sprite = 477,
            color = 21,
            hidden = false
        })
    end
end

lib.callback.register('dealership:vehicleproperties', function(data)

end)

AddEventHandler('ox:playerLoaded', function(playerId, isNew)
    Wait(5000)
    VehicleDealerships()
end)

VehicleDealerships()