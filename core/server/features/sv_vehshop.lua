
lib.callback.register('GetAllVehicles', function(source)
    local vehs = MySQL.query.await('SELECT * FROM listvehicles')
    Wait(50)
    return vehs
end)

lib.callback.register('VorschauVehicle', function(source, model, coords, heading)
    local player = Ox.GetPlayer(source)
    local garage = 'legionsquare'
    local spawndata = {model = model, owner = player.charId, stored = garage}
    local veh = Ox.CreateVehicle(spawndata, coords, heading)
    Wait(1000)
    SetVehicleColours(veh.entity,111,111)
    FreezeEntityPosition(veh.entity, true)
    SetVehicleDirtLevel(veh.entity, 0.0)
    TaskWarpPedIntoVehicle(player.ped, veh.entity, -1)
    local datareturn = {veh}
    return datareturn
end)

lib.callback.register('PrivatBarKauf', function(source, price, kvehicle, vehicleprops)
    local player = Ox.GetPlayer(source)
    local props = vehicleprops or {}
    local garage = 'legionsquare'
    for i=1, #kvehicle do
        local veh = kvehicle[i]
        vehicle = Ox.GetVehicleFromVin(veh.vin)
        Wait(200)
        vehicle.setStored(garage, false)
        vehicle.save()
        Wait(800)
        SetVehicleDirtLevel(vehicle.entity, 0.0)
        FreezeEntityPosition(vehicle.entity, false)
        TaskWarpPedIntoVehicle(player.ped, vehicle.entity, -1)
    end
    local plate = vehicle.plate or props.plate
    if plate == nil then print('sv_vehshop :: Plate ist nil???') end
    local vehData = Ox.GetVehicleData(vehicle.model)
    exports.ox_inventory:RemoveItem(player.source, 'money', price)
    exports.ox_inventory:AddItem(player.source, 'keys', 1, {label = vehData.name, Kennzeichen = vehicle.plate, type = 'Master '..vehicle.plate..'', description = 'VIN: '..vehicle.vin..'', name = "Model: "..vehicle.model})
    return 'verkauft'
end)

lib.callback.register('PrivatBank', function(source, price, kvehicle, vehicleprops)
    local player = Ox.GetPlayer(source)
    local account = player.getAccount()
    local accountbalance = account.get('balance')
    local sellaccount = Ox.GetGroupAccount('staat')
    local props = vehicleprops or {}
    local garage = 'legionsquare'
    for i=1, #kvehicle do
        local veh = kvehicle[i]
        vehicle = Ox.GetVehicleFromVin(veh.vin)
        Wait(50)
        vehicle.setStored(garage, false)
        vehicle.save()
        Wait(800)
        SetVehicleDirtLevel(vehicle.entity, 0.0)
        FreezeEntityPosition(vehicle.entity, false)
        TaskWarpPedIntoVehicle(player.ped, vehicle.entity, -1)
    end
    local plate = vehicle.plate or props.plate
    if plate == nil then print('sv_vehshop :: Plate ist nil???') end
    if accountbalance >= price then
        account.removeBalance({amount = price, message = "Fahrzeugkauf :: VIN: "..vehicle.vin.."", true})
        sellaccount.addBalance({amount = price, message = "Fahrzeugkauf :: VIN: "..vehicle.vin.."", true})
        local vehData = Ox.GetVehicleData(vehicle.model)
        exports.ox_inventory:AddItem(player.source, 'keys', 1, {label = vehData.name, Kennzeichen = vehicle.plate, type = 'Master '..vehicle.plate..'', description = 'VIN: '..vehicle.vin..'', name = "Model: "..vehicle.model})
        MySQL.update('UPDATE vehicles SET props = @props WHERE plate = @plate', {['@props'] = json.encode(props), ['@plate'] = plate })
        return 'verkauft'
    else
        VehicleDelete(vehicle)
        --Notify('~r~Keine Deckung durch die Bank.')
    end
    return true
end)

lib.callback.register('JobBar', function(source, price, kvehicle, vehicleprops)
    local player = Ox.GetPlayer(source)
    local props = vehicleprops or {}
    local pgroups = player.getGroups()
    local pgroup = player.getGroup(pgroups)
    local garage = 'legionsquare'
    for i=1, #kvehicle do
        local veh = kvehicle[i]
        vehicle = Ox.GetVehicleFromVin(veh.vin)
        Wait(50)
        vehicle.setStored(garage, false)
        vehicle.save()
        Wait(800)
        SetVehicleDirtLevel(vehicle.entity, 0.0)
        FreezeEntityPosition(vehicle.entity, false)
        TaskWarpPedIntoVehicle(player.ped, vehicle.entity, -1)
    end
    local plate = vehicle.plate or props.plate
    if plate == nil then print('sv_vehshop :: Plate ist nil???') end
    local vehData = Ox.GetVehicleData(vehicle.model)
    exports.ox_inventory:RemoveItem(player.source, 'money', price)
    exports.ox_inventory:AddItem(player.source, 'keys', 1, {label = vehData.name, Kennzeichen = vehicle.plate, type = 'Master '..vehicle.plate..'', description = 'VIN: '..vehicle.vin..'', name = "Model: "..vehicle.model})
    Wait(50)
    MySQL.update('UPDATE vehicles SET props = @props WHERE plate = @plate', {['@props'] = json.encode(props), ['@plate'] = plate })
    return 'verkauft'
end)

lib.callback.register('JobBank', function(source, price, kvehicle, vehicleprops)
    local player = Ox.GetPlayer(source)
    local props = vehicleprops or {}
    local pgroups = player.getGroups()
    local pgroup = player.getGroup(pgroups)
    local groupaccount = Ox.GetGroupAccount(pgroup)
    local groupbalance = groupaccount.get('balance')
    local sellaccount = Ox.GetGroupAccount('staat')
    local garage = 'legionsquare'
    for i=1, #kvehicle do
        local veh = kvehicle[i]
        vehicle = Ox.GetVehicleFromVin(veh.vin)
        Wait(50)
        vehicle.setStored(garage, false)
        vehicle.save()
        Wait(800)
        SetVehicleDirtLevel(vehicle.entity, 0.0)
        FreezeEntityPosition(vehicle.entity, false)
        TaskWarpPedIntoVehicle(player.ped, vehicle.entity, -1)
    end
    local plate = vehicle.plate or props.plate
    if plate == nil then print('sv_vehshop :: Plate ist nil???') end
    if groupbalance >= price then
        local vehData = Ox.GetVehicleData(vehicle.model)
        groupaccount.removeBalance({amount = price, message = "Fahrzeugkauf :: VIN: "..vehicle.vin.."", true})
        sellaccount.addBalance({amount = price, message = "Fahrzeugkauf :: VIN: "..vehicle.vin.."", true})
        exports.ox_inventory:AddItem(player.source, 'keys', 1, {label = vehData.name, Kennzeichen = vehicle.plate, type = 'Master '..vehicle.plate..'', description = 'VIN: '..vehicle.vin..'', name = "Model: "..vehicle.model})
        Wait(50)
        MySQL.update('UPDATE vehicles SET props = @props WHERE plate = @plate', {['@props'] = json.encode(props), ['@plate'] = plate })
        return 'verkauft'
    else
        --Notify('~r~Keine Deckung durch die Firma.')
        VehicleDelete(vehicle)
    end
end)

lib.callback.register('VehicleDelete', function(source, vehicle)
    for i=1, #vehicle do
        local vehdel = vehicle[i]
        local vehicle = Ox.GetVehicleFromVin(vehdel.vin)
        vehicle.delete()
    end
    return vehicle.entity
end)

function VehicleDelete(vehicle)
    for i=1, #vehicle do
        local vehdel = vehicle[i]
        local vehicle = Ox.GetVehicleFromVin(vehdel.vin)
        vehicle.delete()
    end
end