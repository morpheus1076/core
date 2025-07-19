
local spawnedVehicles = {}

RegisterNetEvent('VehEinparken', function(source, coords, garage, vehnet, properties)
    local src = source
    local vehicle = Ox.GetVehicleFromNetId(vehnet)
    vehicle.setProperties(properties, false)
    vehicle.save()
    MySQL.update('UPDATE vehicles SET park_coord = @coords WHERE plate = @plate', {['@coords'] = coords, ['@plate'] = vehicle.plate})
    MySQL.update('UPDATE vehicles SET garage = @garage WHERE plate = @plate', {['@garage'] = garage, ['@plate'] = vehicle.plate})
    vehicle.setStored(garage, false)
    vehicle.despawn(false)
end)

RegisterNetEvent('VehUpdaten', function(source, coords, heading, garage, vehnet, properties)
    local src = source
    local vehicle = Ox.GetVehicleFromNetId(vehnet)
    if not vehicle then return end
    vehicle.setProperties(properties, false)
    vehicle.save()
    MySQL.update('UPDATE vehicles SET park_coord = @coords WHERE plate = @plate', {['@coords'] = json.encode(coords), ['@plate'] = vehicle.plate})
    MySQL.update('UPDATE vehicles SET park_head = @park_head WHERE plate = @plate', {['@park_head'] = heading, ['@plate'] = vehicle.plate})
    MySQL.update('UPDATE vehicles SET garage = @garage WHERE plate = @plate', {['@garage'] = garage, ['@plate'] = vehicle.plate})
end)

RegisterNetEvent('VehAusparken', function(source, plate, coords, heading)
    local src = source
    local vehs = MySQL.query.await('SELECT * FROM vehicles WHERE plate = @plate ;', {['@plate'] = plate})
    local garage = 'spawned'
    local vehicle = Ox.SpawnVehicle(vehs[1].id, coords, heading)
    local getprops = vehicle.getProperties()

    if vehicle then
        vehicle.setProperties(getprops, true)
        SetVehicleDoorsLocked(vehicle.entity, 2)
        vehicle.setStored(garage, false)
        MySQL.update('UPDATE vehicles SET garage = @garage WHERE plate = @plate', {['@garage'] = garage, ['@plate'] = plate })
    end
end)

lib.callback.register('GetGarageVehicle', function(source, garage)
    local getVehicles = {}
    local player = Ox.GetPlayer(source)
    local owner = player.charId
    if owner then
        getVehicles = MySQL.query.await('SELECT * FROM `vehicles` WHERE `garage` = ? AND `owner` = ? ', {garage, owner})
    end
    if getVehicles then
        return getVehicles
    end
end)

lib.callback.register('PropsGetStart', function(source)
    Wait(100)
    local src = source
    local player = Ox.GetPlayer(src)
    local vehEntities = {}
    local allveh = MySQL.query.await('SELECT * FROM vehicles;')
    if not allveh then return end
    for k,v in ipairs(allveh) do
        if v.park_coord ~= 'null' and v.owner == player.charId then -- vorher UserId???
            local vin = v.vin
            local vehicle = Ox.GetVehicleFromVin(vin)
            if vehicle then
                local coords = vehicle.getCoords()
                local modeldata = Ox.GetVehicleData(vehicle.model)
                local getmodel  = modeldata.name
                local plate = vehicle.plate
                local netentity = vehicle.netId
                Wait(200)
                local sendEntities = {entity = netentity, coords = coords, model = getmodel, plate = plate}
                table.insert(vehEntities, sendEntities)
            end
        end
    end
    return vehEntities
end)

CreateThread(function()
    if cfg_vehicles.aktiv == true then
        local allvehicles = MySQL.query.await('SELECT * FROM vehicles')
        for i=1, #allvehicles do
            if allvehicles[i].park_coord ~= "null" then
                local scoords = allvehicles[i].park_coord
                if scoords ~= "null" then
                    local heading = json.decode(allvehicles[i].park_head)
                    local vehid = allvehicles[i].id
                    local ccoords = json.decode(scoords)
                    local setcoords = vec3(ccoords.x, ccoords.y, ccoords.z)
                    local spawnveh = Ox.SpawnVehicle(vehid, setcoords, heading)

                    if spawnveh then
                        local getprops = spawnveh.getProperties()
                        SetVehicleDoorsLocked(spawnveh.entity, 2)
                        spawnveh.setStored('spawned', false)
                        spawnveh.setProperties(getprops, true)
                        table.insert(spawnedVehicles, spawnveh.plate)
                        TriggerClientEvent('SpawnedVehicleBlip', -1, setcoords)
                    end
                end
            end
        end
        if spawnedVehicles == nil or (type(spawnedVehicles) == "table" and next(spawnedVehicles) == nil) then
            Wait(5000)
            print('Keine Fahrzeuge die gespawned werden müssen in der Datenbank.')
        else
            Wait(5000)
            print('Alle Fahrzeuge aus der Datenbank gespawned')
        end
    else
        Wait(5000)
        print('cfg_vehicles.aktiv ist deaktiviert (cfg_vehicles in mor_vehicles).')
    end
end)
